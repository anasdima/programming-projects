#include <stdio.h>
#include <stdlib.h>

int main () {

	int N = 0;
	scanf("%d",&N);

	int *grid;
	grid = (int *) malloc(N*N*sizeof(int));
	// for(int i=0;i<(N*N);i++) {

	// 	scanf("%d", &grid[i]);

	// }
	int min = 0, min_index[2*N];
	int sum = 0;

	//For each column
	for(int i=0;i<N;i++) {

		//For each row
		for(int j=0;j<N;j++) {

			min = grid[i*N+j] + grid[(i+1)*N+j];
			sum = grid[i*N+j];

			for(int k=(j+1);k<N;k++) {

				sum += grid[i*N+k];
				if (sum > min) {

					break;
				}

				sum += grid[(i+1)*N+k];

				if(sum < min) {

					min = sum;
					min_index[i*2] = j;
					min_index[i*2+1] = k; 
				}
				sum -= grid[(i+1)*N+k];
			}

		}
	}
}