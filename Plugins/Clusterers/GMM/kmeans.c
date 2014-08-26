//
//  kmeans.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#include "kmeans.h"

//  A simple parallel k-means implementation.
//  Possible improvements include using BLAS to calculate sample to centroid 
//  distances, tracking whether centroids have moved instead of whether 
//  assignments have changed (better when N >> D), and modifying the code to
//  run in one large parallel region, instead of two inside the while loop.
//  We could also use Elkan's triangle equality trick and a variety of other
//  optimizations. This code serves its purpose as a reasonably fast implementation
//  that simply illustrates how to use libdispatch.
void *kmeans(float *data, unsigned int n, unsigned int d, unsigned int k, unsigned int r, int *assignment) {
  
  float *centroids = (float *)malloc(k * d * sizeof(float));
  int *assignment_changed = (int *)malloc(n * sizeof(int));
  int *cur_assignment = (int *)malloc(n * sizeof(int));
  
  int num_changed_points;
  int num_iterations;
  int max_iterations = 1000000;
  
  float min_cost, cur_cost;
  min_cost = FLT_MAX;
  
  dispatch_queue_t queueK = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
  
  //  We could do the runs in parallel too, but that would require more memory and
  //  coordination when writing the best current solution.
  for(int run = 0; run < r; run++) {
    num_iterations = 0;
    
    for(int i = 0; i < k; i++) {
      int sample_centroid = rand() % n;
      for(int j = 0; j < d; j++) {
        // Could double sample, but we check for orphan centroids
        centroids[i * d + j] = data[sample_centroid * d + j];
      }
    }
    
    while(num_iterations < max_iterations) {
      
      // This is the parallel version of:
      //
      // for(j = 0; j < n; j++) {
      //
      // As long as each loop iteration doesn't depend on the other (in other words
      // the operation can be thought of as a map function) this works nicely.
      //
      // Update point assignments.
      dispatch_apply(n, queueK, ^(size_t j) {
        float min_distance = FLT_MAX;
        float distance;
        int previous_assignment = cur_assignment[j];
        
        for(int l = 0; l < k; l++)
        {
          distance = 0.f;
          
          for(int m = 0; m < d; m++)
            distance += (data[j * d + m] - centroids[l * d + m]) * (data[j * d + m] - centroids[l * d + m]);
          
          if(distance < min_distance)
          { 
            min_distance = distance;
            cur_assignment[j] = l;
          }
        }
        
        if(cur_assignment[j] == previous_assignment)
          assignment_changed[j] = 0;
        else
          assignment_changed[j] = 1;
        
      });
      
      num_changed_points = 0;
      for (int o = 0; o < n; o++)
        num_changed_points += assignment_changed[o];
      
      if(num_changed_points == 0)
        break;
      
      // Move the centroids to the center of their assigned points.
      dispatch_apply(k, queueK, ^(size_t j) {
        int sample_centroid;
        int num_assigned_points = 0;
        
        for(int l = 0; l < d; l++)
          centroids[j * d + l] = 0.f;
        
        for(int m = 0; m < n; m++)
          if(cur_assignment[m] == j)
          {
            num_assigned_points++;
            for(int l = 0; l < d; l++)
              centroids[j * d + l] += data[m * d + l];
          }
        
        if(num_assigned_points != 0)
          for(int l = 0; l < d; l++)
            centroids[j * d + l] /= num_assigned_points;
        else {
          sample_centroid = rand() % n;
          for(int l = 0; l < d; l++)
            centroids[j * d + l] = data[sample_centroid * d + l];
        }
      });
      
      num_iterations++;
    }
    
    // Calculate the final cost
    float distance;
    cur_cost = 0.f;
    for(int i = 0; i < n; i++) {
      distance = 0.f;
      
      for(int j = 0; j < d; j++)
        distance += (data[i * d + j] - centroids[cur_assignment[i] * d + j]) * (data[i * d + j] - centroids[cur_assignment[i] * d + j]);
      
      cur_cost += distance;
    }
      
    
    // If this is the best solution so far, copy it to the output.
    if (cur_cost < min_cost) {
      min_cost = cur_cost;
      for(int i = 0; i < n; i++)
        assignment[i] = cur_assignment[i];
    }
  }
  
  free(centroids);
  free(assignment_changed);
  free(cur_assignment);
    
    return 0;
}