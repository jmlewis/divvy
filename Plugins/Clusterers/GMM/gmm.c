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
void gmm(float *data, unsigned int n, unsigned int d, unsigned int k, unsigned int r, float th, unsigned int meanInit, unsigned int covInit, int *assignment) {
  
    // Parameters for each Multivariate Gaussian Distribution
    double *tmp_cov = (double *)calloc(d * d, sizeof(double));
    double *means = (double *)calloc(k * d, sizeof(double));
    double *covariances = (double *)calloc(k * d * d, sizeof(double));
    double *priors = (double *)calloc(k, sizeof(double));
    double *Nk = (double *)calloc(k, sizeof(double));
    
    // Parameters for initialization
    int *means_N = (int*)calloc(k,sizeof(int));
    float *covs_N = (float*)calloc(k,sizeof(float));
    
    // Parameters for the pdfs of the Multivariate Gaussians
    double *covInverses = (double *)malloc(k * d * d * sizeof(double));
    double *constantTerms = (double *)malloc(k * sizeof(double));
    
    // Cluster assignments for data
    double *responsibilities = (double *)malloc(n * k * sizeof(double));        // n rows and k columns
    double *forLog = (double *)malloc(n * k * sizeof(double));                  // for computing the loglikelihood (no denom in posterior)
    int *cur_assignment = (int*)calloc(n, sizeof(int));
    int *init_assignment = (int*)calloc(n, sizeof(int));
    double *distances = (double *)calloc(n, sizeof(double));
    
    // Used in E-step and M-step
    double *vecMinusMean = (double *)calloc(k * n * d, sizeof(double));
    
    double *firstProd = (double *)calloc(k * n * d, sizeof(double));
    double *sampleCovs = (double *)calloc(k * d * d, sizeof(double));
    
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
        
        for(int i = 0; i < n; i++) {
            init_assignment[i] = 0;
        }
        
        // INITIALIZE the means, covariances, and priors
        // Ways to improve - make the cases based on the text in menu instead of item positions
        
        // Mean
        // 0 - K-means : Means are found through using K-means (previously implemented)
        // 1 - Random : Means are randomly selected from dataset points
        
        // Covariance
        // 0 - Closest : Covariance is computed from the points in dataset closest to mean
        // 1 - All : Covariance is computed from all the points in dataset
        // 2 - Random : Covaraince is computed from a random set of points in dataset
        // 3 - Uniform : Dataset is split into equal parts and covariance is computed from those points
        
        // Priors
        // If the covariance is computed from All, then priors are equal
        // Otherwise it is calculated from the number of points used in each covariance matrix
        
        printf("Mean = %d, Covariance = %d \n", meanInit, covInit);
        
        switch(meanInit) {
                
            // K-means
            case 0:
                // set the assignments using k-means
                kmeans(data,n,d,k,r,init_assignment);
                // loop through the data points, add points to mean, divide by number used
                for(int i = 0; i < n; i++) {
                    int assign = init_assignment[i];
                    for(int j = 0; j < d; j++) {
                        means[assign * d + j] += data[i * d + j];
                    }
                    means_N[assign] += 1;
                }
                printf("Counts\n");
                for(int i = 0; i < k; i++) {
                    printf("%d ",means_N[i]);
                    for(int j = 0; j < d; j++) {
                        means[i * d + j] /= means_N[i];
                    }
                }
                printf("\nK MEANS WORKS!\n");
                break;
                
            // Random
            case 1:
                for(int i = 0; i < k; i++) {
                    int sample_mean = rand() % n;
                    for(int j = 0; j < d; j++) {
                        means[i * d + j] = data[sample_mean * d + j];
                    }
                }
                break;
        }
        
        printf("MEANS CREATED\n");
        for(int i = 0; i < k; i++) {
            for(int j = 0; j < d; j++) {
                printf("%f ", means[i * d + j]);
            }
            printf("\n");
        }
        
        switch(covInit) {
                
            // Closest
            case 0:
                // Zero out covs_N
                for(int i = 0; i < k; i++) {
                    covs_N[i] = 0;
                }
                
                // Determine which means is closest (from k-means code)
                dispatch_apply(n, queue, ^(size_t j) {
                    double min_distance = DBL_MAX;
                    double distance;
                    
                    for(int l = 0; l < k; l++)
                    {
                        distance = 0.f;
                        
                        for(int m = 0; m < d; m++)
                            distance += (data[j * d + m] - means[l * d + m]) * (data[j * d + m] - means[l * d + m]);
                        
                        if(distance < min_distance)
                        {
                            min_distance = distance;
                            init_assignment[j] = l;
                        }
                    }
                });
//                printf("Assignments\n");
//                for(int i = 0; i < n; i++) {
//                    printf("%d = %d\n", i, assignment[i]);
//                }
                
                // Determine number of points in each covariance matrix
//                for(int i = 0; i < n; i++) {
//                    int j = *(init_assignment + i);
//                    *(covs_N + j) += 1;
//                }
                // Determine indices for points in cluster and create covariances
//                printf("Number of points: %d\n", n);
                for(int i = 0; i < k; i++) {
                    
//                    int *indices = (int*)malloc(covs_N[i]*sizeof(int));
                    int count = 0;
//                    // Determine indices
                    for(int j = 0; j < n; j++) {
                        if(init_assignment[j]==i) {
//                            indices[count] = j;
                            count++;
                        }
                    }
//                    printf("Count = %d\n", count);
//                    printf("Indices:\n");
//                    for(int jeremy = 0; jeremy < covs_N[i]; jeremy++) {
//                        printf("%d = %d\n",jeremy,indices[jeremy]);
//                    }
                    
                    printf("Computing covar!\n");
                    
                    // Use the indices to create covariances matrix
                    covar_indices(data,init_assignment,i,n,d,tmp_cov);
                    // Set the ith covariance to be equal to that.
                    for(int l = 0; l < d; l++) {
                        for(int m = 0; m < d; m++) {
                            covariances[i*(d*d) + l*d + m] = tmp_cov[l*d + m];
                        }
                    }
                    
                    printf("Covariance %d\n",i);
                    for(int l = 0; l < d; l++) {
                        for(int m = 0; m < d; m++) {
                            printf("%f ", covariances[i*(d*d) + l*d + m] = tmp_cov[l*d + m]);
                        }
                        printf("\n");
                    }
                    printf("\n");
                    
//                    free(indices);
                    covs_N[i] = count;
                    printf("Dist %d number of indices = %f\n", i,covs_N[i]);
                }
                
                    
                break;
                
            // All
            case 1:
                for(int i = 0; i < k; i++) {
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
                    covs_N[i] = n / k;
                }
                break;
                
//            // Random
//            case 2:
//                break;
//                
//            // Uniform
//            case 3:
//                break;
        }
        
        // Priors
        for(int i = 0; i < k; i++) {
            priors[i] = covs_N[i] / n;
            printf("%f\n",priors[i]);
        }
        
        
        
        printf("Starting E-M step\n");
    
        // Until the threshold is reached, perform E-M to update means and covariances
        while(fabs(logEstimate - oldLogEstimate) > th) {
            
            //printf("Error = %f \n",fabs(logEstimate - oldLogEstimate));
            
            // Zero out certain arrays
            for(int i = 0; i < k; i++) {
                *(Nk + i) = 0;
            }
            
            // Recompute the pdfs for each multivariate gaussian
            // function doesn't return anything but it sets covInverses and constantTerms
            createpdfs(means, covariances, covInverses, constantTerms, k, d);
            
            // Printing things out to make sure pdf creation worked
            printf("Means!\n");
            for(int i =  0; i<k; i++) {
                for(int j = 0; j<d; j++) {
                    printf("%f ", means[i*d+j]);
                }
                printf("\n");
            }
            
            printf("Inverse of Covariance\n");
            for(int i = 0; i<d; i++) {
                for(int j = 0; j<d; j++) {
                    printf("%f ", covInverses[i*d+j]);
                }
                printf("\n");
            }
        
            printf("E-step!\n");
            
            // E-STEP (compute responsibilities)
            //
            // This is the parallel version of:
            // for(j = 0; j < n; j++) {
            //
            // As long as each loop iteration doesn't depend on the other (in other words
            // the operation can be thought of as a map function) this works nicely.

            dispatch_apply(n, queue, ^(size_t j) {
                double min_distance = DBL_MIN;
                
                //double *datum = (double*)calloc(d, sizeof(double));
                //double *mn = (double*)calloc(d, sizeof(double));
                //double *icv = (double*)calloc(d * d, sizeof(double));
                double cnst;
                double responsibilitySum = 0;
                
                // Get the point
//                for(int i = 0; i < d; i++) {
//                    datum[i] = data[j * d + i];
//                }
        
                // Loop through the possible gaussians and compute responsbilities
                for(int l = 0; l < k; l++) {
                        
                    // get the mean
//                    for(int f = 0; f < d; f++) {
//                        mn[f] = means[l * d + f];
//                    }
                    
                    // get the inverse of covariance
//                    for(int q = 0; q < d; q++) {
//                        for(int r = 0; r < d; r++) {
//                            icv[q*d + r] = covInverses[l*(d*d) + q*d + r];
//                        }
//                    }
                    
                    // get the constant term
                    cnst = constantTerms[l];
                    
                    // Compute distance. Since all posteriors are proportional to likelihood*prior, we can assign
                    // cluster color by the numerator (largest prob), even though point is used in all gaussians
                    
                    // By sending the start address of the covInverse, it will use that specific covInverse without creating new one
                    mvnpdf(distances, data, means, &vecMinusMean[l*(n*d) + (j*d)], &firstProd[l*(n*d) + (j*d)], &covInverses[l*(d*d)], cnst, n, d, j, l);
                    //*(likelihoods + (j * k + l)) = distance;
                    distances[j] *= priors[l];
                    responsibilities[j * k + l] = distances[j];
                    responsibilitySum += distances[j];
                    
                    if(distances[j] > min_distance) {
                        min_distance = distances[j];
                        cur_assignment[j] = l;
                    }
                }
                
                
                // Divide each responsibility by the sum of all the responsibilities to get posteriors
                // Add these to Nk (one value for each gaussian)
                for(int l = 0; l < k; l++) {
                    forLog[j * k + l] = responsibilities[j * k + l];
                    responsibilities[j * k + l] /= responsibilitySum;
                }
                
                //free(distance);
                //free(datum);
                //free(mn);
                //free(icv);
            });
            
//            printf("Responsbilities!\n");
//            for(int i = 0; i < n; i++) {
//                for(int j = 0; j < k; j++) {
//                    printf("%f ",responsibilities[i * k + j]);
//                }
//                printf("\n");
//            }
            
            // Update Nk - can not be parallelized because it accesses the same data for all j
            for(int i = 0; i < n; i++) {
                for(int j = 0; j < k; j++) {
                    Nk[j] += responsibilities[i * k + j];
                }
            }
            
            printf("M-step!\n");
            
            // M-STEP (recompute gaussians)
            dispatch_apply(k, queue, ^(size_t j) {

                //double *sample_cov = (double*)calloc(d * d, sizeof(double));
                //double *vecMinusMean = (double*)calloc(d, sizeof(double));
                
                
                // Compute new means - samples times their responsibilities
                for(int i = 0; i < n; i++) {
                    for(int l = 0; l < d; l++) {
                        means[j * d + l] += responsibilities[i * k + j] * data[i * d + l];
                    }
                }
                for(int l = 0; l < d; l++) {
                    means[j * d + l] /= Nk[j];
                }
                
                
                // Compute new covariances
                // for each data point
                for(int i = 0; i < n; i++) {
                    // get that point minus the mean
                    for(int l = 0; l < d; l++) {
                        vecMinusMean[j*(n*d) + (i*d) + l] = data[i * d + l] - means[j * d + l];
                    }
                    // use it to create addition to covariance matrix
                    // The pointers to spots in sampleCov and vecMinusMean allow it to index into certain parts of multidimensional array
                    dot(&sampleCovs[j*(d*d)],&vecMinusMean[j*(n*d) + (i*d)],&vecMinusMean[j*(n*d) + (i*d)],d,1,1,d);
                    for(int p = 0; p < d; p++) {
                        for(int q = 0; q < d; q++) {
                            covariances[j*(d*d) + p*d + q] += responsibilities[i * k + j] * sampleCovs[j*(d*d) + p*d + q];
                        }
                    }
                }
                // divide entire jth covariance matrix by Nk
                for(int p = 0; p < d; p++) {
                    for(int q = 0; q < d; q++) {
                        covariances[j*(d*d) + p*d + q] /= Nk[j];
                    }
                }
                
                // Compute new prior
                priors[j] = Nk[j]/n;
                
                
                //free(sample_cov);
                //free(vecMinusMean);
            });
            
        
            // Set the old log estimate to be the current one
            oldLogEstimate = logEstimate;
            
            // Compute Log-likelihood
            logEstimate = 0;
            for(int i = 0; i < n; i++) {
                long double tmplogpart = 0;
                for(int j = 0; j < k; j++) {
                    tmplogpart += forLog[i * k + j];
                }
                logEstimate += log(tmplogpart);
            }
            
        }
        
        cur_cost = logEstimate;
        
        // If this is the best solution so far, copy it to the output.
        if (cur_cost > max_cost) {
            printf("Assignment Changed!\n");
            max_cost = cur_cost;
            for(int i = 0; i < n; i++) {
                assignment[i] = cur_assignment[i];
            }
        }
        
        printf("Current Cost = %f\n",cur_cost);
        

    }
    
    for(int i = 0; i < n; i++) {
        printf("%d ", assignment[i]);
    }
    printf("\n\n");
  
    free(tmp_cov);
    free(means);
    free(covariances);
    free(priors);
    free(Nk);
    free(means_N);
    free(covs_N);
    free(covInverses);
    free(constantTerms);
    free(responsibilities);
    free(forLog);
    free(cur_assignment);
    free(init_assignment);
    free(distances);
    free(vecMinusMean);
    free(firstProd);
    free(sampleCovs);
}