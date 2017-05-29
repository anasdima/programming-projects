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

typedef struct {
  int workload_delimeter;
  int tid;
}arguments_struct;

arguments_struct *ChangeDetectorArgs;
volatile int *signalArray, *signalPrevState;
struct timeval *readTimeStamp,*detectTimeStamp;
int N,NTHREADS,alarm_seconds;
volatile int readSum,detectedSum;
pthread_mutex_t detectedSum_mtx;

void exitfunc(int sig)
{

  int i,usecRead,usecDetect,detectionSpeed;
  int inTimeDetections = 0;
  struct timeval tv;
  
  for(i=0;i<detectedSum;i++) { // detectedSum should always be <= readSum
    usecRead   = readTimeStamp[i].tv_usec;
    usecDetect = detectTimeStamp[i].tv_usec;
    detectionSpeed = usecDetect-usecRead;
    printf("%d\n",detectionSpeed);
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

  int i,j,rc;
  ChangeDetectorArgs = malloc(NTHREADS*sizeof(arguments_struct));
  
  // set a timed signal to terminate the program
  signal(SIGALRM, exitfunc);
  alarm(alarm_seconds);

  // Allocate signal, time-stamp arrays and thread handles
  signalArray     = (int *) malloc(N*sizeof(int));
  signalPrevState = (int *) malloc(N*sizeof(int));
  // worst case is that we have a signal change every
  // 10 seconds. So we alocate for each second 10 times.
  detectTimeStamp  = (struct timeval *) malloc(NTHREADS*10*alarm_seconds*sizeof(struct timeval));
  readTimeStamp    = (struct timeval *) malloc(NTHREADS*10*alarm_seconds*sizeof(struct timeval));

  for (i=0; i<N; i++) {
    signalArray[i] = 0;
  }
  for (i=0; i<N; i++) {
    signalPrevState[i] = 0;
  }

  pthread_t sigGen;
  pthread_t sigDet;
  pthread_mutex_init(&detectedSum_mtx,NULL);

  for(i=0;i<NTHREADS;i++) {
    ChangeDetectorArgs[i].workload_delimeter = i*(N/NTHREADS);
    ChangeDetectorArgs[i].tid = i + 1;
  }
  readSum = 0;
  detectedSum = 0;

  for(i=0;i<NTHREADS;i++) {
    rc = pthread_create (&sigDet, NULL, ChangeDetector, (void *) &ChangeDetectorArgs[i]);
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
      readTimeStamp[readSum] = tv;
      readSum++;
    }
  }
}

void *ChangeDetector (void *arg)
{
  struct timeval tv;
  int r;

  int tid               = ((arguments_struct *) arg)->tid;
  int delimeter_low     = ((arguments_struct *) arg)->workload_delimeter;
  int delimeter_high    = delimeter_low + N/NTHREADS - 1 + (tid/NTHREADS)*(N%NTHREADS);
  // (tid/NTHREADS)*(N%NTHREADS) means the last thread gets the remaining workload if N is not a multiple of NTHREADS

  while (1) {
    for(r=delimeter_low;r<=delimeter_high;r++) {
      if (signalArray[r]) {
        gettimeofday(&tv, NULL);
        if (!signalPrevState[r]) {   
          // pthread_mutex_lock(&detectedSum_mtx);
          detectTimeStamp[detectedSum] = tv;
          detectedSum++;
          // pthread_mutex_unlock(&detectedSum_mtx);
          signalPrevState[r] ^= 1;
        }
      }
      else if (signalPrevState[r]) {
        signalPrevState[r] ^= 1;
      }
    }
  }
}

