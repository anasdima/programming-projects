#include <stdio.h>
/* +++++++++++++++ Metablhtes pou xrhsimopoiountai sto programma +++++++++++++++ */
/* a1,b1.....  -> Oria diasthmatwn */
/* N           -> Plithos tyxaion arithmon */
/* TA          -> Tyxaioi arithmoi */
/* P0,P1,P2,P3 -> Plithos arithmon epimerous diastimaton */
/* S0,S1,S2,S3 -> Athroisma arithmon epimerous diastimaton */
/* i           -> Metritis epanalhpsewn */
/* M0,M1,M2,M3 -> Mesh timh arithmon epimerous diasthmatwn */

void main ()
{
float a1,b1,a2,b2,a3,b3,TA,S0,S1,S2,S3 ; 
int N,i,P0,P1,P2,P3 ;
printf ("Dwste ta oria tou 1ou diasthmatos:\n") ; 

do { /* Elegxoume an ta dothenta oria einai swsta */
    scanf ("%f %f",&a1,&b1) ;
    if (a1>b1) {printf ("Lathos oria, prospathiste xana (prepei to 1o na einai mikrotero apo to 2o)\n");}
}while (a1>b1) ;

printf ("Dwste ta oria tou 2ou diasthmatos:\n") ;

do {
    scanf ("%f %f",&a2,&b2) ;
    if (a2>b2) {printf ("Lathos oria, prospathiste xana (prepei to 1o na einai mikrotero apo to 2o)\n");}
}while (a2>b2) ;

printf ("Dwste ta oria tou 3ou diasthmatos:\n") ;

do{
    scanf ("%f %f",&a3,&b3) ;
    if (a3>b3) {printf ("Lathos oria, prospathiste xana (prepei to 1o na einai mikrotero apo to 2o)\n");}
}while (a3>b3) ;
printf ("Ta diasthmata pou dwsate einai ta:\n[%f,%f]\n[%f,%f]\n[%f,%f]\n",a1,b1,a2,b2,a3,b3);
printf ("Dwste to plithos ton tyxaion arithmon\n") ;
scanf ("%d" ,&N) ;
printf ("Twra dwste tous tyxaious arithmous:\n") ;
i=1 ; 
P0=P1=P2=P3=0 ;
S0=S1=S2=S3=0 ;
do {
    scanf ("%f", &TA) ;
    if ( TA >= a1 && TA <= b1){ /* Den xrhsimopoioume domh else if dioti ta oria mporoun na synalhtheuoun. */
    S1 += TA ;
    P1++ ;}
    if (TA >=a2 && TA <=b2) {
    S2 += TA ;
    P2++ ;}
    if (TA >=a3 && TA <=b3) {
    S3 += TA ;
    P3++ ;}
    if (!( TA >= a1 && TA <= b1) && !(TA >=a2 && TA <=b2) && !(TA >=a3 && TA <=b3)) {
    printf ("Eidopoihsh: O arithmos pou dwsate den anhkei se kanena diastima, alla tha katametrithei.\n");
    S0 +=TA ;
    P0 ++ ; }
    
    i++ ;
}while (i<=N) ;
float M0,M1,M2,M3 ;
if (P1!=0) { /*Update apo to prohgoumeno upload, prostethike elegxos gia ton paronomasth tis meshs timhs */
M1 = S1/P1 ;
printf ("Sto diasthma [%f,%f] anhkoun %d arithmoi me mesh timh %f\n" ,a1,b1,P1,M1) ;}
else {
     printf ("Sto diasthma [%f,%f] den anhkei kanenas arithmos\n",a1,b1) ; }
if (P2!=0) {
M2 = S2/P2 ;
printf ("Sto diasthma [%f,%f] anhkoun %d arithmoi me mesh timh %f\n" ,a2,b2,P2,M2) ; }
else {
     printf ("Sto diasthma [%f,%f] den anhkei kanenas arithmos\n",a2,b2) ; }
if (P3!=0) {
M3 = S3/P3 ;
printf ("Sto diasthma [%f,%f] anhkoun %d arithmoi me mesh timh %f\n" ,a3,b3,P3,M3) ; }
else {
     printf ("Sto diasthma [%f,%f] den anhkei kanenas arithmos\n",a3,b3) ; }
if (P0!=0) {
M0 = S0/P0 ;
printf ("Oi arihmoi pou den anhkoun se kanena diasthma einai %d kai exoun mesh timh %f\n" ,P0,M0) ; }
else {
     printf ("\n\nOloi oi arithmoi htan entos ton diasthmaton\n") ; }
}





