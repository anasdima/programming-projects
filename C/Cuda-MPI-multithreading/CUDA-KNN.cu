#include <stdio.h>
#include <stdlib.h>
#include "utils.h"
#include <time.h>
#include <sys/time.h>
#include "cuda.h"
#include <math.h>
#include <float.h>

#define BlockSize 512

void random_initialization(knn_struct *set, int cal){

 int i = 0;
 int n = set->leading_dim;
 int m = set->secondary_dim;
 float *tmp_set = set->data;

 srand(cal*time(NULL));
 /*Generate random floating points [-50 50]*/
 for(i=0; i<m*n; i++){
 
   tmp_set[i] = 100 * (float)rand() / RAND_MAX - 50; 

 }

}

void save_d(float* data, char* file, int N, int M){

  FILE *outfile;
  
  printf("Saving data to file: %s\n", file);

  if((outfile=fopen(file, "wb")) == NULL){
    printf("Can't open output file");
  }

  fwrite(data, sizeof(float), N*M, outfile);

  fclose(outfile);

}

void save_int(int* data, char* file, int N, int M){

  FILE *outfile;
  
  printf("Saving data to file: %s\n", file);

  if((outfile=fopen(file, "wb")) == NULL){
    printf("Can't open output file");
  }

  fwrite(data, sizeof(int), N*M, outfile);

  fclose(outfile);

}

void clean(knn_struct* d){

  free(d->data);
}

__device__ float euclidean_distance(float *X, float *Y, int N){

	int i = 0;
	float dst = 0;

#pragma unroll 2
	for(i=0; i<N; i++){
		float tmp = (X[i] - Y[i]);
		dst += tmp * tmp;
	}

  return(dst);
}

__global__ void compute_distance(float* query, float* data, float* dist, int* idx, int numObjects, int numAttributes){

	extern __shared__ float Qs[];
	
	int tid = threadIdx.x + blockIdx.x*blockDim.x;
	int element = tid;
		
	__syncthreads();
		
	if(tid<numObjects) {
		if(threadIdx.x<numAttributes) {  /* load query in shared memory */
			Qs[threadIdx.x] = query[threadIdx.x];
		}
			
		__syncthreads();

		dist[element] = euclidean_distance(data + element*numAttributes, Qs, numAttributes);	
		idx[element] = tid;
	}
}

__global__ void reduce(float* dist, int* idx, int N, int stride){

	int tid = threadIdx.x + blockIdx.x*blockDim.x;
	int element = tid;
		
	if(tid < (stride) ) {
	
		if(dist[element]>dist[element+stride]) {
		
			dist[element] = dist[element+stride];
			idx[element] = idx[element+stride];
		}
	}

}

void knns(knn_struct* queries, knn_struct* dataset, float *NNdist, int *NNidx, int k){

	float *d_dist,*d_tmp_dist;
	int *d_idx,*d_tmp_idx;
	int numQueries = queries->secondary_dim;
	int numObjects = dataset->secondary_dim;
	int numAttributes = dataset->leading_dim;
	int i,j;
	unsigned long stride=0;
	float max = FLT_MAX;
		
	cudaMalloc((void**)&d_dist, numObjects*sizeof(float));
	cudaMalloc((void**)&d_idx, numObjects*sizeof(int));
	
	// Used for parallel reduction	
	cudaMalloc((void**)&d_tmp_dist, numObjects*sizeof(float));
	cudaMalloc((void**)&d_tmp_idx, numObjects*sizeof(int));
	float h_tmp_dist[2];
	int h_tmp_idx[2];
  
	float tmp_grid_size = (int) ceil((float)numObjects/(float)BlockSize);
	float tmp_block_size = numObjects<BlockSize ? numObjects:BlockSize;

	dim3 grid((int)tmp_grid_size,1);
	dim3 threads((int)tmp_block_size, 1);  
	
	printf("Grid size: %f | Block size: %f\n",tmp_grid_size,tmp_block_size);
	
	for(i=0;i<numQueries;i++) {
		
		compute_distance<<< grid, threads, numAttributes*sizeof(float) >>>(queries->data+i*numAttributes, dataset->data, d_dist, d_idx, numObjects, numAttributes);	
		
		float distance;
		cudaMemcpy(&distance, d_dist, 1*sizeof(float), cudaMemcpyDeviceToHost);
	
		/* Find k nearest neighbours */
		for(j=0;j<k;j++) {
		
			/* Set reduce grid parameters and stride */
			tmp_grid_size = ceil((float)numObjects/((float)BlockSize*2.0));	
			dim3 reduce_grid((int)tmp_grid_size);
			if(numObjects%2 == 0) {
				stride = numObjects/2;
			}
			else {
				stride = numObjects/2 + 1;				
			}
	
			/* Copy distances and indexes to temp, editable memory */
			cudaMemcpy(d_tmp_dist, d_dist, numObjects*sizeof(float), cudaMemcpyDeviceToDevice);
			cudaMemcpy(d_tmp_idx, d_idx, numObjects*sizeof(int), cudaMemcpyDeviceToDevice);

			/* Find minimum distance using parallel reduction */
			while(stride > 1) {
						
				reduce<<< reduce_grid, threads >>>(d_tmp_dist, d_tmp_idx, numObjects, stride); // Global sync point
				
				tmp_grid_size = ceil((float)tmp_grid_size/2.0);
				dim3 reduce_grid((int)tmp_grid_size);
				
				if(stride%2 == 0) {
					stride = stride/2;
				}
				else {
					stride = stride/2 + 1;				
				}
				
			}
					
			cudaMemcpy(h_tmp_dist, d_tmp_dist, 2*sizeof(float), cudaMemcpyDeviceToHost);
			cudaMemcpy(h_tmp_idx, d_tmp_idx, 2*sizeof(int), cudaMemcpyDeviceToHost);
						
			if(h_tmp_dist[0] < h_tmp_dist[1]) {
			
				NNdist[i*k+j] = h_tmp_dist[0];
				NNidx[i*k+j] = h_tmp_idx[0];
				
			}
			else {
			
				NNdist[i*k+j] = h_tmp_dist[1];
				NNidx[i*k+j] = h_tmp_idx[1];
				
			}
					
			cudaMemcpy(d_dist+NNidx[i*k+j], &max, sizeof(float), cudaMemcpyHostToDevice); // Exclude this minimum distance for the next minimum search
			
		}
		
	}
	
	cudaFree(d_dist);
	cudaFree(d_tmp_dist);
	cudaFree(d_idx);
	cudaFree(d_tmp_idx);
}

