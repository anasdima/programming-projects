#include <stdio.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>
#include <float.h>

#define SIZE 14641

int main () {

	struct timeval first, second, lapsed;
	//struct timezone tzp;

	gettimeofday(&first, NULL);

	int primes[10002];
	primes[0] = 2;
	primes[1] = 3;

	int prime_count = 2;
	int number = 4;
	int not_divisible_count = 0;
	int i = 0;

	while(prime_count < 10002) {

		while(primes[i] <= sqrt(number)) {

			if(number%primes[i] == 0) {
				i++;
				break;
			}
			else {
				not_divisible_count++;
			}

			i++;
		}

		if(not_divisible_count == i) {

			primes[prime_count] = number;
			prime_count++;
		}

		not_divisible_count = 0;
		number++;
		i = 0;

	}

	printf("Found %d primes\n", prime_count-2);
	printf("Last prime: %d\n", primes[prime_count-1]);

	gettimeofday(&second, NULL);

	if(first.tv_usec>second.tv_usec){
		second.tv_usec += 1000000;
		second.tv_sec--;
	}
  
	lapsed.tv_usec = second.tv_usec - first.tv_usec;
	lapsed.tv_sec = second.tv_sec - first.tv_sec;

	printf("Time elapsed: %d, %d s\n", lapsed.tv_sec, lapsed.tv_usec);

}