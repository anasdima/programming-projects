#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <pthread.h>
#include <assert.h>

#define NTHREADS	8

#define N 		1048576*16
#define S 		20
#define PI 		3.141592653589

typedef struct {
	int level, boxid, parent, child[8], n,
		start, colleague[26];
	float center[3];
}Box;

typedef struct {
	Box cube;
	float cube_edge;
	int *parent_points,n_points;
}process_cube_args;

typedef struct {
	int start,end; // start and end store the first the the last box each thread is gonna process
}find_colleagues_args;

void *process_cube (void *arg);												
void generate_centers(float centers[8][3],float root[3],float cube_edge);
void *find_colleagues(void *arg);
float random_number (float max);


/*	 Global variables	*/
float **A, **B;
int reserved_ids;					// Used to reserve the next 8 slots in Box box[] each time the cube is about to be divided
int B_pointer;						// Used to point to the current element of matrix B
int leaf_pointer;					// Used to point to the current element of matrix leaf
int max_level;						// Used to keep track of the max level of depth in the tree
int *sorted_ids;					// Used to store all boxids sorted by level
int sorted_ids_pointer;				// Used to point to the current element of matrix sorted_ids
Box *box;							// Array of all boxes
Box *leaf;							// Array of non-null leaf boxes
pthread_mutex_t leaf_mtx;			// Used to create mutexes regarding leaf nodes
pthread_mutex_t parent_mtx;			// Used to create mutexes regarding reserved_ids and max_lvl
pthread_mutex_t sorted_ids_mtx;		// Used to create mutexes regarding sorted_ids_pointer


