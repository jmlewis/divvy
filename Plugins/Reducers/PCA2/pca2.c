/*
 *  pca.cpp
 *  Divvy
 *
 *  Created by Laurens van der Maaten on 8/16/11.
 *  Copyright 2011 Delft University of Technology. All rights reserved.
 *
 */

#include "pca.h"
#include <string.h>
#include <Accelerate/Accelerate.h>


void reduce_data(float* X, int D, int N, float* Y, int no_dims) {
    
    // TODO: Use dispatch here!!!
    
    // Make copy of the data
    float* XX = (float*) malloc(N * D * sizeof(float));
    memcpy((void*) XX, (void*) X, N * D * sizeof(float));
	
	// Compute data mean
	float* mean = (float*) calloc(D, sizeof(float));
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < D; d++) {
			mean[d] += XX[n * D + d];
		}
	}
	for(int d = 0; d < D; d++) {
		mean[d] /= (float) N;
	}
	
	// Subtract data mean
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < D; d++) {
			XX[n * D + d] -= mean[d];
		}
	}
	
	// Compute covariance matrix (with BLAS)
	float* C = (float*) calloc(D * D, sizeof(float));
	cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasTrans, D, D, N, 1.0, XX, N, XX, N, 0.0, C, D);
	
	// Compute covariance matrix (without BLAS)
	/*float* C = (float*) calloc(D * D, sizeof(float));
	for(int n = 0; n < N; n++) {
		for(int d1 = 0; d1 < D; d1++) {
			for(int d2 = 0; d2 < D; d2++) {
				C[d1 * D + d2] += X[n * D + d1] * X[n * D + d2];
			}
		}
	}*/
	
	// Perform eigendecomposition of covariance matrix
	int n = D, lda = D, lwork = -1, info;
	float wkopt;
	float* lambda = (float*) malloc(D * sizeof(float));
	ssyev_((char*) "V", (char*) "U", &n, C, &lda, lambda, &wkopt, &lwork, &info);			// gets optimal size of working memory
	lwork = (int) wkopt;
	float* work = (float*) malloc(lwork * sizeof(float));	
	ssyev_((char*) "V", (char*) "U", &n, C, &lda, lambda, work, &lwork, &info);				// eigenvectors for real, symmetric matrix
    // NOTE: ssyev outputs eigenvalues in ascending order!
    
	// Project data onto first eigenvectors (C' * X, using BLAS)
	//cblas_sgemm(CblasRowMajor, CblasTrans, CblasNoTrans, no_dims, N, D, 1.0, C, no_dims, XX, N, 0.0, Y, N);
    	
	// Project data onto first eigenvectors (without BLAS)
	for(int n = 0; n < N; n++) {
        int count_d = 0;
		for(int d1 = D - 1; d1 >= D - no_dims; d1--) {
			Y[n * no_dims + count_d] = 0.0;
			for(int d2 = 0; d2 < D; d2++) {
				Y[n * no_dims + count_d] += XX[n * no_dims + d2] * C[d1 * D + d2];
			}
            count_d++;
		}
	}
	
	// Normalize data to have a minimum value of zero
	float* min_val = (float*) calloc(no_dims, sizeof(float));
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < no_dims; d++) {
			if(n == 0 || Y[n * no_dims + d] < min_val[d]) min_val[d] = Y[n * no_dims + d];
		}
	}
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < no_dims; d++) {
			Y[n * no_dims + d] -= min_val[d];
		}
	}
	
	// Normalize data to have a maximum value of one
	float* max_val = (float*) calloc(no_dims, sizeof(float));
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < no_dims; d++) {
			if(n == 0 || Y[n * no_dims + d] > max_val[d]) max_val[d] = Y[n * no_dims + d];
		}
	}
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < no_dims; d++) {
			Y[n * no_dims + d] /= max_val[d];
		}
	}	
	
	// Clean up memory
    free(XX);
	free(mean);
	free(C);
	free(lambda);
	free(work);
	free(min_val);
	free(max_val);
}