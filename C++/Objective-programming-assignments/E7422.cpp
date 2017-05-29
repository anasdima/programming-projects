#include <iostream>

using namespace std;

class material {
    float Amount, Specific_Weight;
    public:
    material ();
    void chA (float newA) {Amount=newA;}
    float retA () {return Amount;}
    float retSW () {return Specific_Weight;}
};

material::material () {

    cout << "Please insert the amount of the metal: ";
    cin >> Amount;
    cout << "Please insert the specific weight of the metal: ";
    cin >> Specific_Weight;

}


class product {
    public:
    virtual float volume () {}
    virtual int retN() {}
};

class product1: public product {
    float R,H;
    int N;
    public:
    product1 ();
    float volume ();
    int retN() {return N;}
};

product1::product1() {

    cout << "Please type in the number of cylinder items that are going to be created: ";
    cin >> N;
    cout << "Please type in the base radius and the height of the cylinder.\n";
    cout << "Radius: ";
    cin >> R;
    cout << "Height: ";
    cin >> H;
}

float product1::volume() {

    const double pi = 3.141592;

    return N*pi*(R*R)*H;
}

class product2: public product{
    float S;
    int N;
    public:
    product2();
    float volume ();
    int retN() {return N;}
};

product2::product2 () {

    cout << "Please type in the number of cube items that are going to be created: ";
    cin >> N;
    cout << "Please type in the side length of the cube: ";
    cin >> S;
}

float product2::volume() {

    return N*(S*S*S);
}


void production (material materials[],product **orders) {

    int i,j,check=0,TotalN1[5],TotalN2[5];
    bool GameOver=false;

    //We consider that the 5 product1 orders are going to be produced first
    //Also, in the mathematical formula, "1/Specific_Weight" is the density of the metal
    //(d=M/V)

    //Product 1


    i=0;
    while (i<5 && GameOver == false) {
        j=0;
        while ((materials[j].retA()/orders[i]->volume()) > (1/materials[j].retSW()) && j<5) {
            j++;
        }
        //--//
        if (j == 5) {

            cout << "There is not enough metal to produce order" << i+1 << "\nof type \"product 1\"\n";

        }
        else {

            materials[j].chA(materials[j].retA()-(1/(orders[i]->volume()*materials[j].retSW())));
            TotalN1[j] += orders[i]->retN();

            if (materials[j].retA() == 0) {
            check ++;
            }
        }
        //--//
        if (check == 5) {
            GameOver = true;
        }
        else {
            i++;
        }
    }

    //Product 2

    if (i<5) {

        cout << "The cube type orders cannot be produced due to lack of metal\n";

    }
    else {
        i=5;
        while (i<9 && GameOver == false) {
            j=0;
            while ((materials[j].retA()/orders[i]->volume()) > (1/materials[j].retSW()) && j<5) {
                j++;
            }
            //--//
            if (j == 4) {

                cout << "There is not enough metal to produce order" << i+1 << "\nof type \"product 2\"\n";

            }
            else {

                materials[j].chA(materials[j].retA()-(1/orders[i]->volume()*materials[j].retSW()));
                TotalN2[j] += orders[i]->retN();

                if (materials[j].retA() == 0) {
                check ++;
                }
            }
            //--//
            if (check == 4) {
                GameOver = true;
            }
            else {
                i++;
            }
        }
    }

    cout << "___________________\n";
    cout << "|    Product 1    |\n";
    cout << "-------------------\n";

    for (i=0;i<5;i++) {

        cout << "There are going to be produced " << TotalN1[i] << " items of metal " << i+1 << "\n";
    }

    cout << "___________________\n";
    cout << "|    Product 2    |\n";
    cout << "-------------------\n";

    for (i=0;i<4;i++) {

        cout << "There are going to be produced " << TotalN2[i] << " items of metal " << i+1 << "\n";
    }
}

int main () {

    material *materials;
    product **orders;
    int i;

    materials = new material[5];
    orders = (product**)  new product[9];

    for (i=0;i<5;i++) {

         orders[i] = new product1[1];

    }

    for (i=5;i<9;i++) {

        orders[i] = new product1[1];
    }


    production (materials,orders);

    delete materials,orders;

}
