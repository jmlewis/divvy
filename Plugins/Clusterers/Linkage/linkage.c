/*
 *  linkage.c
 *  Divvy
 *
 *  Created by Joshua Lewis on 8/22/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "linkage.h"

void linkage(float *data, unsigned int n, unsigned int d, unsigned int k, unsigned int complete, int *assignment) {
  float *distance_out = (float *)malloc(sizeof(float) * n * (n - 1) / 2);
  dendrite *dendrogram_out = (dendrite *)malloc(sizeof(dendrite) * (n - 1));
  
  distance(n, d, data, distance_out);
  dendrogram(n, complete, distance_out, dendrogram_out);
  assignLaunch(dendrogram_out, k, n, assignment);
  
  free(distance_out);
  free(dendrogram_out);
}


// This needs to be cleaned up and rewritten to support complete and average linkage
void dendrogram(int N, int complete, float *distance, dendrite *result) {
	int i, j, k;
	int * nearest = (int *)malloc((N - 1) * sizeof(int));
	int * bookkeep = (int *)malloc(N * sizeof(int));
	int * ncopy = (int *)malloc((N - 1) * sizeof(int));
	float * minima = (float *)malloc((N - 1) * sizeof(float));
	float min = FLT_MAX;
	float ndist;
	int mindex, groupA, groupB;
	
	//step 1: make two arrays of size n-1: row minima and nearest neighbors
	for(i = 0; i < N - 1; i++) {
		min = FLT_MAX;
		for(j = i + 1; j < N; j++) 
			if (distance[j*(j-1)/2+i] < min) {
				min = distance[j*(j-1)/2 +i];
				mindex = j;
			}
		minima[i] = min;
		nearest[i] = mindex;
		ncopy[i] = mindex;
	}
	
	for(i = 0; i < N; i++)
		bookkeep[i] = i;
	
	//	for(i = 0; i < (N-1); i++)
	//		printf("%i \t", i);
	//	printf("\t\t\t");
	//	for(i = 0; i < N; i++)
	//		printf("%i \t", i);
	//	printf("\t\t\t");
	//	for(i = 0; i < (N-1); i++)
	//		printf("%i \t", i);
	//	printf("\n\n");
	
	// steps 2-5
	for (j = 0; j < (N-1); j++) {
		//for (i = 0; i < N - 1; i++)
		//printf("%i %f \n", nearest[i], minima[i]);
		min = FLT_MAX;
		//find minimum and index of minimum in minima
		for (i = 0; i < (N-1); i++) {
			if (minima[i] < min) {
				min = minima[i];
				mindex = i;
			}
		}
		
		result[j].i = bookkeep[mindex];
		result[j].j = nearest[mindex];
		result[j].distance = min;
		
		if(nearest[mindex] > N - 1) // check for group origin and switch if necessary
			for(i = 0; i < N - 1; i++) {
				if(bookkeep[i] == nearest[mindex] && i < mindex) {
					result[j].i = result[j].j;
					result[j].j = bookkeep[mindex];
					ncopy[i] = mindex;
					mindex = i;
				}
				if(bookkeep[i] == nearest[mindex] && i < ncopy[mindex])
					ncopy[mindex] = i;
			}
		
		//		for(i = 0; i < (N-1); i++)
		//			printf("%i \t", nearest[i]);
		//		printf("\t\t\t");
		//		for(i = 0; i < N; i++)
		//			printf("%i \t", bookkeep[i]);
		//		printf("\t\t\t");
		//		for(i = 0; i < (N-1); i++)
		//			printf("%i \t", minima[i] == FLT_MAX);
		//		printf("\n");
		
		groupA = bookkeep[mindex];
		groupB = bookkeep[ncopy[mindex]];
		
		//absorb cluster and update nearest neighbors
		for (i = 0; i < (N-1); i++) {
			//	printf("%i %i %i \n", nearest[i], ncopy[mindex], bookkeep[mindex]);
			if (nearest[i] == groupA || nearest[i] == groupB && i != mindex && i != ncopy[mindex])
				nearest[i] = N + j;				
		}
		
		for(i = 0; i < N; i++) {
			if (bookkeep[i] == groupA || bookkeep[i] == groupB)
				bookkeep[i] = N + j;
			if (i > ncopy[mindex]) {
				ndist = distance[i*(i-1)/2 + ncopy[mindex]];
				if ((complete ? ndist > distance[i*(i-1)/2 + mindex] : ndist < distance[i*(i-1)/2 + mindex]))
					distance[i*(i-1)/2 + mindex] = ndist;
			}
			if(i > mindex && i < ncopy[mindex]) {
        if(complete)
          ndist = fmax(distance[i*(i-1)/2 + mindex], distance[ncopy[mindex] * (ncopy[mindex] - 1) / 2 + i]);
        else
          ndist = fmin(distance[i*(i-1)/2 + mindex], distance[ncopy[mindex] * (ncopy[mindex] - 1) / 2 + i]);
				distance[i*(i-1)/2 + mindex] = ndist;
				//distance[ncopy[mindex] * (ncopy[mindex] - 1) / 2 + i] = ndist;
			}
			if(i < mindex && i < ncopy[mindex]) {
        if(complete)
          ndist = fmax(distance[mindex * (mindex - 1) / 2 + i], distance[ncopy[mindex] * (ncopy[mindex] - 1) / 2 + i]);
        else
          ndist = fmin(distance[mindex * (mindex - 1) / 2 + i], distance[ncopy[mindex] * (ncopy[mindex] - 1) / 2 + i]);
				distance[mindex * (mindex - 1) / 2 + i] = ndist;
				//distance[ncopy[mindex] * (ncopy[mindex] - 1) / 2 + i] = ndist;
			}
		}
		
		//replace minima[NN[i]] with FLT_MAX
		minima[ncopy[mindex]] = FLT_MAX;
		distance[ncopy[mindex]*(ncopy[mindex]-1)/2 + mindex] = FLT_MAX;
		
		//		for (i = 0; i < N-1; i++)
		//			if (bookkeep[i] == N + j && i != mindex)
		//				minima[i] = FLT_MAX;
		
		//find new minimum of row i
		i = mindex;
		min = FLT_MAX;
		for (k = i + 1; k < N; k++)
			if (distance[k*(k-1)/2 + i] < min && minima[k] != FLT_MAX) {
				min = distance[k*(k-1)/2 +i];
				mindex = k;
				//printf("%i %i %i \t",i,  k, ncopy[i]);
			}
		//printf("\n");
		minima[i] = min;
		nearest[i] = bookkeep[mindex];
		ncopy[i] = mindex;
		
	}		
	
	free(minima);
	free(ncopy);
	free(nearest);
	free(bookkeep);
	return;
}

void assignLaunch(dendrite *dendrogram, int k, int N, int *assignment) {
	int curK = 0;
	int index = 0;
	for(int i = 0; i < k - 1; i++) {
    index = N - i - 2;
    if(dendrogram[index].i < N)
      assignment[dendrogram[index].i] = curK++;
    else if(dendrogram[index].i <= 2 * (N - 1) - (k - 1))
      assign(dendrogram, dendrogram[index].i - N, curK++, N, assignment);
    if(dendrogram[index].j < N)
      assignment[dendrogram[index].j] = curK++;
    else if(dendrogram[index].j <= 2 * (N - 1) - (k - 1))
      assign(dendrogram, dendrogram[index].j - N, curK++, N, assignment);
  }
}

void assign(dendrite *dendrogram, int line, int k, int N, int *assignment) {
  if(dendrogram[line].i < N)
    assignment[dendrogram[line].i] = k;
  else
    assign(dendrogram, dendrogram[line].i - N, k, N, assignment);
  if(dendrogram[line].j < N)
    assignment[dendrogram[line].j] = k;
  else
    assign(dendrogram, dendrogram[line].j - N, k, N, assignment);
}
