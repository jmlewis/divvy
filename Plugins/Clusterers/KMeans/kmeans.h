/*
 *  kmeans.h
 *  Divvy
 *
 *  Created by Joshua Lewis on 6/13/11.
 *
 */

#ifndef DIVVY_KMEANS_H_
#define DIVVY_KMEANS_H_

#include <stdlib.h>
#include <float.h>
#include <dispatch/dispatch.h>

void kmeans(float *data, unsigned int n, unsigned int d, unsigned int k, int *assignment);

#endif