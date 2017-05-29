#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <math.h>
//Stin synarthsh find_pair, h logikh einai h exhs:
//1.Fantazomaste oti ola ta pithana zeugaria ton radiofarwn sxhmatizoun
//  enan disdiastato pinaka. Ta zeugaria tis kyria diagwniou apoteloun zeugaria radiofarou me ton eauto tou, ara den mas endiaferoun.
//  Ta zeugaria panw kai katw apo tin kyria diagwnio einai idia, ara lambanoume ypopsh (tyxaia) mono ta panw. Etsi dikaiologeitai h
//  if stin grammi 24.
//2.Metakinoume tis syntetagmenes twn pylwnwn pou vrikame stis prwtes theseis tis mnhmhs pou kaname allocate, pragma pou apaiteitai
// wste to bhma 4 na ginei swsta
//3.Twra otan teleiwsei o elegxos meiwnoume ton pointer pou deixnei sto plithos ton radiofaron kata 2, afou 2 rafiofaroi prokeitai
//  na "aferaithoun" apo ton "pinaka".
//4.Stin join:Afou kanoume kati san elegxo peritothtas oso anafora to plithos ton radiofarwn, auxanoume tous pointer x
//kai y kata 2 wste na deixnoun meta apo dyo theseis mnhmhs (dhladh petame tis syntetagmenes pou molis brhkame)


void find_pair (int *N, float *x, float *y){
    float d,min,temp;
    int i,j;
    min=fabs(sqrt((x[0]*x[0])+(y[0]*y[0]))-sqrt((x[1]*x[1])+(y[1]*y[1])));
    for (i=0;i<(*N);i++){
        for (j=2;j<(*N);j++){
            if ((j!=i) && (j>i)){ //1.
                d=fabs(sqrt((x[i]*x[i])+(y[i]*y[i]))-sqrt(x[j]*x[j])+(y[j]*y[j]));
                if (d<min) {
                    min=d;
                    temp=x[0];//2.
                    x[0]=x[i];
                    x[i]=temp;
                    temp=y[0];
                    y[0]=y[i];
                    y[i]=temp;
                    temp=x[1];
                    x[1]=x[j];
                    x[j]=temp;
                    temp=y[1];
                    y[1]=y[j];
                    y[j]=temp;
                }
            }
        }
    }
    (*N)--;//3.
    (*N)--;
}
int join (int *N,float *x,float *y) {
    if (((*N)==0) || ((*N)==1)){
        printf ("Autes htan oles oi antikatastaseis, to programma tha termatistei.\n");
        return EXIT_SUCCESS;
    }
        find_pair (N,x,y);
        printf ("Oi radiofaroi me syntetagmenes\nA:[%f,%f]\nB:[%f,%f]\nTha antikatastathoun apo radiofaro neas texnologias\n\n",x[0],y[0],x[1],y[1]);
        x++;
        x++;
        y++;
        y++;
        join (N,x,y);
}
int main () {
    int N,i;
    float *x,*y;
    printf ("Eisagete to plithos ton radiofarwn: ");
    scanf ("%d",&N);
    x=(float *)malloc(N*sizeof(float));
    y=(float *)malloc(N*sizeof(float));
    if ((x==NULL) || (y==NULL)) {
        printf ("Memory could not be allocated please re-initialize the program");
        exit (1);
    }
    for (i=0;i<N;i++){
        printf ("Eisagete tis syntetagmenes tou %dou radiofarou\nx:",i+1);
        scanf ("%f",&x[i]);
        printf ("y:");
        scanf ("%f",&y[i]);
    }
    join (&N,x,y);
}




