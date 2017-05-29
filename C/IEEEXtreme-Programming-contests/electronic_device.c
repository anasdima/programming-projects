#include <stdio.h>
#include <stdlib.h>

int partition( int a[], int l, int r) {
   int pivot, i, j, t;
   pivot = a[l];
   i = l; j = r+1;
        
   while( 1)
   {
    do ++i; while( a[i] <= pivot && i <= r );
    do --j; while( a[j] > pivot );
    if( i >= j ) break;
    t = a[i]; a[i] = a[j]; a[j] = t;
   }
   t = a[l]; a[l] = a[j]; a[j] = t;
   return j;
}

void quickSort( int a[], int l, int r)
{
   int j;

   if( l < r ) 
   {
    // divide and conquer
        j = partition( a, l, r);
       quickSort( a, l, j-1);
       quickSort( a, j+1, r);
   }
    
}

int main() {

    int N,M,K;

    scanf("%d %d %d",&N,&M,&K);

    int *numbers = (int *) malloc(N*sizeof(int));

    for(int i=0;i<N;i++) {

        scanf("%d",&numbers[i]);
    }

    int mins[M];
    int leaving_index = 0, inc_index = 0, next_index = 0, leaving_index_in_mins = 0;
    int K_value;

    for(int i=0;i<M;i++) {

        mins[i] = numbers[i];
    }
    for(int i=(M-1);i=0;i--) {
        
        if(numbers[i] == mins[K]) {

            next_index = i;
            break;
        }
    }

    for(int i=(M-1);i=0;i--) {
        
        if(mins[i] == numbers[M-1]) {

            leaving_index_in_mins = i;
            break;

        }
    }

    quickSort(mins,0,M-1);

    leaving_index = 0;
    inc_index = M;
    K_value = mins[K-1];

    for(int i=0;i<N;i++) { 
    
        if(numbers[inc_index] < mins[K-1]) {

            if(numbers[leaving_index] < mins[K-1]) {

                mins[leaving_index_in_mins] = numbers[inc_index];
            }
            else if (numbers[leaving_index] > mins[K-1]) {

                mins[K] = numbers[inc_index];
                quickSort(mins,0,M-1);
            }
            else {

                mins[K-1] = numbers[inc_index];
                quickSort(mins,0,M-1);
            }
        }
        else if(numbers[inc_index] > mins[K-1]) {

            if(numbers[leaving_index] <= mins[K-1]) {

                if(numbers[inc_index] >= mins[K]) {

                    mins[leaving_index_in_mins] = mins[K];
                    mins[K] = numbers[inc_index];
                    quickSort(mins,0,M-1);
                }
                else {

                    mins[leaving_index_in_mins] = numbers[inc_index];
                    quickSort(mins,0,M-1);

                }
            }
        }
        else {

            if(numbers[leaving_index] < mins[K-1]) {

                mins[leaving_index_in_mins] = numbers[inc_index];
            }
        }

        for(int i=(M-1);i=0;i--) {
            
            if(mins[i] == numbers[leaving_index+1]) {

                leaving_index_in_mins = i;
                break;
            }
        }

        leaving_index++;
        if(inc_index+1 >= N) {

            inc_index = 0;

        }
        else {

            inc_index++;
        }

        if(K_value < mins[K-1]) {

            K_value = mins[K-1];
        }
    }
    printf("%d",K_value);

}