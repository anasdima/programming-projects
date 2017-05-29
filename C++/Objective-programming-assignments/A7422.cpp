#include <iostream>
#include <cstring>
using namespace std;

class member {
    int ID,Friends[10];
    char Name[20],LoginName[20],Pwd[20];
    public:
    member();
    int TotalFriends; //TotalFriends doesn't actually hold the total friends, its max number is 9. (It's used for array indexing)
    //Admin functions
    void addid(int i);
    void addstr(char str1[],char str2[],char str3[]);
    //Member functions
    int Authentication1(char uname[]);
    int Authentication2(char pass[]);
    int Search(char search[]);
    void AddFriend(int j);
    void DeleteFriend(int j);
    int ReturnFriendsID(int i);
    void PrintName();
};

member::member() {
    TotalFriends=0;
}

void member::addid(int i) {
    ID = i;
}

void member::addstr(char str1[],char str2[],char str3[]) {
    strcpy (Name,str1);
    strcpy (LoginName,str2);
    strcpy (Pwd,str3);
}

int member::Authentication1(char uname[]){
    return strcmp(uname,LoginName);
}

int member::Authentication2(char pass[]){
    return strcmp(pass,Pwd);
}

int member::Search(char search[]) {
    return strcmp (search,Name);
}

void member::AddFriend(int j){
    int i,flag=0;
    if (TotalFriends<9) {
        for (i=0;i<=TotalFriends;i++){
            if (Friends[i]==j){
                cout << "This user is already on your friend list!\n";
                flag=1;
                break;
            }
        }
        if (flag!=1) {
            Friends[TotalFriends]=j;
            TotalFriends++;
            cout << "Friend successfully added!\n";
        }
    }
    else {
        cout << "You have exceeded your friends limit (which is 10).\nIf you want to add a new friend you must first\ndelete one";
    }
}


void member::DeleteFriend(int j) {
    int i,flag=0;
    for (i=0;i<=TotalFriends;i++) {
        if (Friends[i]=j) {                    //When the specified Friend ID is found
            for (i;i<TotalFriends;i++) {       //we "shift" the array, one element to the left, so that
                Friends[i]=Friends[i+1];       //the id is replaced and hence removed from the list
                flag=1;
            }
            Friends[TotalFriends]=-1; //This covers the case where TotalFriends is 9, so that the last 2 elements are not the same
            TotalFriends--;
            break;
        }
    }
    if (flag==0) {
        cout << "The specified user is not on your friend list\n";
    }
    else {
        cout << "Friend successfully deleted\n";
    }
}

int member::ReturnFriendsID(int i) {
    return Friends[i];
}

void member::PrintName() {
    cout << "\n" << Name << "\n";
}


int main () {
    int choice,i,N;
    char admin[]="admin",adminpwd[]="admin",search[20],a[20],b[20];;
    cout << "*****************************************\n" << "Welcome to the Site Interface v1.0!\n" << "*****************************************\n" << "Please insert the number of your members:\n";
    cin >> N;
    member *members = new member[N];
    cout << "-------Administrator Panel-------\n1.New member entry\n2.Exit\n->";
    cin >> choice;
    i=0;
    while (1 == 1) {
        //New member registration
        if (choice == 1) {
            char Name[20],LoginName[20],Pwd[20];
            members[i].addid(i);
            cout << "*New member registration*\nName: ";
            cin >> Name;
            cout << "Login Name: ";
            cin >> LoginName;
            cout << "Password: ";
            cin >> Pwd;
            members[i].addstr(Name,LoginName,Pwd);
            i++;
        }
        //Admin logout
        else {
            do {
                cout << "Administrator user name: ";
                cin >> a;
                cout << "Administrator Password: ";
                cin >> b;
            }while (strcmp(a,admin)!=0 || strcmp(b,adminpwd)!=0);
            cout <<"Administrator Panel: Logout successfull.\n";
            break;
        }
    cout << "1.New member entry\n2.Exit\n->";
    cin >> choice;
    }
    //Member Login
    while (1==1) {
        cout << "-------Member Panel-------\n1.Login\n2.Exit\n->";
        cin >> choice;
        if (choice == 1) {
            char uname[20],pass[20];
            int j,flag=0,success=0;
            cout << "-----------------\nWelcome to the site!\n-----------------\nLogin Name: ";
            cin >> uname;
            cout << "Password: ";
            cin >> pass;
            while (success==0){
                for (i=0;i<N;i++){
                    if (members[i].Authentication1(uname)==0 && members[i].Authentication2(pass)==0) {
                        flag=1;
                        break;
                    }
                }
                if (flag==1) {
                    cout << "Success!\n";
                    success=1;

                }
                else {
                    cout << "Wrong credentials, please try again.\n";
                    cout << "Login Name: ";
                    cin >> uname;
                    cout << "Password: ";
                    cin >> pass;
                }
            }
            //Let's point out that i is now storing the ID of the logged in member.
            cout << "Choose one of the following options:\n1.Search a member\n2.Add a friend\n3.Delete a friend\n4.Print your Friend List\n5.Logout\n->";
            cin >> choice;
            while (choice==1 || choice==2 || choice==3 || choice==4) {
                switch (choice) {
                    case 1:
                    cout << "Please type in the name of the member you want to search for:\n";
                    cin >> search;
                    flag=0;
                    for (j=0;j<N;j++){
                        if (members[j].Search(search)==0){
                            flag=1;
                            cout << "Member found!\n";
                            break;
                        }
                    }
                    if (flag!=1) {
                        cout << "The specified username could not be found\n";
                    }
                    break;
                    case 2:
                    cout << "Please type in the name of the member you want to add:\n";
                    cin >> search;
                    flag=0;
                    for (j=0;j<N;j++){
                        if (members[j].Search(search)==0){
                            members[i].AddFriend(j);
                            flag=1;
                            break;
                        }
                    }
                    if (flag!=1) {
                        cout << "The specified username could not be found\n";
                    }
                    break;
                    case 3:
                    cout << "Please type in the name of the friend you want to delete:\n";
                    cin >> search;
                    flag=0;
                    for (j=0;j<N;j++){
                        if (members[j].Search(search)==0){
                            flag=1;
                            members[i].DeleteFriend(j);
                            break;
                        }
                    }
                    if (flag!=1) {
                        cout << "The specified username could not be found\n";
                    }
                    break;
                    case 4:
                    if (members[i].TotalFriends==0) {
                        cout << "You do not have any friends!\n";
                    }
                    else {
                        //Find the IDs of the friends, and index each one of them into the members[] array.
                        //Call the PrintName function of the members[] object, and print the name of the friend with the id we just indexed.
                        for (j=0;j<members[i].TotalFriends;j++){
                        members[members[i].ReturnFriendsID(j)].PrintName();
                        }
                    }
                    break;
                }
                cout << "Choose one of the following options:\n1.Search a member\n2.Add a friend\n3.Delete a friend\n4.Print your Friend List\n5.Logout\n->";
                cin >> choice;
            }
            cout << "You have succesfully logged out.\n";
        }
        else {
            cout << "Member Panel: Logout successfull.\n";
            do {
                cout << "Administrator user name: ";
                cin >> a;
                cout << "Administrator Password: ";
                cin >> b;
            }while (strcmp(a,admin)!=0 || strcmp(b,adminpwd)!=0);
            cout << "System: Logout successfull.\n";
            break;
        }
    }
}






















