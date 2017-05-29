#include "kmeans.h"
#include "mpi_gather.h"
#include <float.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>
#include <time.h>
#include <sys/time.h>

#define threshold 0.001
//double threshold = 0.01;

double euclidean_distance(double *v1, double *v2, int length){

  int i = 0;
  double dist = 0;

  for(i=0; i<length; i++){
    dist += (v1[i] - v2[i])*(v1[i] - v2[i]); 
  }

  return(dist);
}


void kmeans_process(data_struct *data_in, data_struct *clusters, collector_struct *gathers, double *newCentroids, double* SumOfDist){

  int i, j, k;
  double tmp_dist = 0;
  int tmp_index = 0;
  double min_dist = 0;
  double *dataset = data_in->dataset;
  double *centroids = clusters->dataset;
  unsigned int *Index = data_in->members;
  unsigned int *cluster_size = clusters->members;

  int world_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
  int world_size;
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  /* Variables that store collected data from tasks */

  double *recvCentroids = gathers->centroids;
  double *recvSumOfDist = gathers->SumOfDist;
  int *recvcluster_size = gathers->cluster_size;

  //SumOfDist[0] = 0;

  for(i=0; i<clusters->secondary_dim; i++){
    cluster_size[i] = 0;
  }

  for(i=0; i<data_in->secondary_dim; i++){
    tmp_dist = 0;
    tmp_index = 0;
    min_dist = FLT_MAX;
    /*find nearest center*/
    for(k=0; k<clusters->secondary_dim; k++){

      tmp_dist = euclidean_distance(dataset+i*data_in->leading_dim, centroids+k*clusters->leading_dim, data_in->leading_dim);
        
      if(tmp_dist<min_dist){

  	     min_dist = tmp_dist;
  	     tmp_index = k;
      }
    }
     
    Index[i] = tmp_index;
    SumOfDist[0] += min_dist;
    cluster_size[tmp_index]++;
    for(j=0; j<data_in->leading_dim; j++){
      newCentroids[tmp_index * clusters->leading_dim + j] += dataset[i * data_in->leading_dim + j]; 
    }    
  }

  /* Gather the new centroids and the sum of distances of each process to the root process */

  MPI_Allgather(newCentroids, (clusters->leading_dim)*(clusters->secondary_dim), MPI_DOUBLE,
            recvCentroids, (clusters->leading_dim)*(clusters->secondary_dim), MPI_DOUBLE, MPI_COMM_WORLD);
  MPI_Allgather(cluster_size, clusters->secondary_dim, MPI_INT, recvcluster_size, clusters->secondary_dim, MPI_INT, MPI_COMM_WORLD);
  MPI_Gather(SumOfDist, 1, MPI_DOUBLE, recvSumOfDist, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  for(k=0;k<clusters->secondary_dim;k++) {  // For each cluster

    for(j=0;j<clusters->leading_dim;j++) {  // For each dimension

      for(i=0;i<world_size;i++) {           // For each task

        if(world_rank!=i) { // This process's data are already calculated

          newCentroids[(k * clusters->leading_dim + j)] += recvCentroids[(k * clusters->leading_dim +j) + i*clusters->leading_dim*clusters->secondary_dim];

        }
      }
    }
  }

  for(j=0;j<clusters->secondary_dim;j++) {

    for(i=0;i<world_size;i++) {

      if (world_rank!=i) { // This process's data are already calculated

        cluster_size[j] += recvcluster_size[j + i*clusters->secondary_dim];

      }   
    }
  }

  /*update cluster centers*/
  for(k=0; k<clusters->secondary_dim; k++){
    for(j=0; j<data_in->leading_dim; j++){

      centroids[k * clusters->leading_dim + j] = newCentroids[k * clusters->leading_dim + j] / (double) cluster_size[k];

    }
  }

  if (world_rank == 0) {
    for(i=0;i<world_size;i++) {

      if (world_rank!=i) { // This process's data are already calculated

        SumOfDist[0] += recvSumOfDist[i];

      }
    }
  }
  
}

void cluster(data_struct *data_in, data_struct *clusters, collector_struct *gathers, int max_iterations){ 

  int world_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

  int iter=0, i, j,bcast_msg=1;
  double SumOfDist = 0, new_SumOfDist = 0;
  double* newCentroids;

  newCentroids = (double*)malloc(clusters->leading_dim*clusters->secondary_dim*sizeof(double));

  if(world_rank == 0) {

    for(iter=0;iter<max_iterations;iter++) {

      for(i=0; i<clusters->secondary_dim; i++){
        for(j=0; j<clusters->leading_dim; j++){
          newCentroids[i * clusters->leading_dim + j] = 0;
        }
      }

      new_SumOfDist = 0;

      kmeans_process(data_in, clusters, gathers, newCentroids, &new_SumOfDist);

      if(fabs(SumOfDist - new_SumOfDist)<threshold){

        bcast_msg = 0;
        MPI_Bcast(&bcast_msg, 1, MPI_INT, 0, MPI_COMM_WORLD);
        break;

      }

      SumOfDist = new_SumOfDist;

      if (iter == max_iterations-1) {

        bcast_msg = 0;
        MPI_Bcast(&bcast_msg, 1, MPI_INT, 0, MPI_COMM_WORLD);

      }
      else {

        bcast_msg = 1;
        MPI_Bcast(&bcast_msg, 1, MPI_INT, 0, MPI_COMM_WORLD);

      }
    }
  }
  else {

    while (bcast_msg != 0) {

      for(i=0; i<clusters->secondary_dim; i++){
        for(j=0; j<clusters->leading_dim; j++){
          newCentroids[i * clusters->leading_dim + j] = 0;
        }
      }

      new_SumOfDist = 0;

      kmeans_process(data_in, clusters, gathers, newCentroids, &new_SumOfDist);

      MPI_Bcast(&bcast_msg, 1, MPI_INT, 0, MPI_COMM_WORLD);

    }
  }

  if (world_rank == 0) {

    printf("Finished after %d iterations\n", iter);
    printf("SumOfDist=%f\n",SumOfDist);
    
  }

  free(newCentroids);

}




