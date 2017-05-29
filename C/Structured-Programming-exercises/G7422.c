#include <stdio.h>
#include <stdlib.h>
#include <process.h>
int EggrPel(struct record pelaths);
int KatAitDiag();
int EkdLogEkkPel();
int KatNewe(struct record pelaths);
struct record {
    int kwdikos,sxesh;
    char onoma;
    float endeixh;
};

int main () {
    int choice;
    struct record pelaths;
    printf ("Epilexte ena apo ta parakatw:\n");
    printf ("1.Eggrafh sto arxeio newn pelatwn\n");
    printf ("2.Kataxwrhsh sto arxeio twn aithmatwn gia thn diagrafh pelatwn\n");
    printf ("3.Ekdosh twn logariasmwn twn pelatwn/ekkatharish pelatwn pou zhthsan na lysoun to symbolaio tous\n");
    printf ("4.Kataxwrhsh newn endeixewn pou edwsan oi metrhtes twn pelatwn\n");
    printf ("5.Exodos apo to programma\n");
    scanf ("%d",&choice);
    switch (choice) {
        case 1:
        EggrPel(pelaths);
        break;
        case 2:
        KatAitDiag();
        break;
        case 3:
        EkdLogEkkPel();
        break;
        case 4:
        KatNewe(pelaths);
        break;
        case 5:
        exit (1);
    }
}

int EggrPel (struct record pelaths){
    FILE *fp;
    int i,fl;
    printf ("++++++Eggrafh neou pelath++++++\n");
    printf ("Eisagete ton kwdiko tou pelath: ");
    scanf  ("%d",&pelaths.kwdikos);
    printf ("Eisagete to onoma tou pelath: ");
    scanf  ("%s",&pelaths.onoma);
    pelaths.sxesh=1;
    fp=fopen("Stoixeia","r+b");
    fseek(fp,0,SEEK_END);
    fwrite (&pelaths,sizeof(struct record),1,fp);
    fclose (fp);
    printf ("An thelete na kanete nea kataxwrhsh, dwste 0. Diaforetika dwste otidhpote");
    scanf ("%d",&fl);
    if (fl==0){
        int EggrPel(struct record pelaths);
    }
    else {
        return 0;
    }
}

int KatAitDiag (){
    FILE *fp;
    int kwd,fl;
    struct record a,b,temp;
    printf ("++++++Kataxwrhsh aithshs diagrafhs++++++\n");
    printf ("Eisagete ton kwdiko tou pelath pou ekane aithma diagrafhs symbolaiou: ");
    scanf ("%d",kwd);
    fp=fopen("Stoixeia","r+b");
    if (fp==NULL){
        printf ("File Error, please re-initialize the program");
        return EXIT_FAILURE;
    }
    fseek (fp,kwd,SEEK_SET);
    fread (&a,sizeof (struct record),1,fp);
    a.kwdikos=ftell(fp);
    fseek (fp,0,SEEK_END);
    fread (&b,sizeof (struct record),1,fp);
    b.kwdikos=ftell(fp);
    temp=a;
    a=b;
    b=temp;
    a.sxesh=0;
    fwrite(&a.sxesh,sizeof(int),1,fp);
    fclose(fp);
    printf ("An thelete na kanete nea kataxwrhsh, dwste 0. Diaforetika dwste otidhpote");
    scanf ("%d",&fl);
    if (fl==0){
        int KatAitDiag();
    }
    else {
        return 0;
    }
}

int EkdLogEkkPel() {
    FILE *fp1,*fp2,*fp3;
    int N,i,count;
    struct record a;
    fp1=fopen("Logariasmoi","w+");
    fp2=fopen("Stoixeia","r+b");
    fp3=fopen("StoixeiaNew","r+b");
    fseek(fp2,0,SEEK_END);
    N=ftell(fp2);
    rewind(fp2);
    for (i=0;i<N;i++){
        fread (&a,sizeof (struct record),1,fp2);
        fwrite(&a,sizeof (struct record),1,fp1);
        fseek(fp2,i+1,SEEK_SET);
    }
    fclose(fp1);
    fseek(fp2,0,SEEK_END);
    count=0;
    for (i=0;i<N;i++){
        fread (&a,sizeof (struct record),1,fp2);
        if (a.sxesh==0){
            count++;
        }
        fseek(fp2,-1-i,SEEK_SET);
    }
    rewind(fp2);
    for (i=0;i<(N-count);i++){
        fread (&a,sizeof (struct record),1,fp2);
        fwrite(&a,sizeof (struct record),1,fp3);
    }
    fclose(fp2);
    fclose(fp3);
    remove("Stoixeia");
    rename("StoixeiaNew","Stoixeia");
    printf ("H diadikasia oloklhrwthike epityxws\n");
}

int KatNewe(struct record pelaths) {
    FILE *fp;
    int fl;
    printf ("++++++Kataxwrhsh newn metrhswn++++++\n");
    printf ("Eisagete ton kwdiko tou pelath: ");
    scanf  ("%d",&pelaths.kwdikos);
    printf ("Eisagete tin nea metrhsh tou pelath: ");
    scanf  ("%f",&pelaths.endeixh);
    fp=fopen("Stoixeia","r+b");
    fseek(fp,pelaths.kwdikos,SEEK_END);
    fwrite(&pelaths.endeixh,sizeof(struct record),1,fp);
    fclose(fp);
    printf ("An thelete na kanete nea kataxwrhsh, dwste 0. Diaforetika dwste otidhpote");
    scanf ("%d",&fl);
    if (fl==0){
        int KatNewe(struct record pelaths);
    }
    else {
        return 0;
    }
}
























