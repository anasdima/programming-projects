#include <stdio.h>
#include <stdlib.h>
#include "cuda.h"
#include <curand.h>
#include <curand_kernel.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>
#include <unistd.h>

#define HASH_STEP 720
#define WARP_SIZE 32

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }

inline void gpuAssert(cudaError_t code, char *file, int line, bool abort=true)
{
   if (code != cudaSuccess) 
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

__global__ void generate_randoms(float *d_random_r, int numDim, unsigned long seed) {

	int idx = threadIdx.x + blockIdx.x*blockDim.x;
    curandState localState;
    curand_init (seed, idx, 0, &localState);
    
    for(int i=0;i<numDim;i++) {

    	d_random_r[idx*(numDim+1)+i] = curand_uniform(&localState); // ri [0,1]
    }

    d_random_r[idx*(numDim+1)+numDim] = curand_uniform(&localState)*HASH_STEP; // bi [0,720]
}

__device__ float matrix_multiplication(float *d_data, float *d_random_r, int numDim) {

	float sum = 0;

	for(int i=0;i<numDim;i++) {

		sum += d_data[i]*d_random_r[i];
	}

	return(sum);

}

__global__ void hash_f(float *d_data, int *d_hash_codes, float *d_random_r, int numDim, unsigned long seed) {

    int idx = threadIdx.x + blockIdx.x*blockDim.x;
    d_hash_codes[idx] = floorf((matrix_multiplication(&d_data[(idx/numDim)*numDim],&d_random_r[idx*(numDim+1)],numDim)
    				+ d_random_r[idx*(numDim+1)+numDim])/HASH_STEP);
}

__global__ void initial_count(int *d_hash_codes, int *d_offsets, int digit, int numDim, int NTHREADS) {

	int idx = threadIdx.x + blockIdx.x*blockDim.x;
	int s_zeros = 0,s_ones = 0;

	for(int i=0;i<64;i++) {

		if(d_hash_codes[idx*numDim*64+i*numDim+numDim-digit] == 0) {
			s_zeros++;
		}
		else if(d_hash_codes[idx*numDim*64+i*numDim+numDim-digit] == 1){
			s_ones++;
		}
	}

	d_offsets[idx*2+2] = s_zeros; // First 2 slots are 0 in the table
	d_offsets[idx*2+3] = s_ones;  // Same

}

__global__ void lsd_count(int *d_hash_codes, int *d_offsets, int *d_ids, int digit, int numDim, int NTHREADS) {

	int idx = threadIdx.x + blockIdx.x*blockDim.x;
	int s_zeros = 0,s_ones = 0;

	for(int i=0;i<64;i++) {

		if(d_hash_codes[d_ids[idx*64+i]*numDim+numDim-digit] == 0) {
			s_zeros++;
		}
		else if(d_hash_codes[d_ids[idx*64+i]*numDim+numDim-digit] == 1){
			s_ones++;
		}
	}

	d_offsets[idx*2+2] = s_zeros; // First 2 slots are 0 in the table
	d_offsets[idx*2+3] = s_ones;  // Same

}

__global__ void initialize_sorting(int *d_hash_codes, int *d_offsets, int *d_ids_1, int digit, int numDim, int NTHREADS) {

	int idx = threadIdx.x + blockIdx.x*blockDim.x;
	int offset_zero = d_offsets[idx*2];
	int offset_one = d_offsets[idx*2+1]+d_offsets[2*NTHREADS]; // d_offsets[2*NTHREADS] holds the total number of zeros

	for(int i=0;i<64;i++) {

		if(d_hash_codes[idx*numDim*64+i*numDim+numDim-digit] == 0) {

			d_ids_1[offset_zero] = idx*64+i;
			offset_zero++;

		}
		else if(d_hash_codes[idx*numDim*64+i*numDim+numDim-digit] == 1){

			d_ids_1[offset_one] = idx*64+i;
			offset_one++;

		}

	}

	// At this point offset_zero + offset_one = 64

}

__global__ void radix_sort(int *d_hash_codes, int *d_offsets, int *d_ids_1, int *d_ids_2, int digit, int numDim, int NTHREADS) {

	int idx = threadIdx.x + blockIdx.x*blockDim.x;
	int offset_zero = d_offsets[idx*2];
	int offset_one = d_offsets[idx*2+1]+d_offsets[2*NTHREADS]; // d_offsets[2*NTHREADS] holds the total number of zeros

	for(int i=0;i<64;i++) {

		if(d_hash_codes[d_ids_1[idx*64+i]*numDim+numDim-digit] == 0) {

			d_ids_2[offset_zero] = d_ids_1[idx*64+i];
			offset_zero++;

		}
		else if(d_hash_codes[d_ids_1[idx*64+i]*numDim+numDim-digit] == 1){

			d_ids_2[offset_one] = d_ids_1[idx*64+i];
			offset_one++;

		}

	}

	// At this point offset_zero + offset_one = 64

}

__global__ void write_sorted_hash_codes(int *d_hash_codes, int *d_sorted_hash_codes, int *d_ids, int numDim) {

	int idx = threadIdx.x + blockIdx.x*blockDim.x;

	for(int i=0;i<64;i++) {
		for(int j=0;j<numDim;j++) {
			d_sorted_hash_codes[idx*64*numDim+i*numDim+j] = d_hash_codes[d_ids[idx*64+i]*numDim+j];
		}
	}
}

void lsh(int numObjects, int numDim, float *h_data) {

	/* Generate hash codes */

	int NTHREADS = ceil((float)numObjects*numDim/(float)(64*WARP_SIZE)); //Concurrent threads per loop
	int BLOCK_SIZE = 256;
	int GRID_SIZE = ceil((float)NTHREADS/(float)BLOCK_SIZE);

	dim3 grid(GRID_SIZE,1);
	dim3 threads(BLOCK_SIZE,1);

	printf("NTHREADS:%d GRID_SIZE:%d BLOCK_SIZE:%d\n", NTHREADS,GRID_SIZE,BLOCK_SIZE);

	float *d_random_r;
	cudaMalloc((void**)&d_random_r,NTHREADS*(numDim+1)*sizeof(float)); // numDim+1 because ri has numDim values and bi has 1

	float *d_data;
	cudaMalloc((void**)&d_data,numObjects*numDim*sizeof(float));
	cudaMemcpy(d_data,h_data,numObjects*numDim*sizeof(float),cudaMemcpyHostToDevice);

	int *d_hash_codes;
	cudaMalloc((void**)&d_hash_codes, numObjects*numDim*sizeof(int));

    for(int i=0;i<64*WARP_SIZE;i++) {

    	generate_randoms<<<grid,threads>>>(d_random_r,numDim,time(NULL));

    	hash_f<<<grid,threads>>>(&d_data[i*NTHREADS],&d_hash_codes[i*NTHREADS],d_random_r,numDim,time(NULL));

    }

    cudaFree(d_random_r);
    cudaFree(d_data);

    int *h_hash_codes;
	h_hash_codes = (int *)malloc(numObjects*numDim*sizeof(int));

	cudaMemcpy(h_hash_codes,d_hash_codes,numObjects*numDim*sizeof(int),cudaMemcpyDeviceToHost);

    /* Sort hash codes */

    NTHREADS = ceil((float)numObjects/(float)64); //Concurrent threads per loop
	BLOCK_SIZE = 256;
	GRID_SIZE = ceil((float)NTHREADS/(float)BLOCK_SIZE);

	dim3 grid_2(GRID_SIZE,1);
	dim3 threads_2(BLOCK_SIZE,1);

	printf("NTHREADS:%d GRID_SIZE:%d BLOCK_SIZE:%d\n", NTHREADS,GRID_SIZE,BLOCK_SIZE);

	int *d_ids_1;
	cudaMalloc((void**)&d_ids_1,numObjects*sizeof(int));

	int *d_ids_2;
	cudaMalloc((void**)&d_ids_2,numObjects*sizeof(int));

	int *d_offsets;
	cudaMalloc((void**)&d_offsets,(2*NTHREADS+2)*sizeof(int));

	int *d_sorted_hash_codes;
	cudaMalloc((void**)&d_sorted_hash_codes, numObjects*numDim*sizeof(int));

	initial_count<<<grid_2,threads_2>>>(d_hash_codes,d_offsets,1,numDim,NTHREADS);

	cudaDeviceSynchronize();

	int *h_offsets;
	h_offsets = (int *)malloc((2*NTHREADS+2)*sizeof(int));

	cudaMemcpy(h_offsets,d_offsets,(2*NTHREADS+2)*sizeof(int),cudaMemcpyDeviceToHost);

	//Calculate offsets serially

	h_offsets[0] = 0;
	h_offsets[1] = 0;

	for(int j=2;j<(2*NTHREADS+2);j++) {

			h_offsets[j] += h_offsets[j-2];
	}

	cudaMemcpy(d_offsets,h_offsets,(2*NTHREADS+2)*sizeof(int),cudaMemcpyHostToDevice);

	initialize_sorting<<<grid_2,threads_2>>>(d_hash_codes,d_offsets,d_ids_1,1,numDim,NTHREADS);

	for(int i=1;i<numDim;i++) {

		if (i%2!=0) {

			lsd_count<<<grid_2,threads_2>>>(d_hash_codes,d_offsets,d_ids_1,(i+1),numDim,NTHREADS);

			cudaMemcpy(h_offsets,d_offsets,(2*NTHREADS+2)*sizeof(int),cudaMemcpyDeviceToHost);

			//Calculate offsets serially
			h_offsets[0] = 0;
			h_offsets[1] = 0;

			for(int j=2;j<(2*NTHREADS+2);j++) {

				h_offsets[j] += h_offsets[j-2];
			}

			cudaMemcpy(d_offsets,h_offsets,(2*NTHREADS+2)*sizeof(int),cudaMemcpyHostToDevice);

			radix_sort<<<grid_2, threads_2>>>(d_hash_codes,d_offsets,d_ids_1,d_ids_2,(i+1),numDim,NTHREADS);

		}
		else {

			lsd_count<<<grid_2,threads_2>>>(d_hash_codes,d_offsets,d_ids_2,(i+1),numDim,NTHREADS);

			cudaMemcpy(h_offsets,d_offsets,(2*NTHREADS+2)*sizeof(int),cudaMemcpyDeviceToHost);

			//Calculate offsets serially

			h_offsets[0] = 0;
			h_offsets[1] = 0;

			for(int j=2;j<(2*NTHREADS+2);j++) {

					h_offsets[j] += h_offsets[j-2];
			}

			cudaMemcpy(d_offsets,h_offsets,(2*NTHREADS+2)*sizeof(int),cudaMemcpyHostToDevice);

			radix_sort<<<grid_2, threads_2>>>(d_hash_codes,d_offsets,d_ids_2,d_ids_1,(i+1),numDim,NTHREADS);
				
		}

	}

	write_sorted_hash_codes<<<grid_2, threads_2>>>(d_hash_codes,d_sorted_hash_codes,d_ids_2,numDim);

	int *h_sorted_hash_codes;
	h_sorted_hash_codes = (int *)malloc(numObjects*numDim*sizeof(int));

	cudaMemcpy(h_sorted_hash_codes,d_sorted_hash_codes,numObjects*numDim*sizeof(int),cudaMemcpyDeviceToHost);

}

int main(int argc, char** argv) {

	int numObjects = atoi(argv[1]);
	int numDim = atoi(argv[2]);

	FILE *dataset;
	float *h_data;
	h_data = (float *)malloc(numObjects*numDim*sizeof(float));

	dataset = fopen("/export/home/dhmtasos/Ergasia4/data.bin", "rb");
	if(dataset == NULL) {
		printf("Error opening data.bin\n");
	}

	size_t a = fread(h_data, sizeof(float), numObjects*numDim, dataset);
	if(a!=numObjects*numDim) {
		printf("Error reading data from data.bin\n");
	}

	fclose(dataset);

	struct timeval first, second, lapsed;
	struct timezone tzp;

	gettimeofday(&first, &tzp);

	lsh(numObjects,numDim,h_data);

	gettimeofday(&second, &tzp);

	if(first.tv_usec>second.tv_usec){
		second.tv_usec += 1000000;
		second.tv_sec--;
	}
  
	lapsed.tv_usec = second.tv_usec - first.tv_usec;
	lapsed.tv_sec = second.tv_sec - first.tv_sec;

	printf("Time elapsed: %d, %d s\n", lapsed.tv_sec, lapsed.tv_usec);

}