int main() {

	float theta,fi,r,cube_edge;
	int i,j,k,l,rc;
	int memory_allocation_time,generate_points_time,process_cube_time,find_colleagues_time,time_so_far,total_time;
	time_t start,semi_start,semi_end,end;

	/*	Initialize mutexes	*/

	pthread_mutex_init(&leaf_mtx, NULL);
	pthread_mutex_init(&parent_mtx, NULL);
	pthread_mutex_init(&sorted_ids_mtx,NULL);
	setbuf(stdout, NULL); 	// Disable stdout buffering so messages without newline chars get printed out instantly

	printf("Program started\n");
	printf("Allocating memory...");

	time(&start);			// Store time right now, essentially "start the clock"

	/*	 Allocate memory 	*/

	box = (Box *) malloc(0.35*N*sizeof(Box));
	leaf = (Box *) malloc(0.20*N*sizeof(Box));

	A = malloc(N*sizeof(*A));
	if (A == NULL) {
		fprintf (stderr, "Couldn't allocate memory\n");
		exit(0);
	}
	else {
		for (i = 0; i < N; i++) {
			A[i] = (float *) malloc(3*sizeof(**A));
			if ( A[i] == NULL) {
				fprintf (stderr, "Couldn't allocate memory\n");
				exit(0);
			}
		}
	}

	B = malloc(N*sizeof(*B));
	if (B == NULL) {
		fprintf (stderr, "Couldn't allocate memory\n");
		exit(0);
	}
	else {
		for (i = 0; i < N; i++) {
			B[i] = (float *) malloc(3*sizeof(**B));
			if ( B[i] == NULL) {
				fprintf (stderr, "Couldn't allocate memory\n");
				exit(0);
			}
		}
	}

	time(&semi_end);
	time_so_far 				= (int) difftime(semi_end,start);
	memory_allocation_time 		= (int) difftime(semi_end,start);
	printf ("done! It took %d seconds! %d seconds elapsed so far\n", memory_allocation_time,time_so_far);
	
	/*	Generate random points in sphere's surface using spherical coordinates	*/

	time(&semi_start);
	printf("Generating %d random points...",N);

	srand(time(NULL));	// seed rand() with timestamp

	for (i = 0 ; i < N ; i++) {

			r = 1.0;
			theta = random_number(90)*PI/180.0;
			fi = random_number(90)*PI/180.0;
			A[i][0] = r*sin(theta)*cos(fi); 
			A[i][1] = r*sin(theta)*sin(fi);
			A[i][2] = r*cos(theta);
	}

	time(&semi_end);
	time_so_far 			= (int) difftime(semi_end,start);
	generate_points_time 	= (int) difftime(semi_end,semi_start);
	printf ("done! It took %d seconds! %d seconds elapsed so far\n", generate_points_time,time_so_far);

	/*	Fill up the fields of the root box 	*/

	time(&semi_start);
	printf("Setting up cube and processing it...");

	box[1].center[0] = 0.5;
	box[1].center[1] = 0.5;
	box[1].center[2] = 0.5;
	box[1].level = 0;
	box[1].boxid = 1;
	box[1].n = N;
	box[1].start = 0;
	cube_edge = 1;
	reserved_ids = 1;
	max_level = 0;
	
	/*	Generate the first eight children 	*/
	
	int stored_id,child_id,next_level;
	float centers[8][3];
		
	stored_id = reserved_ids;							// Store the first id
	cube_edge = cube_edge/2;							// Each child's edge is half of the parent's

	reserved_ids += 8; 									// Reserve the next 8 ids
	generate_centers(centers,box[1].center,cube_edge);	// Generate each child's center
	next_level = box[1].level + 1;						// Store the next level
	max_level = next_level;								// New level

	process_cube_args arg[8];

	for (i=0;i<8;i++) {

		box[1].child[i] = stored_id + i + 1; 			// Each child's id is the (i+1)'th stored_id id

		/*	Fill up child's fields	*/		
		child_id = box[1].child[i];
		box[child_id].level = next_level;
		box[child_id].boxid = child_id;
		box[child_id].parent = box[1].boxid;
		box[child_id].center[0] = centers[i][0];
		box[child_id].center[1] = centers[i][1];
		box[child_id].center[2] = centers[i][2];

		/*	 Set up colleagues 	*/
		k=0;
		for(j=2;j<10;j++) {

			if(j!=child_id) {

				box[child_id].colleague[k] = j;
				k++;
			}
		}

		/*	 Prepare each thread's arguments 	*/
		arg[i].cube = box[child_id];
		arg[i].cube_edge = cube_edge;
		arg[i].parent_points = NULL;	
		arg[i].n_points = N;

	}

	/*	Create 8 parallel threads one for each of the first 8 children	*/

	pthread_t thread[NTHREADS];
	for (i=0;i<NTHREADS;i++) {

		rc = pthread_create(&thread[i],NULL,process_cube,(void *) &arg[i]);
		assert(rc == 0);														// Make sure that the thread was created successfully

	}

	for(i=0;i<NTHREADS;i++) {

		pthread_join(thread[i],NULL);
	}

	time(&semi_end);
	time_so_far 			= (int) difftime(semi_end,start);
	process_cube_time		= (int) difftime(semi_end,semi_start);
	printf ("done! It took %d seconds! %d seconds elapsed so far\n", process_cube_time,time_so_far);

	/*	 Find the colleagues of the cubes 	*/

	time(&semi_start);
	printf("Finding colleagues...");

	int *ids_in_level;			// Array that holds the number of ids in each level


	sorted_ids 		= (int *) malloc(reserved_ids*sizeof(*sorted_ids));
	ids_in_level 	= (int *) calloc((max_level+1),sizeof(*ids_in_level));		// Initialize each ids_in_level with 0 


	ids_in_level[0] = 1;		// Level 0 only has the cube-root
	ids_in_level[1] = 8;		// Level 1 only has the first 8 children


	for(i=1;i<10;i++) {

		sorted_ids[i] = box[i].boxid; // The ids of the first eight children are already sorted

	}

	/* Sort the boxids */

	k=9;
	for(j=2;j<=max_level;j++) {					// For each Level

		for(i=10;i<=reserved_ids;i++) {			// For each box

			if(box[i].level == j) {				// If the box is in this level

				k++;						
				sorted_ids[k] = box[i].boxid;	// Copy it to sorted_ids
				ids_in_level[j]++;				// And increment the total number of ids in this level
				
			}
		}
	}

	pthread_t colleague_thread[NTHREADS];
	find_colleagues_args colleague_arg[NTHREADS];

	sorted_ids_pointer = 10;		// Set sorted_ids_pointer to 9 since the first 9 boxes are already set

	for(j=2;j<=max_level;j++) {		// For each level

		for(i=0;i<NTHREADS;i++) {

				/*	 Divide the workshare of each thread to chunks of 	 */
				/*	 (ids_in_level[j]/NTHREADS).						 */ 

				colleague_arg[i].start   = i*(ids_in_level[j]/NTHREADS);
				colleague_arg[i].end	 = ids_in_level[j] - (7-i)*(ids_in_level[j]/NTHREADS);

				rc = pthread_create(&colleague_thread[i],NULL,find_colleagues,(void *) &colleague_arg[i]);
				assert(rc == 0);																			// Make sure that the thread was created successfully

		}

		for(i=0;i<NTHREADS;i++) {

			pthread_join(colleague_thread[i],NULL);
		}
	}


	time(&semi_end);
	time_so_far 				= (int) difftime(semi_end,start);
	find_colleagues_time 		= (int) difftime (semi_end,semi_start);
	printf ("done! It took %d seconds! %d seconds elapsed so far\n", find_colleagues_time,time_so_far);

	time(&end);	// Store time right now, essentially "stop the clock"
	total_time 	= (int) difftime (end,start);
	printf ("All done %d seconds elapsed\n", total_time);

	/*	  Check if the points of each leaf cube are within boundaries 	*/

	int points_within_boundaries=0;
	for (i=0; i<leaf_pointer; i++) {
			
		for (j=leaf[i].start; j<(leaf[i].start+leaf[i].n); j++) {

			if(fabs(B[j][0]-leaf[i].center[0]) <= pow(0.5,leaf[i].level)/2	// Leaf's edge is (1/2)^(leaf.level)
				&& fabs(B[j][1]-leaf[i].center[1]) <= pow(0.5,leaf[i].level)/2
				&& fabs(B[j][2]-leaf[i].center[2]) <= pow(0.5,leaf[i].level)/2) {

				points_within_boundaries++;
			}
		}
	}

	if (points_within_boundaries == B_pointer) {

		printf("All the points of each leaf cube are within boundaries!\n");
	}
	else {

		printf("Found %d points out of boundaries!\n", B_pointer-points_within_boundaries);
	}

	printf("\n--------------\nPoints in leafs\t:\t%d\nBoxes created\t:\t%d\nLeafs created\t:\t%d\nTree depth\t:\t%d\n",B_pointer,reserved_ids,leaf_pointer,max_level);
}

