#include <iostream>
#include <cstdlib>
#include <cstring>

using namespace std;

class circuitS {
    int *R,*I_max,i;
    float *V_R;
    public:
    circuitS(int N_R,float V);
    circuitS(int N_R, int seed,float V);
    float get_tres(int N_R);
    void check(int N_R,float V);
    void out(int N_R,float V);
    int Ret_Res (int i);
};

circuitS::circuitS(int N_R,float V){
    float tres;

    V_R= new float[N_R]; //Voltage of each resistance
    R= new int[N_R];
    I_max = new int[N_R];

    tres = get_tres(N_R);

    cout << "+--------------+\n";
    cout << "+Serial circuit+\n";
    cout << "+--------------+\n";

    for (i=0;i<N_R;i++) {
        cout << "Please type in the value of Resistance " << i+1 << " and the respective value of its Maximum Current\n";
        cout << "Resistance: ";
        cin >> R[i];
        cout << "Maximum current: ";
        cin >> I_max[i];
        V_R[i] = (V/tres)*R[i];
    }
}

circuitS::circuitS (int N_R, int seed,float V) {
    int Max,Min;
    float tres;

    V_R= new float[N_R];
    R= new int[N_R];
    I_max = new int[N_R];

    tres = get_tres(N_R);

    cout << "+--------------+\n";
    cout << "+Serial circuit+\n";
    cout << "+--------------+\n";

    cout << "Please type in a maximum and a minimum limit for the generated values of \nthe Resistances and the respective Maximum Currents\n";
    cout << "Max: ";
    cin >> Max;
    cout << "Min: ";
    cin >> Min;

    srand (seed);

    for (i=0;i<N_R;i++) {
        R[i] = rand() % Max + Min;
        I_max[i] = rand() % Max + Min;
        V_R[i]=(V/tres)*R[i];

    }

}

float circuitS::get_tres(int N_R) {
    float sum=0;

    for (i=0;i<N_R;i++) {
        sum=sum+R[i];
    }
    return sum;
}

void circuitS::check (int N_R,float V) {

    for (i=0;i<N_R;i++) {
        if ( (V_R[i]/R[i]) > I_max[i] ) {
            cout << "Resistance " << i+1 << "will be destroyed with the current voltage!\n";
        }
    }
}

void circuitS::out (int N_R, float V) {
    float tres;

    tres= get_tres(N_R);
    cout << "Serial circuit attributes at " << V/tres << "A\n";
    cout << "Resistance|Voltage\n";
    for (i=0;i<N_R;i++) {
        cout << R[i] << "|" << (V/tres)*R[i] << "\n";
    }
}

int circuitS::Ret_Res(int i) {
    return R[i];
}


//End of circuitS

class circuitP {
    int *R,*I_R,*I_max,i;
    public:
    circuitP(int N_R,float V);
    circuitP(int N_R, int seed,float V);
    float get_tres(int N_R);
    void check(int N_R,float V);
    void out(int N_R,float V);

};

circuitP::circuitP(int N_R,float V){

    R= new int[N_R];
    I_R= new int[N_R]; //Currency of each resistance
    I_max = new int[N_R];

    cout << "+----------------+\n";
    cout << "+Parallel circuit+\n";
    cout << "+----------------+\n";

    for (i=0;i<N_R;i++) {
        cout << "Please type in the value of Resistance " << i+1 << " and the respective value of its Maximum Current\n";
        cout << "Resistance: ";
        cin >> R[i];
        cout << "Maximum current: ";
        cin >> I_max[i];
        I_R[i] = V*R[i];
    }
}

circuitP::circuitP (int N_R, int seed,float V) {
    int Max,Min;

    R= new int[N_R];
    I_R= new int[N_R]; //Currency of each resistance
    I_max = new int[N_R];

    cout << "+----------------+\n";
    cout << "+Parallel circuit+\n";
    cout << "+----------------+\n";

    cout << "Please type in a maximum and a minimum limit for the generated values of \nthe Resistances and the respective Maximum Currents\n";
    cout << "Max: ";
    cin >> Max;
    cout << "Min: ";
    cin >> Min;

    srand (seed);

    for (i=0;i<N_R;i++) {
        R[i] = rand() % Max + Min;
        I_max[i] = rand() % Max + Min;
        I_R[i] = V*R[i];
    }

}

