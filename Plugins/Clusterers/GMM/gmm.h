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

#ifndef DIVVY_GMM_H_
#define DIVVY_GMM_H_

#include <stdlib.h>
#include <float.h>
#include <dispatch/dispatch.h>
#include <math.h>
#include "meancovar.h"
#include "multivariate.h"
#include "kmeans.h"

void gmm(float *data, unsigned int n, unsigned int d, unsigned int k, unsigned int r, float th, unsigned int meanInit, unsigned int covInit, int *assignment);

#endif