void *process_cube (void *arg) {


	Box cube;	
	int i,j,*local_points,*parent_points,n_points;					// Local points holds the indexes referring to matrix A of the points that are inside this cube
																	// while parent points are respectively the indexes of the parent. n_points is the total points in this cube
	float cube_edge;												// This cube's edge
	
	/*	Store thread arguments locally	*/

	cube			= ((process_cube_args *) arg)->cube;
	cube_edge		= ((process_cube_args *) arg)->cube_edge;
	parent_points 	= ((process_cube_args *) arg)->parent_points;
	n_points		= ((process_cube_args *) arg)->n_points;
	
	cube.n=0;

	local_points = malloc(n_points*sizeof(*local_points));
	
	/*	Find how many points does the cube include	*/
		
	if (cube.boxid >= 2 && cube.boxid <= 9) { 						// These are the first 8 cubes, so all of the points need to be examined

		for (i=0; i<n_points; i++) {

			if (fabs(A[i][0]-cube.center[0]) < cube_edge/2			// Checking if the vertical distance of each coordinate
				&& fabs(A[i][1]-cube.center[1]) < cube_edge/2		// from the center is less than half of the cube's edge
				&& fabs(A[i][2]-cube.center[2]) < cube_edge/2) {

				local_points[cube.n] = i;							// Store parent's index each time we find a point inside the cube
					
				cube.n++; 											// Increment cube's points
				
			}	
		}

	}
	else {	

		for (i=0; i<n_points; i++) {

			if (fabs(A[parent_points[i]][0]-cube.center[0]) < cube_edge/2		// Checking if the vertical distance of each coordinate
				&& fabs(A[parent_points[i]][1]-cube.center[1]) < cube_edge/2	// from the center is less than half of the cube's edge
				&& fabs(A[parent_points[i]][2]-cube.center[2]) < cube_edge/2) {

				local_points[cube.n] = parent_points[i];						// Store parent's index each time we find a point inside the cube
					
				cube.n++; 														// Increment cube's points
				
			}
		}
	}
		
	/*	Check if cube is empty, a leaf, or needs to be divided	*/

	if (cube.n == 0) {

		//cube.boxid = 0;
	
	}
	else if (cube.n <= S) {

		int stored_B_pointer=0;

		pthread_mutex_lock(&leaf_mtx);		// Lock critical section

		cube.start = B_pointer; 			// Copy B_pointer to cube.start, which right now points to the next free slot in B matrix
		B_pointer += cube.n;				// Increment B_pointer by cube.n so it can be used from another cube that wants to copy points
		stored_B_pointer = B_pointer; 		// Store B_pointer since B_pointer is global and it could be edited by another thread
		leaf[leaf_pointer] = cube;			// This cube is a leaf
		leaf_pointer++;						// Increment leaf_pointer by 1 so it points to the next free slot in leaf matrix

		pthread_mutex_unlock(&leaf_mtx);	// Unlock critical section

		j=0;

		for (i=cube.start; i<stored_B_pointer; i++) {

			B[i][0] = A[local_points[j]][0];
			B[i][1] = A[local_points[j]][1];
			B[i][2] = A[local_points[j]][2];

			j++;
		}
	}
	else if (cube.n > S) {

		int stored_id,child_id,next_level;
		float centers[8][3];

		cube_edge = cube_edge/2;							// Each child's edge is half of the parent's		
		generate_centers(centers,cube.center,cube_edge);	// Generate 8 new centers for the children		
		next_level = cube.level + 1;						// Move to the next level

		pthread_mutex_lock(&parent_mtx);					// Lock critical section
		stored_id = reserved_ids;							// Since reserved_ids is global we need to store the first id in this scope in case
		reserved_ids += 8; 									// Reserve the next 8 ids
		if(next_level > max_level) {						// Check if this is a new level
			max_level = next_level;
		}
		pthread_mutex_unlock(&parent_mtx);					// Unlock critical section

		process_cube_args child_arg[8];

		for (i = 0; i < 8; i++) {

			cube.child[i] = stored_id + i + 1;				// Each child's id is the (i+1)'th stored_id id

			/*	Fill up child's fields	*/
			child_id = cube.child[i];
			box[child_id].level = next_level;
			box[child_id].boxid = child_id;
			box[child_id].parent = cube.boxid;
			box[child_id].center[0] = centers[i][0];
			box[child_id].center[1] = centers[i][1];
			box[child_id].center[2] = centers[i][2];

			/*	 Prepare function's arguments	*/
			child_arg[i].cube = box[child_id];
			child_arg[i].cube_edge = cube_edge;
			child_arg[i].parent_points = local_points;
			child_arg[i].n_points = cube.n;

			process_cube((void*) &child_arg[i]);			// Recursively call process_cube for each child
		}

	}

	free(local_points);

	box[cube.boxid] = cube;
	
}

