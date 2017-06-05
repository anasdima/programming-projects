# programming-projects

## Ruby

### Preprocessing scripts

Developed for Pattern Recognition projects. Their purpose is to read data from files and prepare them for machine training. The most notable of them is csv_reader.rb.

csv_reader.rb integrates a set of preprocessing techniques to be applied in a dataset with a time series format. These techniques can be accessed through a menu. Through this menu the user can

* Split & merge datasets
* Sample the dataset (per day, hour, minute etc)
* Create metrics in the dataset (like avg, sum, min, max)
* Detect outliers
* Clean unwanted values
* Perform attribute convertions
* Select attributes
* arff to csv filetype convertion

The outlier detection functionality synergizes with a MATLAB script.

### HMMYStat

A demo showing database functionality through a web app. The database holds university student statistics. HMMYStat works with the database through tiny_tds, receives web input from with the help of sinatra and plots requested data with nyaplot.

### Database population script

Script to fill a newly designed MySQL database with random data for trigger testing and showcase examples.

### eTHMMY & thmmy.gr agents

Agents developed to track changes in student websites. Originally forked from https://github.com/iodim/thmmy-notifier, eTHMMY agent can detect new announcements posted in the eTHMMY platform by crawling the announcement post time. Similarily the thmmy.gr agent detects new posts in a specific thread of the thmmy.gr website.

### Chatbot for Mumble

Features:

* Read, process, log and post messages in chat
* Manage users in a database, edit their respective ACL rights, check user authorization
* Command execution on demand, command authorization based on user rights
* Play music through mpd
* Initial parameterization through .ini file
* Synergy with Dropbox through a filewatcher library
* Synergy with bot to restart the Mumble server
* Synergy with the eTHMMY agent to post announcements in chat
* Multithreading

### Chatbot for Slack

* Read, process, log and post messages in chat
* Command execution on demand
* Multithreading
* Synergy with eTHMMY and thmmy.gr agents to post announcements and files in chat
* Synergy with Dropbox through a filewatcher library
* Initial parameterization through .ini file

### IEEEXtreme Programing contests

Algorithms that solve IEEEXtreme Programming contest challenges. The challenges were of mathematical, logic, computational and programming nature. The algorithms were developed while participating at 8 & 9 IEEEXtreme Programming Contests with a 3-person team.

### Mathematics

Discrete mathematics algorithms that solve adjacency, incidence and weights problems in the subject of graph theory

## Python

### Diploma Thesis

Information about the python software I developed for my Thesis can be found here:
https://github.com/anasdima/gherkin2oas

## Java

### Network programming

Development of serial and socket network communications. The programs can send and receive network packets, manage connection speed and store received data in text, image, and sound format. In the socket communications program, an AQDPCM decoding algorithm was developed.

### AI Player in RTS Game

Patched existing novice AI player with heuristic code in order to beat another AI player in an RTS game.

# C

### CUDA, MPI, PTHREADS, OPENMP

* Cube spliting

Three programs were developed: one serial, one with PTHREADS and one with OPENMP. 

* K-means

A K-means algorithm implementation with the Message Passing Interface

* K-NN

A K-NN algorithm implementation with CUDA on an NVIDIA gpu

* LSH 

A LSH algorithm implementation with CUDA an an NVIDIA gpu

### IEEEXtreme Programing contests

Algorithms that solve IEEEXtreme Programming contest challenges. The challenges were of mathematical, logic, computational and programming nature. The algorithms were developed while participating at 8 & 9 IEEEXtreme Programming Contests with a 3-person team.

### Mathematics

A program that detects if two graphs are isomorphic

### Real time measurements

A program that tries to detect as fast as possible a change in memory and measures the detection time. The program is multithreaded and it was developed as part of an Embedded Systems university course. In order to better organize the time measurements, bash test scripts were written.

## C, C++ and Assembly assignments

Assignments for the respective university courses

## Summary

github.com/AlDanial/cloc v 1.72

| Language          |          files   |        blank   |      comment     |       code 
| ----------------- |:----------------:|:--------------:|:----------------:| ----------:
| Ruby              |             39   |          447   |          167     |       3243 
| Python            |             11   |          123   |          109     |       2145 
| C                 |             21   |          862   |          166     |       2721 
| CUDA              |              2   |          219   |           22     |        409 
| Java              |             24   |         1211   |          150     |       4389 
| C++               |              7   |          369   |           26     |       1100 
| Assembly          |              7   |          531   |           84     |       1046 
| Bourne Shell      |              4   |            4   |            0     |         66 
| **SUM**:          |        **115**   |     **3766**   |      **724**     |  **15119**


