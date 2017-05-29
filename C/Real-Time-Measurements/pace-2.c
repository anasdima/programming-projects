/*
  Multiple Change Detector
  RTES 2015

  Nikos P. Pitsianis 
  AUTh 2015
 */

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/time.h>
#include <time.h>
#include <assert.h>

volatile int *signalArray;
struct timeval *readTimeStamp,*detectTimeStamp;
int N,NTHREADS,alarm_seconds;
volatile int readSum,detectedSum,changedSignal;
pthread_mutex_t changedSignal_mtx;

void exitfunc(int sig)
{

  int i,usecRead,usecDetect,detectionSpeed;
  int inTimeDetections = 0;
  struct timeval tv;
  
  for(i=0;i<detectedSum;i++) { // detectedSum should always be <= readSum
    usecRead   = readTimeStamp[i].tv_usec;
    usecDetect = detectTimeStamp[i].tv_usec;
    detectionSpeed = usecDetect-usecRead;
    if (detectionSpeed <= 1) {
      inTimeDetections++;
    }
  }

  char buf[200];
  snprintf(buf, sizeof(buf), "Results/Statistics-%d-%d.txt",NTHREADS,alarm_seconds);
  FILE *f = fopen(buf, "a");
  if (f == NULL)
  {
      printf("Error opening file!\n");
      exit(1);
  }

  fprintf(f,"%d,%d,%d,%.2f,%.2f\n",N,readSum,detectedSum,((float)detectedSum/(float)readSum)*100
    ,((float)inTimeDetections/(float)detectedSum)*100);
  fclose(f);
  fflush(stdout);
  printf("%d-%d-%d\n",N,NTHREADS,alarm_seconds);
  _exit(0);
}

void *SensorSignalReader (void *args);
void *ChangeDetector (void *args);

int main(int argc, char **argv)
{

  if (argc != 4) {
    printf("Usage: %s N NTHREADS s\n"
           " where\n"
           " N           : number of signals to monitor\n"
           " NTHREADS    : number of threads\n"
           " s           : number of seconds to run\n"
     , argv[0]);
    
    return (1);
  }

  N         = atoi(argv[1]);
  NTHREADS  = atoi(argv[2]);
  alarm_seconds = atoi(argv[3]);

  int i,rc;
  
  // set a timed signal to terminate the program
  signal(SIGALRM, exitfunc);
  alarm(alarm_seconds);

  // Allocate signal, time-stamp arrays and thread handles
  signalArray     = (int *) malloc(N*sizeof(int));
  // worst case is that we have a signal change every
  // 10 seconds. So we alocate for each second 10 times.
  detectTimeStamp  = (struct timeval *) malloc(NTHREADS*10*alarm_seconds*sizeof(struct timeval));
  readTimeStamp    = (struct timeval *) malloc(NTHREADS*10*alarm_seconds*sizeof(struct timeval));

  for (i=0; i<N; i++) {
    signalArray[i] = 0;
  }

  pthread_t sigGen;
  pthread_t sigDet;
  pthread_mutex_init(&changedSignal_mtx,NULL);

  readSum = 0;
  detectedSum = 0;
  changedSignal = -1;

  for(i=0;i<NTHREADS;i++) {
    rc = pthread_create (&sigDet, NULL, ChangeDetector, NULL);
    assert(rc == 0);
  }

  pthread_create (&sigGen, NULL, SensorSignalReader, NULL);
  
  // wait here until the signal 
  pthread_join (sigDet, NULL);

  return 0;
}


void *SensorSignalReader (void *arg)
{
  struct timeval tv;

  srand(time(NULL));

  while (1) {
    int t = rand() % 10 + 1; // wait up to 1 sec in 10ths
    usleep(t*100000);

    int r = rand() % N;
    signalArray[r] ^= 1; 

    if (signalArray[r]) { 
      gettimeofday(&tv, NULL);
      changedSignal = r;
      readTimeStamp[readSum] = tv;
      readSum++;
    }
  }
}

void *ChangeDetector (void *arg)
{

  struct timeval tv;

  while (1) {
    pthread_mutex_lock(&changedSignal_mtx);
    while (changedSignal == -1) {}
    gettimeofday(&tv, NULL);
    changedSignal = -1;
    pthread_mutex_unlock(&changedSignal_mtx);
    detectTimeStamp[detectedSum] = tv;
    detectedSum++;
  }
}

