#include <stdio.h>
#include <stdlib.h>
#include <process.h>
int diadromh (int fl,int max,int **graph,float **weights);
int main () {
    int N,i,j,k,l,**graph,max,fl,*p,*Bathmos;
    float **weights;
    printf ("Eisagete to plithos twn koryfwn: ");
    scanf("%d",&N);
    p=(int *) malloc(N*sizeof(int));
    Bathmos=(int *) malloc(N*sizeof(int));
    for (i=0;i<N;i++){
        printf ("Eisagete ton bathmo tis %dhs koryfhs: ",i);
        scanf ("%d",&Bathmos[i]);
        p[i]=0;
    }
    for (i=0;i<N;i++) {
        for (j=0;j<N;j++){
            if (Bathmos[i]==Bathmos[j]){
                p[i]++;
            }
        }
    }
    for (i=0;i<N;i++){
        printf ("%d\n",p[i]);
    }
    graph=(int **)malloc(N*sizeof(int));
    weights=(float **)malloc(N*sizeof(float));
    if ((graph==NULL) || (weights==NULL)){
        printf ("Memory could not be allocated please re-initialize the program\n");
        exit (EXIT_FAILURE);
    }
    for (i=0;i<N;i++){
        graph[i]=(int*)malloc(p[i]*sizeof(int));
        weights[i]=(float*)malloc(p[i]*sizeof(float));
        if ((graph[i]==NULL) || (weights[i]==NULL)){
            printf ("Memory could not be allocated please re-initialize the program\n");
            exit (EXIT_FAILURE);
        }
    }
    for (i=0;i<N;i++){
        l=0;
        j=0;
        while ((l<p[i]) && (j<N)){
            if (Bathmos[j]==i){
                graph[i][l]=Bathmos[j];
                l++;
            }
            j++;
        }
    }
    for (i=0;i<N;i++){
        l=0;
        j=0;
        while ((j<N) && (l<p[i])){
            if ((i<j) && (Bathmos[j]==i)){
                printf ("Eisagete to baros tis akmis metaxy ths %dhs kai ths %dhs koryfhs: ",i,j);
                scanf ("%f",&weights[i][l]);
                weights[l][i]=weights[i][l];
                l++;
            }
            j++;
        }
    }
    for (i=0;i<N;i++){
        for (j=0;j<max;j++){
            printf ("%d    |||||||||||||    %f\n",graph[i][j],weights[i][j]);
        }
    }
    fl=0;
    printf ("+++++++++Diadikasia Dynatwn Diadromwn+++++++++\n\n");
    diadromh(fl,max,graph,weights);
    free (graph);
    free (weights);
}
int diadromh (int fl,int max,int **graph,float **weights){
    int count,i,j,k,l,success,plithos,stop;
    float sum;
    if (fl==0){
        success=0;
        printf("Poses koryfes diadromhs tha eisagete?: ");
        scanf ("%d",&plithos);
        int koryfh[plithos];
        for (i=0;i<plithos;i++){
            printf ("Eisagete thn %dh koryfh: ",i+1);
            scanf  ("%d",&koryfh[i]);
        }
        count=k=j=0;
        sum=stop=0;
        while ((k<plithos) && (stop==0)){
            for (j=0;j<max;j++){
                if (graph[koryfh[k+1]][j]==koryfh[k]){
                    count++;
                    sum+=weights[koryfh[k+1]][j];
                    break;
                }
            }
            if (count==0){
                stop=1;
            }
            else success++;
            k++;
            count=0;
        }
        if (success==(plithos)){
        printf ("H diadromh einai efikth!\nTo athroisma ton barwn twn akmwn pou syndeoun\ntis koryfes ths diadromhs einai: %f\n",sum);
        }
        else {
        printf ("H diadromh einai anefikth.\n");
        }
        printf ("\n\n\n\nAn thelete na eisagete kai nea diadromh dwste 0, allios dwste otidhpote: ");
        scanf ("%d",&fl);
        diadromh(fl,max,graph,weights);
    }
    else {
        return 0;
    }
}






