#include <iostream>
using namespace std;

//In this program time is represented in minutes


class machine {
    int ID,ItemLimit;
    float Payment,ConstructionTime,IdleTime,ServiceCost,FunctionCost;
    public:
    void Attributes (int i);
    float ReturnConTime ();
    float TotalCost (int m,float Materialcost);
    int ReturnID();
};

void machine::Attributes(int i) {
    cout << "Please fill the attributes of machine" << i+1 << ".\n";
    cout << "ID: ";
    cin >> ID;
    cout << "Time in minutes required to make an item: ";
    cin >> ConstructionTime;
    cout << "Mechanic's payment/hour: ";
    cin >> Payment;
    cout << "Total items before service: ";
    cin >> ItemLimit;
    cout << "Idle time in minutes while in service: ";
    cin >> IdleTime;
    cout << "Service cost: ";
    cin >> ServiceCost;
    cout << "Energy consumption/hour cost: ";
    cin >> FunctionCost;
    cout << "\n";
}

float machine::ReturnConTime() {
    return ConstructionTime;
}

float machine::TotalCost(int m, float MaterialCost) {
    if (m<ItemLimit) {
        return ((ConstructionTime/60)*m*Payment)+(m*MaterialCost)+((ConstructionTime/60)*m*FunctionCost);
    }
    else {
        return ((ConstructionTime/60)*m*Payment)+((ConstructionTime/60)*m*FunctionCost)+(m*MaterialCost)+(m/ItemLimit)*((IdleTime/60)*FunctionCost)+(m/ItemLimit)*((IdleTime/60)*Payment)+(m/ItemLimit)*ServiceCost;
    }
}

int machine::ReturnID() {
    return ID;
}

machine m_short (machine machines[],int m,int n,float MaterialCost) {
    int i,j,flag;
    float min;
    for (i=1;i<n;i++){
        for (j=0;j<(n-i);j++) {
            if (machines[j].ReturnConTime() > machines[j+1].ReturnConTime()) {
                swap (machines[j],machines[j+1]);
            }
            else if (machines[j].ReturnConTime() == machines[j+1].ReturnConTime()) {
                if (machines[j].TotalCost(m,MaterialCost) > machines[j+1].TotalCost(m,MaterialCost)) { //We consider that two machines cannot have the same cost.
                    swap (machines[j],machines[j+1]);
                }
            }
        }
    }
    min=machines[0].ReturnConTime()/machines[0].TotalCost(m,MaterialCost);
    for (i=1;i<n;i++) {
       if ((machines[i].ReturnConTime()/machines[i].TotalCost(m,MaterialCost))<min) {
           min=(machines[i].ReturnConTime()/machines[i].TotalCost(m,MaterialCost));
           j=i;
       }
    }
    cout << min;
    return machines[j];
}

int main () {
    int i,n,m;
    float MaterialCost;
    machine best;

    cout << "Please insert the total number of machines available: ";
    cin >> n;
    machine *machines = new machine[n];
    for (i=0;i<n;i++) {
        machines[i].Attributes(i);
    }

    cout << "Please insert the total number of items\nthat are going to be produced: ";
    cin >> m;
    cout << "Please insert the cost of the materials/item: ";
    cin >> MaterialCost;

    best=m_short (machines,m,n,MaterialCost);
    cout << "_______________________________________________________________\n";
    cout << "|  ID  |   ConstructionTime   |   Cost    |   ConTime/Cost    |\n";
    for (i=0;i<n;i++) {
        cout << "|  " << machines[i].ReturnID() << "   |           " << machines[i].ReturnConTime() << "          |     " << machines[i].TotalCost(m,MaterialCost) << "      |         " << machines[i].ReturnConTime()/machines[i].TotalCost(m,MaterialCost) <<"          |\n";
    }
    cout << "_______________________________________________________________\n";
    cout << "The best machine is the one with the ID: " << best.ReturnID() << "\n";
}


