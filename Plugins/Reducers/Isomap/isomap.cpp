//
//  isomap.c
//  Divvy
//
//  Created by Laurens van der Maaten on 9/20/11.
//  Copyright 2011 Delft University of Technology. All rights reserved.
//

#include "isomap.h"
#include "fibheap.h"
#include <math.h>
#include <float.h>
#include <Accelerate/Accelerate.h>

void dodijk_sparse(long int M,
                   long int N,
                   long int S,
                   long int *P, // parents
                   double   *D, // distances
                   double   *sr,
                   int      *irs,
                   int      *jcs,
                   HeapNode *A,
                   FibHeap  *theHeap  );


void run_isomap(float* X, int N, int D, float* Y, int no_dims, int K) {
    
    // Compute pairwise distance matrix
    float* DD = (float*) calloc(N * N, sizeof(float));
    float val;
	for(int n = 0; n < N; n++) {
		DD[n * N + n] = 0.0;
		for(int m = n + 1; m < N; m++) {
			val = 0.0;
			for(int d = 0; d < D; d++) val += (X[n * D + d] - X[m * D + d]) * (X[n * D + d] - X[m * D + d]);
			DD[n * N + m] = val;
			DD[m * N + n] = val;
		}
	}    
    
    // Compute pairwise distance matrix (using BLAS)
    // ...put squared row and column sums in DD...
    //cblas_sgemm(CblasRowMajor, CblasTrans, CblasNoTrans, N, N, D, -2.0, X, N, X, N, 0.0, DD, N);
    
    // Construct k-nearest neighbors graph (compact sparse format)
    double* sr = (double*) malloc(N * K * sizeof(double));  // nonzero values (N * K elements)
    int* irs   = (int*)    malloc(N * K * sizeof(int));     // row at which a nonzero element can be found (N * K elements)
    int* jcs   = (int*)    malloc((N + 1) * sizeof(int));   // indicates columns containing nonzero elements (N + 1 elements)
    jcs[0] = 0;
    for(int n = 0; n < N; n++) {
        for(int k = 0; k < K; k++) {                // this is inefficient for large K
            
            // Find k-th nearest neighbor
            int min_ind   = 0;
            float min_val = FLT_MAX;
            for(int m = 0; m < N; m++) {
                if(DD[n * N + m] < min_val) {
                    min_val = DD[n * N + m];
                    min_ind = m;
                }
            }
            DD[n * N + min_ind] = FLT_MAX;
            
            // Store neighbor in compact sparse format
            sr[n * K + k]  = min_val;
            irs[n * K + k] = min_ind;
        }
        jcs[n + 1] = jcs[n] + K;
    }
    
    // Select largest connected component
    // ...
    
    // Perform Dijkstra's algorithm
    HeapNode *A = NULL;
    FibHeap  *theHeap = NULL;
    float*   gD      = (float *)    malloc(N * N * sizeof(float));
    double*   Dsmall = (double *)   calloc(N, sizeof(double));
    long int* Psmall = (long int *) calloc(N, sizeof(long int));
    for(int i = 0; i < N; i++) {        
        if((theHeap = new FibHeap) == NULL || (A = new HeapNode[N + 1]) == NULL) {
            return;
        }     
        theHeap->ClearHeapOwnership();     
        dodijk_sparse(N, N, i, Psmall, Dsmall, sr, irs, jcs, A, theHeap);
        for(int j = 0; j < N; j++) {
            *(gD + j * N + i) = (float) *(Dsmall + j);
        }
        delete theHeap;
        delete[] A;
    }
    
    // Perform centering of geodesic distance matrix
    float* row_sums = (float*) calloc(N, sizeof(float));
    float* col_sums = (float*) calloc(N, sizeof(float));
    for(int n = 0; n < N; n++) {
        for(int m = 0; m < N; m++) {
            row_sums[m] += gD[n * N + m];
            col_sums[n] += gD[n * N + m];
        }
    }
    float tot_sum = 0.0;
    for(int n = 0; n < N; n++) tot_sum += col_sums[n];
    for(int n = 0; n < N; n++) row_sums[n] /= (float) N;
    for(int n = 0; n < N; n++) col_sums[n] /= (float) N;
    tot_sum /= (N * N);
    for(int n = 0; n < N; n++) {
        for(int m = 0; m < N; m++) {
            gD[n * N + m] = -.5 * (gD[n * N + m] - row_sums[m] - col_sums[n] + tot_sum);
        }
    }
    
    // Perform eigendecomposition of kernel matrix
    int n = N, lda = D, lwork = -1, info;
	float wkopt;
	float* lambda = (float*) malloc(N * sizeof(float));
	ssyev_((char*) "V", (char*) "U", &n, gD, &lda, lambda, &wkopt, &lwork, &info); // gets optimal size of working memory
	lwork = (int) wkopt;
	float* work = (float*) malloc(lwork * sizeof(float));	
	ssyev_((char*) "V", (char*) "U", &n, gD, &lda, lambda, work, &lwork, &info);   // eigenvectors for real, symmetric matrix
    
    // Compute final embedding
    for(int n = 0; n < N; n++) {
		for(int d = 0; d < no_dims; d++) {
            Y[n * no_dims + d] = gD[d * N + n] * sqrt(lambda[d]);
		}
	}
    
    // Clean up memory
    free(DD);
    free(sr);
    free(irs);
    free(jcs);
    free(gD);
    free(Dsmall);
    free(Psmall);
    free(lambda);
    free(work);
}