void generate_centers(float centers[8][3],float parent_center[3],float cube_edge) { // cube_edge is the edge of the cubes to be created

	float x[2],y[2],z[2];
	int i,j,k,l;

	/* Calculate all the coordinates of the centers */

	x[0] = parent_center[0] + cube_edge/2;
	x[1] = parent_center[0] - cube_edge/2;

	y[0] = parent_center[1] + cube_edge/2;
	y[1] = parent_center[1] - cube_edge/2;

	z[0] = parent_center[2] + cube_edge/2;
	z[1] = parent_center[2] - cube_edge/2;

	/* Copy the coordinates to matrix centers */

	l=0;
	for (i=0;i<2;i++) {
		for (j=0;j<2;j++) {
			for (k=0;k<2;k++) {
				centers[l][0]=x[i];
				centers[l][1]=y[j];
				centers[l][2]=z[k];
				l++;
			}
		}
	}
}

void *find_colleagues(void *arg) {

	int i,j,k,l,start,end,local_pointer;							// Local pointer stores a copy of the global sorted_ids_pointer

	start = ((find_colleagues_args *)arg)->start;
	end   = ((find_colleagues_args *)arg)->end;

	for(i=start;i<end;i++) {										// For each box in this range

		l=0;														// Reset the colleague counter
		pthread_mutex_lock(&sorted_ids_mtx);						// Lock critical section
		local_pointer = sorted_ids_pointer;							// Store the current sorted_ids_pointer localy
		sorted_ids_pointer++;										// Increment sorted_ids_pointer by one
		pthread_mutex_unlock(&sorted_ids_mtx);						// Unlock critical section

		for(k=0;k<8;k++) {											// For each box's parent's child


			/*	Check if this child of this box's parent is a colleague of the box.	We do that		*/
			/*	by checking if the distance^2 between the two centers is less or equal to 3  		*/
			/*	times of the cube's edge (detailed explanation in the report)						*/

			if(box[box[sorted_ids[local_pointer]].parent].child[k] != sorted_ids[local_pointer] ) { // Lets not examine ourselves!

				if(pow(box[sorted_ids[local_pointer]].center[0]-box[box[box[sorted_ids[local_pointer]].parent].child[k]].center[0],2)
					+ pow(box[sorted_ids[local_pointer]].center[1]-box[box[box[sorted_ids[local_pointer]].parent].child[k]].center[1],2)
					+ pow(box[sorted_ids[local_pointer]].center[2]-box[box[box[sorted_ids[local_pointer]].parent].child[k]].center[2],2)
					<= 3*pow(pow(0.5,box[sorted_ids[local_pointer]].level),2)) {	// Cube's edge is (1/2)^cube.level

						box[sorted_ids[local_pointer]].colleague[l] = box[box[sorted_ids[local_pointer]].parent].child[k];
						l++;
				}
			}
		}

		for(j=0;j<26;j++) {											// For each parent's colleague

			for(k=0;k<8;k++) {										// For each parent's colleague's child

			/*	Check if this child of this colleague of this box's parent is a colleague of the box.	*/	
			/*	We do that by checking if the distance^2 between the two centers is less   				*/
			/*	or equal to 3 times of the cube's edge (detailed explanation in the report)				*/

				if (pow(box[sorted_ids[local_pointer]].center[0]-box[box[box[box[sorted_ids[local_pointer]].parent].colleague[j]].child[k]].center[0],2)
					+ pow(box[sorted_ids[local_pointer]].center[1]-box[box[box[box[sorted_ids[local_pointer]].parent].colleague[j]].child[k]].center[1],2)
					+ pow(box[sorted_ids[local_pointer]].center[2]-box[box[box[box[sorted_ids[local_pointer]].parent].colleague[j]].child[k]].center[2],2) 
					<= 3*pow(pow(0.5,box[sorted_ids[local_pointer]].level),2)) {	// Cube's edge is (1/2)^cube.level

					box[sorted_ids[local_pointer]].colleague[l] = box[box[box[box[sorted_ids[local_pointer]].parent].colleague[j]].child[k]].boxid;
					l++;					
				}
			}
		}
	}
}

float random_number (float max) { // calculate random number between 0.0 and max using rand()

	return (float)rand()/(float)(RAND_MAX) * max;

}

