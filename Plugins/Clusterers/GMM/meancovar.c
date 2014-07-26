//
//  meancovar.c
//
//  Written in 2014 by Jeremy Karnowski at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu

#include "meancovar.h"

void *covar(float *data, unsigned int n, unsigned int d, double *cov) {
    
    // data has columns as data points n, and rows as dimensions d
    // the covariance matrix will be dxd
    float *tmpmeans = (float *)malloc(d * sizeof(float));
    float *vec = (float *)malloc(n * sizeof(float));
    
    // Create the mean across the data points (one column at a time)
    for(int j = 0; j < d; j++) {
        for(int i = 0; i < n; i++) {
            tmpmeans[j] += data[i * d + j];
        }
        tmpmeans[j] /= n;
    }
    
    // For every combination of dimensions, find the covariance
    for(int i = 0; i < d; i++) {
        for(int j = i; j < d; j++) {
            float val = 0;
            // loop through all the values in both dimensions and add them up as you go
            for(int k = 0; k < n; k++) {
                val += ((data[k * d + i] - tmpmeans[i]) * (data[k * d + j] - tmpmeans[j]));
            }
            // divide by the total number of samples
            *(cov + i*d +j) = val / (n-1);
            *(cov + j*d +i) = val / (n-1);
        }
    }
    
    free(tmpmeans);
    free(vec);
    
    return 0;
}
