#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>
#include <unistd.h>

int isomporhism(int **adj_1,int **adj_2,int *v_rank_1,int *v_rank_2, int *v_index_1, int *v_index_2, int n);
int compare(const void * a, const void * b);
int ranks_compare(const void *a, const void *b);

int *comparator;

int main () {

  struct timeval first, second, third, fourth, lapsed;
  struct timezone tzp;

  gettimeofday(&first, &tzp);

	FILE* file = fopen ("input.txt", "r");
	int i=0;
	int j=0;
	int k=0;
  int l=0;
  // bulk read file into memory
  fseek(file, 0, SEEK_END);
  long fsize = ftell(file);
  fseek(file, 0, SEEK_SET);
  fscanf (file, "%d", &i); // read number of vertices from the first line as int
  int n = i;
  char *memFile = malloc(fsize + 1);
  if (memFile == NULL) return; // not enough memory
  fread(memFile, fsize, 1, file);
  fclose(file);
  memFile[fsize] = 0;
 
	int *v_rank_1,*v_rank_2, *v_index_1, *v_index_2, **adj_1, **adj_2;
  int max_rank_1 = 0;
  int max_rank_2 = 0;

  comparator = (int *) malloc(n*sizeof(int));
	v_rank_1 = (int *) malloc(n*sizeof(int));
	v_rank_2 = (int *) malloc(n*sizeof(int));
  v_index_1 = (int *) malloc(n*sizeof(int));
  v_index_2 = (int *) malloc(n*sizeof(int));
  adj_1 = (int *) malloc(n*sizeof(*adj_1));
  adj_2 = (int *) malloc(n*sizeof(*adj_2));
  if (adj_1 == NULL || adj_2 == NULL) {
    fprintf (stderr, "Couldn't allocate memory\n");
    exit(0);
  }
  else {
    for (k = 0; k < n; k++) {
      adj_1[k] = (int *) malloc(n*sizeof(**adj_1));
      adj_2[k] = (int *) malloc(n*sizeof(**adj_2));
      if (adj_1[k] == NULL || adj_2[k] == NULL) {
        fprintf (stderr, "Couldn't allocate memory\n");
        exit(0);
      }
      memset(adj_1[k],-1,n*sizeof(int));
      memset(adj_2[k],-1,n*sizeof(int));
    }
  }
	memset(v_rank_1,0,n*sizeof(v_rank_1));
	memset(v_rank_2,0,n*sizeof(v_rank_1));
  for (k=0;k<n;k++) {
    v_index_1[k] = k;
    v_index_2[k] = k;
  }

  k=0;
  l=0;
  j=0;

  int lig, col;
  char *mem = memFile, c;
  for (lig = 0; lig < n; lig++) { // first graph
    for (col = 0; col < n; col++) {
      for (;;) {
        c = *mem;
        if (c == 0) break;
        mem++;
        if (c == '1') {
          adj_1[lig][v_rank_1[lig]++] = col; // add the vertice to the adjacents of the current vertice   
          break;
        }
        if (c == '0') break;
      }
    }
  }
  for (lig = 0; lig < n; lig++) { // second graph
    for (col = 0; col < n; col++) {
      for(;;) {
        c = *mem;
        if (c == 0) break;
        mem++;
        if (c == '1') {
          adj_2[lig][v_rank_2[lig]++] = col; // add the vertice to the adjacents of the current vertice
          break;
        }
        if (c == '0') break;
      } 
    }
  }
  free(memFile);

  gettimeofday(&second, &tzp);

  if(first.tv_usec>second.tv_usec){
    second.tv_usec += 1000000;
    second.tv_sec--;
  }
  
  lapsed.tv_usec = second.tv_usec - first.tv_usec;
  lapsed.tv_sec = second.tv_sec - first.tv_sec;

  printf("Reading from file took: %d, %d s\n", lapsed.tv_sec, lapsed.tv_usec);

  int im;

  im = isomporhism(adj_1,adj_2,v_rank_1,v_rank_2,v_index_1,v_index_2,n);

  gettimeofday(&third, &tzp);

  if(second.tv_usec>third.tv_usec){
    third.tv_usec += 1000000;
    third.tv_sec--;
  }
  
  lapsed.tv_usec = third.tv_usec - second.tv_usec;
  lapsed.tv_sec = third.tv_sec - second.tv_sec;

  printf("Isomoprhism took: %d, %d s\n", lapsed.tv_sec, lapsed.tv_usec);

  gettimeofday(&fourth, &tzp);

  if(first.tv_usec>fourth.tv_usec){
    fourth.tv_usec += 1000000;
    fourth.tv_sec--;
  }
  
  lapsed.tv_usec = fourth.tv_usec - first.tv_usec;
  lapsed.tv_sec = fourth.tv_sec - first.tv_sec;

  printf("Total Time Elapsed: %d, %d s\n", lapsed.tv_sec, lapsed.tv_usec);

  if (im == 1) {
    printf("Graphs isomorphic.\n");
    printf("Isomorphism:\n[ ");
    for(i=0;i<n;i++) {
      printf("%d ",v_index_1[i]+1);
    }
    printf("]\n[ ");
    for(i=0;i<n;i++) {
      printf("%d ",v_index_2[i]+1);
    }
    printf("]\n");
  }
  else {
    printf("Graphs not isomorphic\n");
  }
}

