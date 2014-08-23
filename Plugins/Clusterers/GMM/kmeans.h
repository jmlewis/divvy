//
//  kmeans.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu

#ifndef DIVVY_KMEANS_H_
#define DIVVY_KMEANS_H_

#include <stdlib.h>
#include <float.h>
#include <dispatch/dispatch.h>

void kmeans(float *data, unsigned int n, unsigned int d, unsigned int k, unsigned int r, int *assignment);

#endif