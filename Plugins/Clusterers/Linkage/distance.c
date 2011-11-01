/*
 *  distance.c
 *  Divvy
 *
 *  Created by Joshua Lewis on 8/22/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "distance.h"

// Calculate distances with matrix/matrix operations (BLAS3)
void distance(int N, int D, float *data, float *result) {
	int blockSize = 50;
  int blockCount = N / blockSize;
  
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  
	float *diag = (float *)malloc(sizeof(float) * N);
  float *C = (float *)malloc(blockCount * blockSize * blockSize * sizeof(float));
  
  dispatch_apply(blockCount, queue, ^(size_t m) {
    int i, j;
    
    cblas_sgemm(CblasColMajor, CblasTrans, CblasNoTrans, blockSize, blockSize, D,
                1, &data[m * blockSize * D], D,
                &data[m * blockSize * D], D, 0,
                &C[m * blockSize * blockSize], blockSize);
    
    for(i = 0; i < blockSize; i++)
      diag[m * blockSize + i] = C[m * blockSize * blockSize + i * (blockSize + 1)];
    
    for(i = 0; i < blockSize; i++)
      for(j = i + 1; j < blockSize; j++)
        result[utndidx(i + m * blockSize, j + m * blockSize)] = \
        sqrt(diag[i + m * blockSize] + diag[j + m * blockSize] - \
             2 * C[m * blockSize * blockSize + j * blockSize + i]);
  });
  
  dispatch_apply(blockCount, queue, ^(size_t m) {
    int i, j, o;
    for(o = m + 1; o < blockCount; o++)
    {
      cblas_sgemm(CblasColMajor, CblasTrans, CblasNoTrans, blockSize, blockSize, D,
                  1, &data[m * blockSize * D], D,
                  &data[o * blockSize * D], D, 0,
                  &C[m * blockSize * blockSize], blockSize);
      
      for(j = 0; j < blockSize; j++)
        for(i = 0; i < blockSize; i++)
          result[utndidx(j + m * blockSize, i + o * blockSize)] = \
          sqrt(diag[i + o * blockSize] + diag[j + m * blockSize] - \
               2 * C[m * blockSize * blockSize + i * blockSize + j]);
    }
  });
  
  free(C);
  free(diag);
  
  return;
}