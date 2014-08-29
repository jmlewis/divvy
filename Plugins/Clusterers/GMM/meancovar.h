//
//  meancovar.h
//
//  Written in 2014 by Jeremy Karnowski at the UC San Diego Natural Computation Lab,
//  Based on code written in 2011 by Josh Lewis
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu

#ifndef DIVVY_MEANCOVAR_H
#define DIVVY_MEANCOVAR_H

#include <stdlib.h>
#include <float.h>
#include <dispatch/dispatch.h>

void covar(float *data, unsigned int n, unsigned int d, double *cov);
void covar_indices(float *data, int *assignment, int clust, unsigned int n, unsigned int d, double *cov);

#endif
