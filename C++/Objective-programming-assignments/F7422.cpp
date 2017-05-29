#include <iostream>

using namespace std;

template <class burner> class device {

    burner *burners;
    int n;
    public:
    device (float Uptime);
    burner* b_sort();
};

template <class burner> device<burner>::device (float Uptime) {

    cout << "Please insert the number of burners: ";
    cin >> n;

    burners = new burner[n];

    int i;

    for (i=0;i<n;i++) {

        burners[i].setUptime(Uptime);

    }


}

template <class burner> burner* device<burner>::b_sort () {

    int i,j;

    for (i=1;i<n;i++){
        for (j=0;j<(n-i);j++) {
            if ((burners[j].retP()/burners[j].retFR()) < (burners[j+1].retP()/burners[j+1].retFR())) { // P/FR descending sort
                swap (burners[j],burners[j+1]);
            }
        }
    }

    return burners;

}


class oil_burner {

    int ID;
    float P,FR,CostPerUnit,PurchaseCost,ServiceCost,Uptime;
    public:

    oil_burner ();
    void setUptime(float a) {Uptime=a;}
    int retID () {return ID;}
    float retP () {return P;}
    float retFR() {return FR;}
    float retPurch() {return PurchaseCost;}
    float retTotalCost() {return (Uptime*FR*CostPerUnit)+ServiceCost;}

};

oil_burner::oil_burner () {

    cout << "Please type in the ID the oil burner: ";
    cin >> ID;
    cout << "Please type in the maximum power of the oil burner: ";
    cin >> P;
    cout << "Please type in the daily consumption of the oil burner: ";
    cin >> FR;
    cout << "Please type in the cost (per unit) of the oil burner's fuel: ";
    cin >> CostPerUnit;
    cout << "Please type in the purchase cost of the oil burner: ";
    cin >> PurchaseCost;
    cout << "Please type in the yearly service cost of the oil burner: ";
    cin >> ServiceCost;

}

class gas_burner {

    int ID;
    float P,FR,CostPerUnit,PurchaseCost,ServiceCost,ConnCost,Uptime;
    public:

    gas_burner ();
    void setUptime(float a) {Uptime=a;}
    int retID () {return ID;}
    float retP () {return P;}
    float retFR() {return FR;}
    float retPurch() {return PurchaseCost;}
    float retTotalCost() {return (Uptime*FR*CostPerUnit)+ServiceCost+ConnCost;}
    float retDailyCost() {return FR*CostPerUnit;}
};

gas_burner::gas_burner () {

    cout << "Please type in the ID the burner: ";
    cin >> ID;
    cout << "Please type in the maximum power of the gas burner: ";
    cin >> P;
    cout << "Please type in the daily consumption of the gas burner: ";
    cin >> FR;
    cout << "Please type in the cost (per unit) of the gas burner's fuel: ";
    cin >> CostPerUnit;
    cout << "Please type in the purchase cost of the gas burner: ";
    cin >> PurchaseCost;
    cout << "Please type in the yearly service cost of the gas burner: ";
    cin >> ServiceCost;
    cout << "Please type in the connection cost to the gas\nnetwork: ";
    cin >> ConnCost;

}

template <class burner1, class burner2> void choice (burner1 a[], burner2 b[],float Pmin,float Gold) {

    int i,days=1,n;
    oil_burner canditate1;
    gas_burner canditate2;

    n=sizeof(a)/sizeof(burner1); //Getting number of array elements, since original number "n" is private in device class

    for (i=0;i<n;i++) {

        if ( a[i].retP()>Pmin && a[i].retPurch()<Gold) {

            canditate1=a[i];
            break;

        }
    }

    for (i=0;i<n;i++) {

        if ( b[i].retP()>Pmin && a[i].retPurch()<Gold) {

            canditate2=b[i];
            break;

        }
    }

    if (canditate1.retTotalCost() < canditate2.retTotalCost()) {

        if (canditate1.retPurch() < canditate1.retPurch()) {
            cout << "The oil burner with id " << canditate1.retID() << " is the best choice\n";
        }

        else {

            float temp;
            temp= (canditate2.retTotalCost() - canditate1.retTotalCost());

            while (temp<(canditate1.retPurch()-canditate2.retPurch())) {

                temp+=temp;
                days++;
            }

            cout << "The oil burner with id " << canditate2.retID() << " is the best choice\n";
            cout << "The depriciation time of the extra cost is " << days << " days.\n";

        }
    }

    else {

        if (canditate2.retPurch() < canditate1.retPurch()) {
            cout << "The oil burner with id " << canditate2.retID() << " is the best choice\n";
        }
        else {

            float temp;
            temp= (canditate1.retTotalCost() - canditate2.retTotalCost());

            while (temp<(canditate2.retPurch()-canditate1.retPurch())) {

                temp+=temp;
                days++;
            }

            cout << "The oil burner with id " << canditate1.retID() << " is the best choice\n";
            cout << "The depriciation time of the extra cost is " << days << " days.\n";

        }
    }
}

int main () {

    float Pmin,Gold,Uptime;

    cout << "Please type in the minimum power of the burner: ";
    cin >> Pmin;
    cout << "Please type in the available budget: ";
    cin >> Gold;
    cout << "Please type in the uptime of the burner (in days): ";
    cin >> Uptime;

    device<oil_burner> Oilburner(Uptime);
    device<gas_burner> Gasburner(Uptime);

    choice (Oilburner.b_sort(),Gasburner.b_sort(),Pmin,Gold);

}



