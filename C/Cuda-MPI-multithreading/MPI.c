#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include "kmeans.h"
#include "mpi_gather.h"
#include "cluster.h"
#include <time.h>
#include <sys/time.h>

#define max_iterations 50

void receive_workload(int workload, int *subworkload_start, int *subworkload, int world_size, int world_rank) {

  if (world_size > workload) {

    printf("Well this can't be right... number of tasks greater than workload. Terminating");
    MPI_Abort(MPI_COMM_WORLD, 1);

  }

  *subworkload_start = workload / world_size * world_rank;
  *subworkload = workload / world_size;

  if (world_rank == world_size -1) {

    *subworkload += workload % world_size;

  }
}

void random_initialization(data_struct *data_in,int world_rank){

  int i, j = 0;
  int n = data_in->leading_dim;
  int m = data_in->secondary_dim;
  double *tmp_dataset = data_in->dataset;
  unsigned int *tmp_Index = data_in->members;

  srand(world_rank*time(NULL)); // generate different random numbers
  // srand(0); // generate the same random numbers on every run
  // random floating points [0 1]
  for(i=0; i<m; i++){
    tmp_Index[i] = 0;
    for(j=0; j<n; j++){
      tmp_dataset[i*n + j] = (double) rand() / RAND_MAX;
    }
  }
}


void initialize_clusters(double *data, int numObjects, data_struct *cluster_in){

  int i, j, pick = 0;
  int n = cluster_in->leading_dim;
  int m = cluster_in->secondary_dim;
  int Objects = numObjects;
  double *tmp_Centroids = cluster_in->dataset;
  double *tmp_dataset = data;

  int step = Objects / m;

  /*randomly pick initial cluster centers*/
  for(i=0; i<m; i++){
    for(j=0; j<n; j++){
      tmp_Centroids[i*n + j] = tmp_dataset[pick * n + j];
    }
    pick += step; 
  }

}

void save(data_struct* data2save, char *filename1, char *filename2){

  int i, j = 0;
  FILE *outfile;
  int n = data2save->leading_dim;
  int m = data2save->secondary_dim;
  double *tmp_dataset = data2save->dataset;
  unsigned int *tmp_members = data2save->members;

  printf("Saving data to files: "); printf(filename1); printf(" and "); printf(filename2); printf("\n");

  /*===========Save to file 1===========*/
  if((outfile=fopen(filename1, "wb")) == NULL){
    printf("Can't open output file\n");
  }

  fwrite(tmp_dataset, sizeof(double), m*n, outfile);

  fclose(outfile);

  /*===========Save to file 2========*/

  if((outfile=fopen(filename2, "wb")) == NULL){
    printf("Can't open output file\n");
  }

  fwrite(tmp_members, sizeof(unsigned int), m, outfile);

  fclose(outfile);

}

void clean(data_struct* data1){

  free(data1->dataset);
  free(data1->members);
}

