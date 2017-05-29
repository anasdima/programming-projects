#include <sys/times.h>
#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main (int argc, char *argv[])
{
	int pid,status,pd[2];
	struct timeval tv_start;

	// printf("No. of clock ticks per sec : %ld\n",sysconf(_SC_CLK_TCK)); // Get the number of clock ticks per second in current system

	if (pipe(pd) < 0) error("can't open pipe");

	pid = fork();

	if (pid == 0) {
		close(pd[0]);
		gettimeofday(&tv_start, NULL);
		write(pd[1],&tv_start,sizeof(tv_start));
		close(pd[1]);
		system(argv[1]);
		exit(0);
	}
	else {
		struct timeval tv_end;
		struct tms cpu_time;

		close(pd[1]);

		while (!(read(pd[0],&tv_start,sizeof(tv_start))));
		wait(&status);

		gettimeofday(&tv_end, NULL);
		printf("%d\n",tv_start.tv_usec);
		printf("%d\n",tv_end.tv_usec);
		if(tv_start.tv_usec>tv_end.tv_usec){
      		tv_end.tv_usec += 1000000;
      		tv_end.tv_sec--;
    	}
		times(&cpu_time);
		printf("Real time elapsed: %d.%06ds\n",tv_end.tv_sec-tv_start.tv_sec,tv_end.tv_usec-tv_start.tv_usec);
		printf("user time (child): %ld\nsystem time (child): %ld\n", cpu_time.tms_cutime, cpu_time.tms_cstime);
	}
}