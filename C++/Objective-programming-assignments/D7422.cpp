#include <iostream>
#include <cstdio>

using namespace std;

class vector;

class matrix {
    int n;
    float **a;
    public:
    int Current_Index;
    matrix (int N);
    float* operator [] (int index);
    vector operator ! ();
};

class vector {
    int n,i;
    float *x;
    public:
    vector (int N);
    int operator > (vector v);
    float& operator [] (int index) {return x[i];}
    void operator = (matrix a);
    vector operator - (vector w);
    float operator ++ ();
};

matrix::matrix (int N) {

    int i,j;

    n=N;

    a =(float **) new float[n]; //Cast to float** since new will return float*
    for (i=0;i<n;i++) {
        a[i] = new float[n];
    }

    cout << "///////Please insert the elements of the matrix \"a\"///////\n";

    for (i=0;i<n;i++) {
        for (j=0;j<n;j++) {
            printf ("a[%d,%d]: ",i,j);
            cin >> a[i][j];
        }
    }
}

float* matrix::operator [] (int index) {
    return a[index];
}



vector matrix::operator ! () {
    int j;
    vector temp(n);

    float Sum_i=0,Sum_j=0;

    for (j=0;j<n;j++) {
        Sum_i+=a[Current_Index][j];
    }
    for (j=0;j<n;j++) {
        Sum_j+=a[j][Current_Index];
    }

    if (Sum_i < Sum_j) {
        temp[Current_Index] = Sum_i;
        return temp;
    }
    else { //Even if Sum_i and Sum_j are equal we still return Sum_j (random pick)
        temp[Current_Index] = Sum_j;
        return temp;
    }
}

vector::vector (int N) {

    n=N;

    x = new float[n];

}

int vector::operator > (vector v) {

    int check=0;

    for (i=0;i<n;i++) {
        if (x[i] > v[i]) {
            check++;
        }
    }

    if (check == n) {
        return 0;
    }
    else {
        return 1;
    }
}

void vector::operator = (matrix a) {

     for (i=0;i<n;i++) {
        x[i] = a[i][i];
     }
}

vector vector::operator - (vector w) {

    vector temp(n);

    for (i=0;i<n;i++) {
        temp[i] = x[i]-w[i];
    }

    return temp;
}

float vector::operator ++ () {

    float sum=0;

    for (i=0;i<n;i++) {
        sum+= x[i];
    }

    return sum;
}

int main () {

    int N,i,check=0;

    cout << "Please insert the size of the matrix \"a\" ";
    cin >> N;

    matrix a(N);
    vector d(N),v(N),w(N);


    d=a;
    for (i=0;i<N;i++) {
        a.Current_Index=i;
        v=!a;
    }
    w= d-v;

    if ((d > v) == 0) {

        cout << "Matrix is diagonal (unknown english word)!\n";
        cout << "//////Matrix W//////\n";

        for (i=0;i<N;i++) {
            cout << "//////" << w[i] << "//////\n";
        }

        cout << "\n" << ++w << "\n";
    }
}