int main(int argc,char **argv) {

  struct timeval first, second, lapsed;
  struct timezone tzp;

  int rc;
  rc = MPI_Init(NULL,NULL);
  if (rc != MPI_SUCCESS) {
    printf ("Error starting MPI program. Terminating.\n");
    MPI_Abort(MPI_COMM_WORLD, rc);
  }

  int  world_size;
  MPI_Comm_size(MPI_COMM_WORLD,&world_size);
  int world_rank;
  MPI_Comm_rank(MPI_COMM_WORLD,&world_rank);
  int len;
  char hostname[MPI_MAX_PROCESSOR_NAME];
  MPI_Get_processor_name(hostname, &len);

  int numObjects = atoi(argv[1]);
  int numAttributes = atoi(argv[2]);
  int numClusters = atoi(argv[3]);

  int subworkload_start, subworkload;

  /* Receive your workload */

  receive_workload(numObjects, &subworkload_start, &subworkload, world_size, world_rank);

  data_struct data_in;
  data_struct clusters;
  collector_struct gathers;

  if (world_rank == 0) {
    gettimeofday(&first, &tzp);
  }

  /*=======Memory Allocation=========*/
  data_in.leading_dim = numAttributes;
  data_in.secondary_dim = subworkload;
  data_in.dataset = (double*)malloc(subworkload*numAttributes*sizeof(double));
  data_in.members = (unsigned int*)malloc(subworkload*sizeof(unsigned int));

  clusters.leading_dim = numAttributes;
  clusters.secondary_dim = numClusters;
  clusters.dataset = (double*)malloc(numClusters*numAttributes*sizeof(double));
  clusters.members = (unsigned int*)malloc(numClusters*sizeof(unsigned int));

  gathers.centroids = (double *) malloc(world_size*(clusters.leading_dim)*(clusters.secondary_dim)*sizeof(double));
  gathers.cluster_size = (int *) malloc(world_size*(clusters.secondary_dim)*sizeof(int));
  /* Only root gathers SumOfDist */
  if (world_rank == 0) {
    gathers.SumOfDist = (double *) malloc(world_size*sizeof(double));
  }
  else {
    gathers.SumOfDist = NULL;
  }

  /*=============initialize==========*/
  random_initialization(&data_in,world_rank);  // Each process randomly initializes one chunk of the dataset with size of subworkload

  /* Gather dataset to root */

  double *temp_dataset = NULL;
  int *sizes = NULL;
  int *displs = NULL;
  if (world_rank == 0) {

    temp_dataset = (double *) malloc(numAttributes*numObjects*sizeof(double));

  }

  if (numObjects % world_size == 0) { // If numObjects is a multiple of number of processes then subworkloads are equal in size

    MPI_Gather(data_in.dataset, subworkload*data_in.leading_dim, MPI_DOUBLE, temp_dataset, subworkload*data_in.leading_dim, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  }
  else { // If not, then the last process has a larger buffer than the others

    /* Send buffer sizes to root */

    if (world_rank==0) {

      sizes = (int *) malloc(world_size*sizeof(int));
      displs = (int *) malloc(world_size*sizeof(int));

    }

    int size = subworkload*data_in.leading_dim;

    MPI_Gather(&size, 1, MPI_INT, sizes, 1, MPI_INT, 0, MPI_COMM_WORLD);
  
    if (world_rank == 0) {

      int i;
      for(i=0;i<world_size;i++) {

        displs[i] = i*subworkload*data_in.leading_dim;

      }

    }

    MPI_Gatherv(data_in.dataset, subworkload*data_in.leading_dim, MPI_DOUBLE, temp_dataset, sizes, displs, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  }

  
  if (world_rank == 0) {

    initialize_clusters(temp_dataset, numObjects, &clusters);

  }

  MPI_Bcast(clusters.dataset, clusters.leading_dim*clusters.secondary_dim, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  if (world_rank == 0) {

    gettimeofday(&second, &tzp);

    if(first.tv_usec>second.tv_usec){
      second.tv_usec += 1000000;
      second.tv_sec--;
    }
  
    lapsed.tv_usec = second.tv_usec - first.tv_usec;
    lapsed.tv_sec = second.tv_sec - first.tv_sec;

    printf("Initialization took: %d.%06dsec\n", lapsed.tv_sec, lapsed.tv_usec); 

  }

  /*=================================*/

  if (world_rank == 0) {
    gettimeofday(&first, &tzp);
  }

  cluster(&data_in, &clusters, &gathers, max_iterations);

  int *temp_members;
  if (world_rank == 0) {

    temp_members = (int *) malloc(numObjects*sizeof(int));

  }

  /* Gather Indexes */
  if (numObjects % world_size == 0) {

    MPI_Gather(data_in.members, subworkload, MPI_INT, temp_members, subworkload, MPI_INT, 0, MPI_COMM_WORLD);

  }
  else {

    int size = subworkload;

    MPI_Gather(&size, 1, MPI_INT, sizes, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if(world_rank == 0) {
      int i;
      for(i=0;i<world_size;i++) {

        displs[i] = i*subworkload;

      }
    }

    MPI_Gatherv(data_in.members, subworkload, MPI_INT, temp_members, sizes, displs, MPI_INT, 0, MPI_COMM_WORLD);

  }



  if (world_rank == 0) {

    gettimeofday(&second, &tzp);

    if(first.tv_usec>second.tv_usec){
      second.tv_usec += 1000000;
      second.tv_sec--;
    }
  
    lapsed.tv_usec = second.tv_usec - first.tv_usec;
    lapsed.tv_sec = second.tv_sec - first.tv_sec;

    printf("Time elapsed: %d.%06dsec\n", lapsed.tv_sec, lapsed.tv_usec); 

  }

  /*========save data============*/
  if (world_rank == 0) {

    data_in.dataset = temp_dataset;
    data_in.secondary_dim = numObjects;
    data_in.members = temp_members;

    char *file1_0 = "centroids.bin";
    char *file1_1 = "ClusterSize.bin";
    char *file2_0 = "dataset.bin";
    char *file2_1 = "Index.bin"; 

    save(&clusters, file1_0, file1_1);
    save(&data_in, file2_0, file2_1);
    
  }

  /*============clean memory===========*/
  clean(&data_in);
  clean(&clusters);

  MPI_Finalize();
}
