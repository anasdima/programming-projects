#include <stdio.h>
#include <math.h>

int main() {

	int N;
	scanf("%d",&N);

	int *legs = (int *) malloc(N*sizeof(int));

	for(int i=0;i<N;i++) {

		scanf("%d %d", &legs[i*2],&legs[i*2+1]);
	}

}