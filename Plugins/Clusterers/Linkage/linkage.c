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

void dendrogram(int N, int complete, float *distance, dendrite *result) {
	int i, j;
  
  float *minima = (float *)malloc((N - 1) * sizeof(float));
	int *nearest_neighbors = (int *)malloc(N * sizeof(int)); // Use N due to memory reuse below
	
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);  
  
	// Find nearest neighbors
	dispatch_apply(N - 1, queue, ^(size_t i) {
		minima[i] = FLT_MAX;
		for(int j = i + 1; j < N; j++) 
			if (distance[j * (j - 1) / 2 + i] < minima[i]) {
				minima[i] = distance[j * (j - 1) / 2 + i];
				nearest_neighbors[i] = j;
			}
	});
	
  // Join the two closest clusters in each iteration
	for (j = 0; j < N - 1; j++) {
		result[j].distance = FLT_MAX;
		
    // Find the minimum distance
		for (i = 0; i < N - 1; i++) {
			if (minima[i] < result[j].distance) {
				result[j].distance = minima[i];
				result[j].i = i;
			}
		}
		result[j].j = nearest_neighbors[result[j].i];
    
    // Update distances
    dispatch_apply(N, queue, ^(size_t i) {
      int indexI, indexJ; // Indices into the upper triangular distance matrix (sometimes to the non-existent diagonal, but we ignore those cases)
      indexI = i <= result[j].i ? result[j].i * (result[j].i - 1) / 2 + i : i * (i - 1) / 2 + result[j].i;
      indexJ = i <= result[j].j ? result[j].j * (result[j].j - 1) / 2 + i : i * (i - 1) / 2 + result[j].j;
      
      if (i == result[j].i)
        distance[indexJ] = FLT_MAX; // Remove D(i, j)
      else if (i != result[j].j) { // We've already removed D(i, j), so ignore this case
        if (distance[indexI] > distance[indexJ]) distance[indexI] = distance[indexJ]; // Take shorter distances
        distance[indexJ] = FLT_MAX; // Remove all j distances
      }
    });
      
    // This point can no longer be joined
    minima[result[j].j] = FLT_MAX;
    
    // Find a new nearest neighbor for i + j
    minima[result[j].i] = FLT_MAX;
		for (i = result[j].i + 1; i < N; i++) {
      if (distance[i * (i - 1) / 2 + result[j].i] < minima[result[j].i]) {
        minima[result[j].i] = distance[i * (i - 1) / 2 + result[j].i];
        nearest_neighbors[result[j].i] = i;
      }
		}
    
    // Update j's neighbors to reference i
    dispatch_apply(N - 1, queue, ^(size_t i) {
      if (nearest_neighbors[i] == result[j].j) nearest_neighbors[i] = result[j].i;
    });
	}
  
  // Add group numbers for assign, reuse nearest_neighbors memory for convenience to track groups
  nearest_neighbors[N - 1] = 0; // Clear out the memory uninitialized from above
  for(i = 0; i < N - 1; i++) {
    int baseGroup = -1;
    if (nearest_neighbors[result[i].i] > N - 1)
      baseGroup = nearest_neighbors[result[i].i];
    
    nearest_neighbors[result[i].i] = N + i; // Group number
    
    if (baseGroup > N - 1)
      result[i].i = baseGroup;
    if (nearest_neighbors[result[i].j] > N - 1)
      result[i].j = nearest_neighbors[result[i].j];
  }
	
	free(minima);
	free(nearest_neighbors);
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
