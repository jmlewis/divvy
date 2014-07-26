//
//  multivariate.h
//
//
//  Written in 2014 by Jeremy Karnowski at the UC San Diego Natural Computation Lab,
//  Based on code written in 2011 by Josh Lewis
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu

#ifndef DIVVY_MULTIVARIATE_H
#define DIVVY_MULTIVARIATE_H

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <float.h>
#include <dispatch/dispatch.h>

double mvnpdf(double *vec, double *mu, double *invcov, double cnst, int d, int j, int l);
void createpdfs(double *mus, double *covs, double *covInvs, double *constants, int k, int d);
double *dot(double *A, double *B, int n, int m, int o, int p);

#endif
