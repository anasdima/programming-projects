#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void calk(int AA,float x[],float y[], float p[],int N,float minp,float *elegxosA,float *MeshTimh) { //AA auxontas arithmos//
    float d,w,Sum;
    int i;
    *elegxosA=N;
    Sum=0;
   for (i=0;i<N;i++) {
        d=fabs(sqrt(pow(x[i],2)+pow(y[i],2))-sqrt(pow(x[AA],2)+pow(y[AA],2)));
        if (d==0){
            w=0;
        }
        else {
            w=p[i]/(d*d);
        }
        if (w<minp){
            *elegxosA=N--;
        }
        else {
            Sum+=w;
        }

    }
    *MeshTimh=Sum/(*elegxosA);
}
int main () {
    int N,i,StathmosBashs,StathmoiB;//Opou Stathmoi B oi Stathmoi Bashs pou ikanpoioun to krithrio B//
    float *x,*y,*p,*MeshTimh,minp,max1,max2,*elegxosA;//Opou elegxos A oi pylwnes pou ikanpoioun to krithria A//
    printf ("Eisagete ton arithmo ton pylwnwn: ");
    scanf ("%d",&N);
    printf ("Eisagete ti elaxisth isxy shmatos, bash ton prodiagrafwn tou stathmou: ");
    scanf ("%f",&minp);
    x=(float*)malloc(N*sizeof(float));
    y=(float*)malloc(N*sizeof(float));
    p=(float*)malloc(N*sizeof(float));
    MeshTimh=(float*)malloc(N*sizeof(float));
    elegxosA=(float*)malloc(N*sizeof(float));
    if ((x==NULL) || (y==NULL) || (p==NULL) || (MeshTimh==NULL) || (elegxosA==NULL)) {
        printf ("Memory could not be allocated, please reinitialize the program\n");
        return EXIT_FAILURE;
    }
    else {
        for (i=0;i<N;i++){
            printf ("Dwste tis syntetagmenes tou %dou pylwna\nx:",i+1);
            scanf ("%f",&x[i]);
            printf ("y:");
            scanf ("%f",&y[i]);
            printf ("Dwste tin isxy tou %dou pylwna\np:",i+1);
            scanf ("%f",&p[i]);
        }
    }
    for (i=0;i<N;i++){
        calk (i,x,y,p,N,minp,&elegxosA[i],&MeshTimh[i]);
    }
    max1=elegxosA[0];
    StathmoiB=1;
    for (i=1;i<N;i++){
        if (elegxosA[i]=max1){
            StathmoiB++;
            StathmosBashs=i;
        }
        else if (elegxosA[i]>max1){
            max1=elegxosA[i];
        }
    }
    if (StathmoiB>1){
        max2=MeshTimh[0];
        for (i=0;i<N;i++){
            if (MeshTimh[i]>max2){
                MeshTimh[i]=max2;
                StathmosBashs=i;
            }
        }
    }
    printf ("O pylwnas pou prepei na egatastathei me stathmo vashs einai autos me syntetagmenes\nx:%f\ny:%f",x[StathmosBashs],y[StathmosBashs]);
}