int main(int argc, char **argv){

	int numObjects = atoi(argv[1]);
	int numDim = atoi(argv[2]);
	int numQueries = atoi(argv[3]);
	int k = atoi(argv[4]);

	printf("objects: %d\n", numObjects);
	printf("dimentions: %d\n", numDim);
	printf("queries: %d\n", numQueries);
	printf("k: %d\n", k);

	/*===== Host ======*/
	struct timeval first, second, lapsed;
	struct timezone tzp;
  
	//size_t memory_free, memory_total;

	char *dataset_file = "training_set.bin";
	char *query_file = "query_set.bin";
	char *KNNdist_file = "KNNdist.bin";
	char *KNNidx_file = "KNNidx.bin" ;

	knn_struct training_set;
	knn_struct query_set;
	float *NNdist;
	int *NNidx;
  
	/*==== Device ======*/
	knn_struct d_training_set;
	knn_struct d_query_set;
  
	/*======== Initialization =======*/
	training_set.leading_dim = numDim;
	training_set.secondary_dim = numObjects;
	query_set.leading_dim = numDim;
	query_set.secondary_dim = numQueries;
  
	d_training_set.leading_dim = numDim;
	d_training_set.secondary_dim = numObjects;
	d_query_set.leading_dim = numDim;
	d_query_set.secondary_dim = numQueries;
  
	/*======== Host memory allocation ======*/
	training_set.data = (float*)malloc(numObjects*numDim*sizeof(float));
	query_set.data = (float*)malloc(numQueries*numDim*sizeof(float));
	NNdist = (float*)malloc(numQueries*k*sizeof(float));
	NNidx = (int*)malloc(numQueries*k*sizeof(int));  
 
	/*========= Device memory allocation======*/
	cudaMalloc((void **)&d_training_set.data, training_set.leading_dim*training_set.secondary_dim*sizeof(float));
	cudaMalloc((void**)&d_query_set.data, query_set.leading_dim*query_set.secondary_dim*sizeof(float));
  
	/*======== Initialize =========*/
	random_initialization(&training_set, 1);
	random_initialization(&query_set, 2);
  
	/*========= Device memory initialization =========*/
	cudaMemcpy(d_training_set.data, training_set.data, training_set.leading_dim*training_set.secondary_dim*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_query_set.data, query_set.data, query_set.leading_dim*query_set.secondary_dim*sizeof(float), cudaMemcpyHostToDevice);
  
	gettimeofday(&first, &tzp);

	knns(&d_query_set, &d_training_set, NNdist, NNidx, k);

	gettimeofday(&second, &tzp);
  
	if(first.tv_usec>second.tv_usec){
		second.tv_usec += 1000000;
		second.tv_sec--;
	}
  
	lapsed.tv_usec = second.tv_usec - first.tv_usec;
	lapsed.tv_sec = second.tv_sec - first.tv_sec;

	printf("Time elapsed: %d, %d s\n", lapsed.tv_sec, lapsed.tv_usec); 

	save_d(query_set.data, query_file, numQueries, numDim);
	save_d(training_set.data, dataset_file, numObjects, numDim);
	save_d(NNdist, KNNdist_file, k, numQueries);
	save_int(NNidx, KNNidx_file, k, numQueries);

	/*===== clean memory ========*/
	clean(&training_set);
	clean(&query_set);
	free(NNdist);
	free(NNidx);

}




