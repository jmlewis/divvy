/*
 *  tsne.c
 *  Divvy
 *
 *  Created by Laurens van der Maaten on 8/18/11.
 *  Copyright 2011 Delft University of Technology. All rights reserved.
 *
 */

#include "tsne.h"
#include <math.h>
#include <float.h>
#include <Accelerate/Accelerate.h>


void perform_tsne(float* X, int D, int N, float* Y, int no_dims, float perplexity) {
	
	// Set learning parameters
	int max_iter = 1000, stop_lying_iter = 100;
	float initial_momentum = .5, final_momentum = .8;
	float eta = 1000.0;
	
	// Allocate some memory
	float* P        = (float*) malloc(N * N * sizeof(float));
	float* Q        = (float*) malloc(N * N * sizeof(float));
	float* unnorm_Q = (float*) malloc(N * N * sizeof(float));
	float* uY       = (float*) calloc(N * no_dims, sizeof(float));	
	float* dY       = (float*) malloc(N * no_dims * sizeof(float));	
	
	// Compute Gaussian affinities
	compute_gaussian_perplexity(X, N, D, P, perplexity);
	
	// Lie about the P-values
	for(int i = 0; i < N * N; i++) P[i] *= 4.0;
	
	// Initialize solution
	for(int i = 0; i < N * no_dims; i++) {
		Y[i] = randn() * .0001;
	}
	
	// Perform main training loop
	float momentum = initial_momentum;
	for(int iter = 0; iter < max_iter; iter++) {
		
		// Compute the Q-matrix
		compute_student(Y, N, no_dims, Q, unnorm_Q);
		
		// Compute stiffnesses
		compute_stiffnesses(P, Q, unnorm_Q, N);
		
		// Compute gradient
		compute_gradient(Y, unnorm_Q, dY, N, no_dims);
		
		// Update solution
		for(int i = 0; i < N * no_dims; i++) uY[i] = momentum * uY[i] - eta * dY[i];
		for(int i = 0; i < N * no_dims; i++)  Y[i] = Y[i] + uY[i];
			
		// Make solution zero-mean
		zero_mean(Y, N, no_dims);
		
		// Stop lying about the P-values after a while, and switch momentum
		if(iter == stop_lying_iter) {
			for(int i = 0; i < N * N; i++) P[i] /= 4.0;
			momentum = final_momentum;
		}
        
        // Print out progress
        /*if(iter % 25 == 0) {
            float C = evaluate_error(P, Q, N);
            printf("Iteration %d: error is %f\n", iter, C);
        }*/
	}
    
    // Normalize plot between 0 and 1
    normalize_data(Y, N, no_dims);
	
	// Clean up memory
	free(P);
	free(Q);
	free(unnorm_Q);
	free(uY);
	free(dY);
}

void normalize_data(float* X, int N, int D) {
	
	// Normalize data to have a minimum value of zero
	float* min_val = (float*) calloc(D, sizeof(float));
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < D; d++) {
			if(n == 0 || X[n * D + d] < min_val[d]) min_val[d] = X[n * D + d];
		}
	}
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < D; d++) {
			X[n * D + d] -= min_val[d];
		}
	}
	
	// Normalize data to have a maximum value of one
	float* max_val = (float*) calloc(D, sizeof(float));
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < D; d++) {
			if(n == 0 || X[n * D + d] > max_val[d]) max_val[d] = X[n * D + d];
		}
	}
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < D; d++) {
			X[n * D + d] /= max_val[d];
		}
	}	
}

void zero_mean(float* X, int N, int D) {
	
	// Compute data mean
	float* mean = (float*) calloc(D, sizeof(float));
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < D; d++) {
			mean[d] += X[n * D + d];
		}
	}
	for(int d = 0; d < D; d++) {
		mean[d] /= (float) N;
	}
	
	// Subtract data mean
	for(int n = 0; n < N; n++) {
		for(int d = 0; d < D; d++) {
			X[n * D + d] -= mean[d];
		}
	}
}

void compute_squared_euclidean_distance(float* X, int N, int D, float* DD) {
    
    // Compute squared Euclidean distance matrix (without BLAS)
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
    
    // Compute squared Euclidean distance matrix (using BLAS)
    // ...put squared row and column sums in DD...
    //cblas_sgemm(CblasRowMajor, CblasTrans, CblasNoTrans, N, N, D, -2.0, X, N, X, N, 0.0, DD, N);	
}