int isomporhism(int **adj_1,int **adj_2,int *v_rank_1,int *v_rank_2, int *v_index_1, int *v_index_2, int n) {

  int i,j,k,l,count=0;
  for(i=0;i<n;i++) {
    for(j=0;j<v_rank_1[i];j++) {
      adj_1[i][j] = v_rank_1[adj_1[i][j]]; //replace adjacent vertice indexes with adjacent vertice ranks
    }
    for(j=0;j<v_rank_2[i];j++) {
      adj_2[i][j] = v_rank_2[adj_2[i][j]]; //replace adjacent vertice indexes with adjacent vertice ranks
    } 
    qsort(adj_1[i],v_rank_1[i],sizeof(int),compare); // sort only the first v_rank[i] items in descending order (the rest are "-1")
    qsort(adj_2[i],v_rank_2[i],sizeof(int),compare); // sort only the first v_rank[i] items in descending order (the rest are "-1")
  }

  int *cmp_container_1, *cmp_container_2;
  cmp_container_1 = (int *) malloc(n*sizeof(int));
  cmp_container_2 = (int *) malloc(n*sizeof(int));

  memcpy(comparator,v_rank_1,n*sizeof(int));    // load the ranks of graph 1 in the comperator
  qsort(v_index_1,n,sizeof(int),ranks_compare); // Sort the indexes of graph 1 based on the ranks of graph 1 using the comperator
  memcpy(comparator,v_rank_2,n*sizeof(int));    // load the ranks of graph 2 in the comperator
  qsort(v_index_2,n,sizeof(int),ranks_compare); // Sort the indexes of graph 2 based on the ranks of graph 2 using the comperator

  for(i=0;i<n;i++) {
    cmp_container_1[i] = v_rank_1[v_index_1[i]];
    cmp_container_2[i] = v_rank_2[v_index_2[i]];
  }
  if (memcmp(cmp_container_1,cmp_container_2,n*sizeof(int)) == 0) { // Here we check if the series of vertices ranks is the same between graphs
    count++;
  }
  else { // If they aren't, graphs are not isomorphic
    return 0;
  }

  int *delimeters, *actual_discrete_ranks;
  delimeters = (int *) malloc((n+1)*sizeof(int)); // n+1 for zero padding
  actual_discrete_ranks = (int *) malloc((n+1)*sizeof(int));
  memset(delimeters,0,(n+1)*sizeof(int));
  memset(actual_discrete_ranks,-1,(n+1)*sizeof(int));
  delimeters[0] = -1;
  actual_discrete_ranks[1] = v_rank_1[v_index_1[0]]; // v_index is sorted by rank, so we assign the first and the highest rank as the current rank
  delimeters[1] += 1;
  int discrete_ranks = 1;
  // delimeters point to the last position of a region
  for(i=1;i<n;i++) {
    if(actual_discrete_ranks[discrete_ranks] == v_rank_1[v_index_1[i]]) {
      delimeters[discrete_ranks]++;
    }
    else {
      discrete_ranks++;
      delimeters[discrete_ranks] = delimeters[discrete_ranks-1];
      delimeters[discrete_ranks-1]--;
      actual_discrete_ranks[discrete_ranks] = v_rank_1[v_index_1[i]];  
    }
  }
  if (discrete_ranks == 1) {
    delimeters[discrete_ranks]--;
  }

  int comparison_tries,equal,current_rank_1,current_rank_2,discrete_ranks_1,discrete_ranks_2,start;
  int *rank_column_1,*rank_column_2,*previous_rank_column_1,*previous_rank_column_2,*delimeters_1,*delimeters_2,*temp_column;
  rank_column_1 = (int *) malloc(n*sizeof(int));
  rank_column_2 = (int *) malloc(n*sizeof(int));
  delimeters_1 = (int *) malloc(n*sizeof(int));
  delimeters_2 = (int *) malloc(n*sizeof(int));
  previous_rank_column_1 = (int *) malloc(n*sizeof(int));
  previous_rank_column_2 = (int *) malloc(n*sizeof(int));
  temp_column = (int *) malloc(n*sizeof(int));
  for(i=1;i<(discrete_ranks+1);i++) { // i=1 and discrete_ranks+1 because of the zero padding in the delimeters
    comparison_tries = 0;
    while(comparison_tries<(actual_discrete_ranks[i]+1)) {
      equal = 1;
      memset(previous_rank_column_1,-1,n*sizeof(int));
      memset(previous_rank_column_2,-1,n*sizeof(int));
      if((comparison_tries > 0) && (comparison_tries != actual_discrete_ranks[i])) { // not the first and not the last try
        // store the previous "column of ranks" so we can sort based on that if need be
        for(j=0;j<n;j++) {
          previous_rank_column_1[j] = rank_column_1[j];
        }
        for(j=0;j<n;j++) {
          previous_rank_column_2[j] = rank_column_2[j];
        }
      }
      l=0;
      for(j=(delimeters[i-1]+1);j<(delimeters[i]+1);j++) {
        cmp_container_1 = adj_1[v_index_1[j]];
        cmp_container_2 = adj_2[v_index_2[j]];
        rank_column_1[l] = adj_1[v_index_1[j]][comparison_tries]; // if this is the last try this doesn't help in anything
        rank_column_2[l] = adj_2[v_index_2[j]][comparison_tries];
        l++;
        // we should remind here that v_rank_1[v_index_1[temp_index]] == v_rank_2[v_index_2[temp_index]],
        // since the indexes are sorted by rank and the graphs have the same sequence of ranks
        if(equal == 1) {
          if(memcmp(cmp_container_1,cmp_container_2,actual_discrete_ranks[i]*sizeof(int)) != 0) {
            equal = 0;
          }
        }
      }
      if(equal == 0) {
        if(comparison_tries == 0) { // first "column", so sort all the elements of the current discrete rank
          if(memcmp(rank_column_1,rank_column_2,(delimeters[i]-delimeters[i-1])*sizeof(int)) !=0) { // if columns are equal, no need for sorting
            for(k=0;k<n;k++) { // first graph
              comparator[k] = adj_1[k][comparison_tries];
            }             
            qsort(v_index_1+delimeters[i-1],delimeters[i]-delimeters[i-1],sizeof(int),ranks_compare);
            for(k=0;k<n;k++) { // second graph
              comparator[k] = adj_2[k][comparison_tries];
            } 
            qsort(v_index_2+delimeters[i-1],delimeters[i]-delimeters[i-1],sizeof(int),ranks_compare);
          }
        }
        else if (comparison_tries != actual_discrete_ranks[i]) { // not the first or the last "column", so sort the elements based on the elements of the previous column
          memset(delimeters_1,0,n*sizeof(int));
          memset(delimeters_2,0,n*sizeof(int));
          discrete_ranks_1 = 1;
          discrete_ranks_2 = 1;
          delimeters_1[0] += 1;
          delimeters_2[0] += 1;
          current_rank_1 = previous_rank_column_1[0];
          current_rank_2 = previous_rank_column_2[0];
          
          // find the discrete ranks in this column
          for(j=1;j<(delimeters[i]-delimeters[i-1]);j++) {
            if(current_rank_1 == previous_rank_column_1[j]) {
              delimeters_1[discrete_ranks_1-1]++;
            }
            else {
              delimeters_1[discrete_ranks_1]++;
              discrete_ranks_1++;
              current_rank_1 = previous_rank_column_1[j];
            }
            if(current_rank_2 == previous_rank_column_2[j]) {
              delimeters_2[discrete_ranks_2-1]++;
            }
            else {
              delimeters_2[discrete_ranks_2]++;
              discrete_ranks_2++;
              current_rank_2 = previous_rank_column_2[j];
            }
          }

          // sort the vertices of the two graphs in the scope of the ranks of the previous column
          for(k=0;k<n;k++) { // first graph
            comparator[k] = adj_1[k][comparison_tries];
          }
          start = 0;
          j=0;
          while (j<discrete_ranks_1) {
            qsort(v_index_1+delimeters[i-1]+1+start,delimeters_1[j],sizeof(int),ranks_compare);
            start += delimeters_1[j];
            j++;
          }
          for(k=0;k<n;k++) { // second graph
            comparator[k] = adj_2[k][comparison_tries];
          }
          start = 0;
          j=0;
          while (j<discrete_ranks_2) {
            qsort(v_index_2+delimeters[i-1]+1+start,delimeters_2[j],sizeof(int),ranks_compare);
            start += delimeters_2[j];
            j++;
          }
        }    
      }
      else { // this segment was isomorphic
        count++;
        break;
      }
      comparison_tries++;
    }
  }

  if (count == discrete_ranks+1) {
    return 1;
  }
  else {
    return 0;
  }
}

int compare (const void * a, const void * b)
{
  return (*(int*)b - *(int*)a);
}

int ranks_compare(const void *a, const void *b) {
  int index_1 = *(int*)a;
  int index_2 = *(int*)b;
  return comparator[index_2] - comparator[index_1];
}