float circuitP::get_tres(int N_R) {
    float sum=0;

    for (i=0;i<N_R;i++) {
        sum=sum+(1/R[i]);
    }
    return sum;
}

void circuitP::check (int N_R,float V) {

    for (i=0;i<N_R;i++) {
        if ( (V/R[i]) > I_max[i] ) {
            cout << "Resistance " << i+1 << "will be destroyed with the current voltage!\n";
        }
    }
}

void circuitP::out (int N_R, float V) {

    cout << "Parallel circuit attributes at " << V << "V\n";
    cout << "Resistance|Current\n";
    for (i=0;i<N_R;i++) {
        cout << R[i] << "|" << V/R[i] << "\n";
    }
}

class circuit: public circuitS, public circuitP {
    int N_Rs,N_Rp,V,seed,k;
    float TotalRes;
    public:
    circuit(int N_Rs,int N_Rp,float V);
    circuit(int N_Rs,int N_Rp,int seed,float V);
    float set_tres(int k);
    void check(int k);
};

circuit::circuit(int N_Rs,int N_Rp,float V):circuitS(N_Rs,V),circuitP(N_Rp,V) {}
circuit::circuit(int N_Rs,int N_Rp,int seed,float V):circuitS(N_Rs,seed,V),circuitP(N_Rp,seed,V) {}

float circuit::set_tres(int k) {

    if (k == 0) {
        TotalRes=circuitS::get_tres(N_Rs)+(1/circuitP::get_tres(N_Rp));
    }
    else {
        TotalRes=circuitS::get_tres(N_Rs)+circuitP::get_tres(N_Rp);
    }
    return TotalRes;
}

void circuit::check (int k) {

    if (k == 0) {
        circuitS::check(N_Rs,V);
        circuitP::check(N_Rp,V);
    }
    else {
        int i,Vin=0;
        for (i=0;i<N_Rs;i++) {
            Vin+=(V/circuitS::get_tres(N_Rs))*Ret_Res(i); //Here we calculate the voltage input into the parallel circuit.
        }
        circuitS::check(N_Rs,V-Vin);
        circuitP::check(N_Rp,Vin);
    }
}

int main () {
    float V;
    int N_Rs,N_Rp,seed,Conn_type;
    char check[2],yes[2]="y"; //1 slot for the letter and one for "\0" (string null terminator)

    cout << "Please type in the Voltage of the circuit: ";
    cin >> V;
    cout << "Please type in the number of Resistances in the serial circuit: ";
    cin >> N_Rs;
    cout << "Please type in the number of Resistances in the parallel circuit: ";
    cin >> N_Rp;

    cout << "Do you know the values of the Resistances and their\nrespective Maximum Currents?(y/n): ";
    cin >> check;

    if (strcmp (yes,check) == 0) {

        cout << "Please type 1 if the circuits are going to be connected\nserially or 0 if they are going to be connected parallelly: ";
        cin >> Conn_type;

        if (Conn_type == 0) {
            circuit parallel (N_Rs,N_Rp,V);
            parallel.circuitS::out(N_Rs,V);
            parallel.circuitP::out(N_Rp,V);
            cout << "Circuit's total Resistance: " << parallel.set_tres(0) << "\n";
            parallel.check(0);
        }
        else {
            circuit serial (N_Rs,N_Rp,V);
            serial.circuitS::out(N_Rs,V);
            serial.circuitP::out(N_Rp,V);
            cout << "Circuit's total Resistance: " << serial.set_tres(1) << "\n";
            serial.check(1);
        }
    }
    else {

        cout << "Please type an integral seed to generate random values\nfor the Resistances and their respective Maximum Currents: ";
        cin >> seed;

        cout << "Please type 1 if the circuits are going to be connected\nserially or 0 if they are going to be connected parallelly: ";
        cin >> Conn_type;

        if (Conn_type == 0) {
            circuit parallel (N_Rs,N_Rp,seed,V);
            parallel.circuitS::out(N_Rs,V);
            parallel.circuitP::out(N_Rp,V);
            cout << "Circuit's total Resistance: " << parallel.set_tres(0) << "\n";
            parallel.check(0);
        }
        else {
            circuit serial (N_Rs,N_Rp,seed,V);
            serial.circuitS::out(N_Rs,V);
            serial.circuitP::out(N_Rp,V);
            cout << "Circuit's total Resistance: " << serial.set_tres(1) << "\n";
            serial.check(1);
        }
    }

}


