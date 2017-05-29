#include <stdio.h>
#include <math.h>
void main ()
{
int i,j,BestPos ;
float x[30],y[30],bx[30],by[30],P[30],d[30],w[30][15],MT[15],max ;
static float S[15] ;
printf ("\n\n\n******************************************\n");
printf ("EISAGWGH STOIXEIWN, ANAMETADOTWN *********\n");
printf ("******************************************\n");
for (i=0 ; i <30 ; i++) {
    printf ("------------------------------------------------------------------\n\n");
    printf ("Eisagete tis syntetagmenes kai tin isxy tou %dou anametadoth:\nx:",i+1);
    scanf ("%f",&x[i]);
    printf ("y:");
    scanf ("%f",&y[i]);
    printf ("P:");
    scanf ("%f",&P[i]);
}
printf ("\n\n\n*********************************************************\n");
printf ("EISAGWGH SYNTETAGMENWN, PITHANWN STATHMWN BASHS *********\n");
printf ("*********************************************************\n");
for (i=0 ; i<15 ; i++) {
    printf ("------------------------------------------------------------------\n\n");
    printf ("Eisagete tis pithanes syntetagmenes tou %dou stathmou vashs:\nx:",i+1);
    scanf ("%f",&bx[i]);
    printf ("y:");
    scanf ("%f",&by[i]);
}
for (i=0;i<30;i++) {
    for (j=0;j<15;j++) { /*Ypologismos apostashs anametadoth-stathmou bashs kai isxyos stin pithani thesh */
        d[i]=fabs(sqrt(pow(bx[j],2)+pow(by[j],2))-sqrt(pow(x[i],2)+pow(y[i],2)));
        w[i][j]=P[i]/pow(d[i],2);
    }
}   
for (i=0;i<15;i++){ /*Ypologismos meshs timhs,kathe shmeiou */
     for (j=0;j<30;j++) {
        S[i] += w[i][j];/*Athroisma isxyon sto ekastte shmeio */
}
MT[i]=S[i]/30;
}
max=MT[0]; 
BestPos=0;
for (i=1 ; i<15 ; i++){ /*Euresh ths megisths meshs timhs kai apodotikoterhs theshs. */
    if (MT[i]>max) {
      max=MT[i];
      BestPos=i;
      }
}
printf ("-----------------------------------------------------------------------\n");
printf ("-----------------------------------------------------------------------\n\n\n\n");
printf ("To katallhlotero shmeio gia tin egatastash toy stathmou bashs einai to:\nx:%f\ny:%f",bx[BestPos],by[BestPos]); 
}    

