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
#include <iostream>
#include <queue>
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
    int orig_N = N;
    
    // Select largest connected component
    double* new_sr;
    int *new_irs, *new_jcs;
    int max_ind, max_count;
    int* comp_no = (int*) malloc(N * sizeof(int));
    find_connected_components(irs, N, K, comp_no);
    find_largest_connected_component(comp_no, N, &max_ind, &max_count);

    // Only select part of the data when graph is not completely connected
    if(max_count < N) {
        
        // Count number of removed instances before index n
        int counter = 0;
        int* rem_counts = (int*) calloc(N, sizeof(int));
        for(int n = 0; n < N; n++) {
            if(comp_no[n] != max_ind) counter++;
            rem_counts[n] = counter;
        }
        
        // Build new sparse matrix
        int new_n = 0;
        new_sr  = (double*) malloc(max_count * K   * sizeof(double));
        new_irs =    (int*) malloc(max_count * K   * sizeof(int));
        new_jcs =    (int*) malloc((max_count + 1) * sizeof(int));
        new_jcs[0] = 0;
        for(int n = 0; n < N; n++) {
            if(comp_no[n] == max_ind) {
                for(int k = 0; k < K; k++) {
                    new_sr[ new_n * K + k] =  sr[n * K + k];
                    new_irs[new_n * K + k] = irs[n * K + k] - rem_counts[irs[n * K + k]];
                }
                new_n++;
                new_jcs[new_n] = new_jcs[new_n - 1] + K;                
            }
        }
        
        // Clean up old matrix
        N = max_count;
        free(rem_counts);
        free(sr);
        free(irs);
        free(jcs);
    }
    else {
        new_sr  = sr;
        new_irs = irs;
        new_jcs = jcs;
    }
    
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
        dodijk_sparse(N, N, i, Psmall, Dsmall, new_sr, new_irs, new_jcs, A, theHeap);
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
    int n = N, lda = N, lwork = -1, info;
	float wkopt;
	float* lambda = (float*) malloc(N * sizeof(float));
	ssyev_((char*) "V", (char*) "U", &n, gD, &lda, lambda, &wkopt, &lwork, &info); // gets optimal size of working memory
	lwork = (int) wkopt;
	float* work = (float*) malloc(lwork * sizeof(float));	
	ssyev_((char*) "V", (char*) "U", &n, gD, &lda, lambda, work, &lwork, &info);   // eigenvectors for real, symmetric matrix
    // NOTE: ssyev outputs eigenvalues in ascending order!
    
    // Compute final embedding
    int cur_n = 0;
    for(int n = 0; n < orig_N; n++) {
        if(comp_no[n] == max_ind) {
            int count_d = 0;
            for(int d = N - 1; d >= N - no_dims; d--) {
                Y[n * no_dims + count_d] = gD[d * N + cur_n] * sqrt(lambda[d]);
                count_d++;
            }
            cur_n++;
        }
        else {
            for(int d = 0; d < no_dims; d++) {
                Y[n * no_dims + d] = NAN;
            }
        }
	}
    
    // Normalize data to have a minimum value of zero
	float* min_val = (float*) calloc(no_dims, sizeof(float));
	for(int n = 0; n < orig_N; n++) {
		for(int d = 0; d < no_dims; d++) {
			if(Y[n * no_dims + d] != NAN && Y[n * no_dims + d] < min_val[d]) min_val[d] = Y[n * no_dims + d];
		}
	}
	for(int n = 0; n < orig_N; n++) {
		for(int d = 0; d < no_dims; d++) {
			Y[n * no_dims + d] -= min_val[d];
		}
	}
	
	// Normalize data to have a maximum value of one
	float* max_val = (float*) calloc(no_dims, sizeof(float));
	for(int n = 0; n < orig_N; n++) {
		for(int d = 0; d < no_dims; d++) {
			if(Y[n * no_dims + d] != NAN && Y[n * no_dims + d] > max_val[d]) max_val[d] = Y[n * no_dims + d];
		}
	}
	for(int n = 0; n < orig_N; n++) {
		for(int d = 0; d < no_dims; d++) {
			Y[n * no_dims + d] /= max_val[d];
		}
	}
    
    // Clean up memory
    free(DD);
    free(new_sr);
    free(new_irs);
    free(new_jcs);
    free(comp_no);
    free(gD);
    free(Dsmall);
    free(Psmall);
    free(lambda);
    free(work);
}

void find_connected_components(int* irs, int N, int K, int* comp_no) {
    
    // Initialize some variables
    int cur_comp = 0;
    for(int n = 0; n < N; n++) comp_no[n] = 0;
    
    // Loop over vertices
    for(int n = 0; n < N; n++) {
        if(comp_no[n] == 0) {                               // vertex not yet assigned to a component
            cur_comp++;
            
            // Perform breadth-first search
            std::queue<int> q;
            q.push(n);                                      // push root vertex onto queue
            comp_no[n] = cur_comp;                          // mark root vertex
            while(!q.empty()) {
                
                // Get, remove, and mark current vertex
                int cur = q.front();
                q.pop();
                
                // Loop over all children of current vertex
                for(int k = 0; k < K; k++) {
                    if(comp_no[irs[cur * K + k]] == 0) {     // only add vertices we did not see before
                        q.push(irs[cur * K + k]);
                        comp_no[irs[cur * K + k]] = cur_comp;
                    }
                }                
            }
        }
    }
}

void find_largest_connected_component(int* comp_no, int N, int* max_ind, int* max_count) {
    
    // Find number of components
    int no_comp = 0;
    for(int n = 0; n < N; n++) {
        if(comp_no[n] > no_comp) no_comp = comp_no[n];
    }
    
    // Compute size of each component
    int* counts = (int*) calloc(no_comp, sizeof(int));
    for(int n = 0; n < N; n++) {
        counts[comp_no[n] - 1]++;
    }
    
    // Find largest component
    *max_ind = 0, *max_count = 0;
    for(int i = 0; i < no_comp; i++) {
        if(counts[i] > *max_count) {
            *max_count = counts[i];
            *max_ind = i + 1;
        }
    }
    
    // Clean up
    free(counts);
}