void compute_gaussian_perplexity(float* X, int N, int D, float* P, float perplexity) {
	
	// Compute the squared Euclidean distance matrix
	float* DD = (float*) malloc(N * N * sizeof(float));
	compute_squared_euclidean_distance(X, N, D, DD);
	
	// Compute the Gaussian kernel row by row
	for(int n = 0; n < N; n++) {
		
		// Initialize some variables
		bool found = false;
		float beta = 1.0;
		float min_beta = -FLT_MAX;
		float max_beta =  FLT_MAX;
		float tol = 1e-5;
		
		// Iterate until we found a good perplexity
		int iter = 0;
		while(!found && iter < 200) {				
			
			// Compute Gaussian kernel row
			for(int m = 0; m < N; m++) P[n * N + m] = exp(-beta * DD[n * N + m]);
			P[n * N + n] = FLT_MIN;			
			
			// Compute entropy of current row
			float sumP = 0.0;
			for(int m = 0; m < N; m++) sumP += P[n * N + m];
			float H = 0.0;
			for(int m = 0; m < N; m++) H += beta * (DD[n * N + m] * P[n * N + m]);
			H = (H / sumP) + log(sumP);
			
			// Evaluate whether the entropy is within the tolerance level
			float Hdiff = H - log(perplexity);
			if(Hdiff < tol && -Hdiff < tol) {
				found = true;
			}
			else {
				if(Hdiff > 0) {
					min_beta = beta;
					if(max_beta == FLT_MAX || max_beta == -FLT_MAX)
						beta *= 2.0;
					else
						beta = (beta + max_beta) / 2.0;
				}
				else {
					max_beta = beta;
					if(min_beta == -FLT_MAX || min_beta == FLT_MAX) 
						beta /= 2.0;
					else
						beta = (beta + min_beta) / 2.0;
				}
			}
			
			// Update iteration counter
			iter++;
		}
		
		// Row normalize P
		float sumP = 0.0;
		for(int m = 0; m < N; m++) sumP += P[n * N + m];
		for(int m = 0; m < N; m++) P[n * N + m] /= sumP;
	}
	
	// Make sure the Gaussian kernel is symmetric
    float val1, val2;
	for(int n = 0; n < N; n++) {
		for(int m = 0; m < N; m++) {
            val1 = P[n * N + m];
            val2 = P[m * N + n];
            P[n * N + m] = val1 + val2;
            P[m * N + n] = val1 + val2;
        }
    }
    float sumP = 0.0;
    for(int i = 0; i < N * N; i++) sumP += P[i];        
    for(int i = 0; i < N * N; i++) {
        P[i] /= sumP;
        P[i] += FLT_MIN;
    }
	
	// Clean up memory
	free(DD);
}

void compute_student(float* X, int N, int D, float* P, float* unnorm_P) {
    
    // Compute squared Euclidean distances
    compute_squared_euclidean_distance(X, N, D, unnorm_P);
	
	// Compute unnormalized Student-t densities
	float val;
	for(int n = 0; n < N; n++) {
		unnorm_P[n * N + n] = FLT_MIN;
		for(int m = n + 1; m < N; m++) {
            val = 1 / (1 + unnorm_P[n * N + m]);
			unnorm_P[n * N + m] = val;
			unnorm_P[m * N + n] = val;
		}
	}
	
	// Compute row sums
	float* sum_P = (float*) calloc(N, sizeof(float));
	for(int n = 0; n < N; n++) {
		for(int m = 0; m < N; m++) {
			sum_P[n] += unnorm_P[n * N + m];
		}
	}
	
	// Normalize rows
	for(int n = 0; n < N; n++) {
		for(int m = 0; m < N; m++) {
			P[n * N + m] = unnorm_P[n * N + m] / sum_P[n];
		}
	}
	free(sum_P);
    
    // Perform full normalization
    float totalSum = 0.0;
    for(int i = 0; i < N * N; i++) totalSum += P[i];
    for(int i = 0; i < N * N; i++) P[i] /= totalSum;    
}

void compute_stiffnesses(float* P, float* Q, float* unnorm_Q, int N) {
	for(int i = 0; i < N * N; i++) unnorm_Q[i] = 4.0 * (P[i] - Q[i]) * unnorm_Q[i];
}

void compute_gradient(float* Y, float* Z, float* dY, int N, int D) {
	
	// Make sure the current gradient contains zeros
	for(int i = 0; i < N * D; i++) dY[i] = 0.0;
	
	// Perform the computation of the gradient
	float val;
	for(int n = 0; n < N; n++) {
		for(int m = n + 1; m < N; m++) {
			for(int d = 0; d < D; d++) {
				val = (Y[n * D + d] - Y[m * D + d]) * Z[n * N + m];
				dY[n * D + d] += val;
				dY[m * D + d] -= val;
			}
		}
	}
}

float evaluate_error(float* P, float* Q, int N) {
	float C = 0.0;
	for(int n = 0; n < N; n++) {
		for(int m = 0; m < N; m++) {
			C += P[n * N + m] * log(P[n * N + m] / Q[n * N + m]);
		}
	}
	return 2.0 * C;
}

float randn() {
    
	// Initialize some variables
	float x1, x2, w;
    
	// Generate a Gaussian random number
	do {
		x1 = 2.0 * ((float) rand() / (float) RAND_MAX) - 1.0;
		x2 = 2.0 * ((float) rand() / (float) RAND_MAX) - 1.0;
		w = x1 * x1 + x2 * x2;
	} while (w >= 1.0);
	w = sqrt((-2.0 * log(w) ) / w);
	return x1 * w;
}
