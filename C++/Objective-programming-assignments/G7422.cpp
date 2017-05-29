#include <iostream>
#include <string>

using namespace std;


//------------------------------
class region {
    public:
    virtual float retMaxP() {}
    virtual int retID() {}
    virtual int retPriority() {}
};

class hospital:public region {
    int ID,Priority,Beds,Hospitals;
    float MaxPower;
    public:
    hospital();
    float retMaxP() {return MaxPower;}
    int retID() {return ID;}
    int retPriority() {return Priority;}
};

hospital::hospital() {

    cout << "*********Hospital Region*********\n";

    cout << "Please type in the region ID: ";
    cin >> ID;

    cout << "Please type in the priority number: ";
    cin >> Priority;

    cout << "Please type in the total beds and hospitals of the region: ";
    cin >> Beds;
    cin >> Hospitals;

    cout << "Please type in the max power of the region: ";
    cin >> MaxPower;

}


class household:public region {
    int ID,Priority,Households;
    float MaxPower;
    public:
    household();
    float retMaxP() {return MaxPower;}
    int retID() {return ID;}
    int retPriority() {return Priority;}
};

household::household () {

    cout << "*********Household Region*********\n";

    cout << "Please type in the region ID: ";
    cin >> ID;

    cout << "Please type in the priority number: ";
    cin >> Priority;

    cout << "Please type in the total households of the region: ";
    cin >> Households;

    cout << "Please type in the max power of the region: ";
    cin >> MaxPower;

}

//-------------------------------

//_______________________________
class region_type {

    string region_name;
    public:
    region_type(string name) {region_name=name;}
    string return_name () {return region_name;}
    virtual region* create()=0;

};


class Register_Utility {

    //Every new type is registered through this utility at compilation time

    public:
    static int total_types;
    static region_type **new_type;
    static void register_new_type (region_type *p);
    static int retTotal() {return total_types;}

};


region_type **Register_Utility::new_type;
int Register_Utility::total_types=0;

//Registering procedure

void Register_Utility::register_new_type (region_type *p) {

    total_types++;

    if (total_types == 1) {

        new_type = (region_type**) malloc (sizeof(region_type*));

    }
    else {

        new_type = (region_type**) realloc (new_type,total_types*sizeof(region_type*));

    }

    new_type[total_types-1]=p;
}

//_______________________________


class hospital_creation:public region_type {
    public:
    hospital_creation():region_type("hospital") {Register_Utility::register_new_type(this);}
    region* create() {return new hospital;}

}hospital_creation_instance;

class household_creation:public region_type {
    public:
    household_creation():region_type("household") {Register_Utility::register_new_type(this);}
    region* create() {return new household;}

}household_creation_instance;


void distribution (region **regions,float P,int total_regions) {

    int i,j;
    float sum=0;

    for (i=0;i<total_regions;i++) {

        sum+=regions[i]->retMaxP();

    }

    if (P>=sum) {

        for (i=0;i<total_regions;i++) {

            cout << "Region IDs that are going to be electrified.\n";
            cout << regions[i]->retID() << "\n";

        }
    }
    else {

        int Priority[total_regions];
        float deficit=P-sum;
        sum=0;

        //We assume that lower Priority number means higher priority
        for (i=0;i<total_regions;i++) {

            Priority[i]=regions[i]->retPriority();

        }

        for (i=0;i<total_regions;i++) {
            for (j=0;j<(total_regions-1);j++) {

                if (Priority[j]>Priority[j+1]) {

                    swap (Priority[j],Priority[j+1]);

                }
            }
        }

        int end=0;
        while (P<=sum) {

            sum+=regions[end]->retMaxP();
            end++;

        }

        for (i=0;i<(end-1);i++) {

            cout << "Region IDs that are going to be electrified.\n";
            cout << regions[end]->retID() << "\n";

        }
    }
}

int main () {

    float P;
    int i,j,total_regions=0,*regions_per_type;
    int total_region_types=Register_Utility::retTotal();
    region **regions;

    regions_per_type = new int[Register_Utility::total_types];

    cout << "Please type in the available Power";
    cin >> P;

    for (i=0;i<total_region_types;i++) {

        cout << "Please insert the number of " << Register_Utility::new_type[i]->return_name() << " regions: ";
        cin >> regions_per_type[i];

        total_regions+=regions_per_type[i];

    }

    regions =(region**) new region[total_regions];

    int k=0;
    for (i=0;i<total_region_types;i++) {
        for (j=0;j<regions_per_type[i];j++) {

            regions[k] = Register_Utility::new_type[i]->create();
            k++;
        }
    }

    distribution (regions,P,total_regions);
}





