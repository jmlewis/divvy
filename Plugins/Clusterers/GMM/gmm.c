//
//  gmm.h
//
//  Written in 2014 by Jeremy Karnowski at the UC San Diego Natural Computation Lab,
//  Based on code written in 2011 by Josh Lewis
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#include "gmm.h"

// A parallel gmm implementation.
// One thing that I want to improve was to create different ways to initialize the first points.
// The UI interface could choose the initialization method, pass it as a parameter to this function,
// and the initialization code could run differently depending on the parameter value.
void gmm(float *data, unsigned int n, unsigned int d, unsigned int k, unsigned int r, float th, int *assignment) {
  
    // Parameters for each Multivariate Gaussian Distribution
    double *tmp_cov = (double *)malloc(d * d * sizeof(double));
    double *means = (double *)malloc(k * d * sizeof(double));
    double *covariances = (double *)malloc(k * d * d * sizeof(double));
    float *priors = (float *)malloc(k * sizeof(float));
    double *Nk = (double *)malloc(k * sizeof(double));
    
    // Parameters for the pdfs of the Multivariate Gaussians
    double *covInverses = (double *)malloc(k * d * d * sizeof(double));
    double *constantTerms = (double *)malloc(k * sizeof(double));
    
    // Cluster assignments for data
    double *responsibilities = (double *)malloc(n * k * sizeof(double));        // n rows and k columns
    double *forLog = (double *)malloc(n * k * sizeof(double));                  // for computing the loglikelihood (no denom in posterior)
    int *cur_assignment = (int*)calloc(n, sizeof(int));
    
    //double *likelihoods = (double*)calloc(n * k, sizeof(double));       // testing to see if the mvnpdf works and it giving correct values
    
    float oldLogEstimate, logEstimate;
  
    float max_cost, cur_cost;
    max_cost = -FLT_MAX;
  
    // The queue code is the part that makes it parallel.
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    
    // Perform clustering for each restart (run)
    for(int run = 0; run < r; run++) {

        oldLogEstimate = FLT_MAX;         // not true, just initialization
        logEstimate = FLT_MAX/2 + th;     // not true, just initialization
      
        // INITIALIZE the means, covariances, and priors
        // (could be improved to provide different initialization methods)
        // For this current version:
        // mean - random points from the dataset
        // covariance - the covariance of the whole dataset
        // priors - equal probability
        for(int i = 0; i < k; i++) {
            
            // mean
            int sample_mean = rand() % n;
            for(int j = 0; j < d; j++) {
                means[i * d + j] = data[sample_mean * d + j];
            }
            
            // covariance
            // compute covariance of all the data
            covar(data,n,d,tmp_cov);
            // copy it to all covariances for each distribution
            for(int dist = 0; dist < k; dist++) {
                for(int i = 0; i < d; i++) {
                    for(int j = 0; j < d; j++) {
                        covariances[dist*(d*d) + i*d + j] = tmp_cov[i*d + j];
                    }
                }
            }
            
            // prior
            priors[i] = 1.0 / k;
        }
        

    
        // Until the threshold is reached, perform E-M to update means and covariances
        while(fabs(logEstimate - oldLogEstimate) > th) {
            
            // Zero out certain arrays
            for(int i = 0; i < k; i++) {
                *(Nk + i) = 0;
            }
            
            // Recompute the pdfs for each multivariate gaussian
            // function doesn't return anything but it sets covInverses and constantTerms
            createpdfs(means, covariances, covInverses, constantTerms, k, d);
            

            
            // E-STEP (compute responsibilities)
            //
            // This is the parallel version of:
            // for(j = 0; j < n; j++) {
            //
            // As long as each loop iteration doesn't depend on the other (in other words
            // the operation can be thought of as a map function) this works nicely.

            dispatch_apply(n, queue, ^(size_t j) {
                float min_distance = FLT_MIN;
                float distance;
                double *datum = (double*)calloc(d, sizeof(double));
                double *mn = (double*)calloc(d, sizeof(double));
                double *icv = (double*)calloc(d * d, sizeof(double));
                double cnst;
                double responsibilitySum = 0;
                
                // Get the point
                for(int i = 0; i < d; i++) {
                    datum[i] = data[j * d + i];
                }
        
                // Loop through the possible gaussians and compute responsbilities
                for(int l = 0; l < k; l++) {
                    distance = FLT_MAX;
                        
                    // get the mean
                    for(int f = 0; f < d; f++) {
                        *(mn + f) = *(means + (l * d + f));
                    }
                        
                    // get the inverse of covariance
                    for(int q = 0; q < d; q++) {
                        for(int r = 0; r < d; r++) {
                            *(icv + (q*d + r)) = *(covInverses + (l*(d*d) + q*d + r));
                        }
                    }
                    
                    // get the constant term
                    cnst = *(constantTerms + l);
                    
                    // Compute distance. Since all posteriors are proportional to likelihood*prior, we can assign
                    // cluster color by the numerator (largest prob), even though point is used in all gaussians
                    
                    distance =  mvnpdf(datum, mn, icv, cnst, d, j,l);
                    //*(likelihoods + (j * k + l)) = distance;
                    distance *= priors[l];
                    *(responsibilities + (j * k + l)) = distance;
                    responsibilitySum += distance;
                    
                    if(distance > min_distance) {
                        min_distance = distance;
                        *(cur_assignment + j) = l;
                    }
                    
                }
                
                // Divide each responsibility by the sum of all the responsibilities to get posteriors
                // Add these to Nk (one value for each gaussian)
                for(int l = 0; l < k; l++) {
                    *(forLog + (j * k + l)) = *(responsibilities +(j * k + l));
                    *(responsibilities + (j * k + l)) /= responsibilitySum;
                }
                
                free(datum);
                free(mn);
                free(icv);
            });
            
            // Update Nk - can not be parallelized because it accesses the same data for all j
            for(int i = 0; i < n; i++) {
                for(int j = 0; j < k; j++) {
                    *(Nk + j) += *(responsibilities + (i * k + j));
                }
            }
            
            
            
            // M-STEP (recompute gaussians)
            dispatch_apply(k, queue, ^(size_t j) {

                double *sample_cov = (double*)calloc(d * d, sizeof(double));
                double *vecMinusMean = (double*)calloc(d, sizeof(double));
                
                
                // Compute new means - samples times their responsibilities
                for(int i = 0; i < n; i++) {
                    for(int l = 0; l < d; l++) {
                        *(means + (j * d + l)) += *(responsibilities + (i * k + j)) * *(data + (i * d + l));
                    }
                }
                for(int l = 0; l < d; l++) {
                    *(means + (j * d + l)) /= *(Nk + (j));
                }
                
                
                // Compute new covariances
                // for each data point
                for(int i = 0; i < n; i++) {
                    // get that point minus the mean
                    for(int l = 0; l < d; l++) {
                        *(vecMinusMean + l) = *(data + (i * d + l)) - *(means + (j * d + l));
                    }
                    // use it to create addition to covariance matrix
                    sample_cov = dot(vecMinusMean,vecMinusMean,d,1,1,d);
                    for(int p = 0; p < d; p++) {
                        for(int q = 0; q < d; q++) {
                            *(covariances + (j*(d*d) + p*d + q)) += *(responsibilities + (i * k + j)) * *(sample_cov + (p*d + q));
                        }
                    }
                }
                // divide entire jth covariance matrix by Nk
                for(int p = 0; p < d; p++) {
                    for(int q = 0; q < d; q++) {
                        *(covariances + (j*(d*d) + p*d + q)) /= *(Nk + j);
                    }
                }
                
                // Compute new prior
                *(priors + j) = *(Nk + j)/n;
                
                
                free(sample_cov);
                free(vecMinusMean);
            });
            
        
            // Set the old log estimate to be the current one
            oldLogEstimate = logEstimate;
            
            // Compute Log-likelihood
            logEstimate = 0;
            for(int i = 0; i < n; i++) {
                long double tmplogpart = 0;
                for(int j = 0; j < k; j++) {
                    tmplogpart += *(forLog + (i * k + j));
                }
                logEstimate += log(tmplogpart);
            }
            
        }
        
        cur_cost = logEstimate;
        
        // If this is the best solution so far, copy it to the output.
        if (cur_cost > max_cost) {
            max_cost = cur_cost;
            for(int i = 0; i < n; i++) {
                *(assignment + i) = *(cur_assignment + i);
            }
        }
        

    }
  
    free(tmp_cov);
    free(means);
    free(covariances);
    free(priors);
    free(Nk);
    free(covInverses);
    free(constantTerms);
    free(responsibilities);
    free(forLog);
    free(cur_assignment);
    
}