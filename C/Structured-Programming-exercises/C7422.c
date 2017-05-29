#include <stdio.h>
#define k 10
int main () {
    float W[k][k];
    static float S[k];
    int i,j,State[k],c,stable_state,m,count,limit,temp[k];
    for (i=0;i<k;i++) {
        printf ("-------------------------------------------------\n");
        printf ("\nEisagete tin arxikh katastash tou %dou neurwna:\n",i+1);
        scanf ("%d",&State[i]);
        for (j=0;j<k;j++) {
            if (!((i==j) || (i>j))) { /* tipota stis theseis tou neurwna me ton eauto tou kathws kai stis antistoixes p.x h synapsh (5,6) einai idia me tin (6,5) */
                printf ("-----------------------------------------------------------------------\n");
                printf ("\nEisagete to baros tis synapshs pou syndeei ton %do neurwna me ton %do\n(Ean den yparxei synapsh metaxy autwn twn dyo neuronwn, kataxwrhste to 0):\n",i+1,j+1);
                scanf ("%f",&W[i][j]);
            }
        }
    }

for (i=0;i<k;i++) {
    c=i+1;
    for (j=c;j<k;j++) { /*Mono panw apo tin kyria diagwnio*/
        S[i] +=W[i][j]*State[j];
        c++;
    }
    temp[i]=State[i];

}
printf ("\nTwra to programma tha prospathisei na ferei to diktyo se stable state.\nParakaloume eisagete ton arithmo ton prospatheiwn pou tha ektelesei to programa.");
scanf ("%d",&limit);
count=0;
stable_state=0;
do {
    for (i=0;i<k;i++){
        if (S[i]>=0) {
            State[i]=1;
        }
        else {
            State[i]=-1;
        }
        if (temp[i]!=State[i]) {
            temp[i]=State[i];
            for (j=0;j<k;j++) {
                c=j+1;
                for (m=c;m<k;m++){
                    S[j]+=W[j][m]*State[m];
                    c++;
                }
            }
        }
        else {
            stable_state++;
        }
    }
    if (stable_state!=k){
            stable_state=0;
        }
    count++;
} while (stable_state!=k && count!=limit);
if (stable_state==k){
    printf ("To diktyo diamorfwthike epityxws se Stable State, epeita apo %d epanalhpseis\n",count);
    printf ("O pinakas me tin katastash ton neurwnwn:\n");
    printf ("|Neurwnas|Katastash|\n");
    for (i=0;i<k;i++){
        printf ("|%4d%10d\n",i+1,State[i]);
    }
}
else {
    printf ("To diktyo den diamorfwthike epityxws se Stable State\n");
    printf ("O pinakas me tin katastash ton neurwnwn epeita apo %d epanalhpseis:\n",limit);
    printf ("|Neurwnas|Katastash|\n");
    for (i=0;i<k;i++){
        printf ("|%4d%10d\n",i+1,State[i]);
    }
}
}

