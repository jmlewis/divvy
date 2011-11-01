/*
 *  linkage.h
 *  Divvy
 *
 *  Created by Joshua Lewis on 8/22/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef LINKAGE_H
#define LINKAGE_H

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>

#include <omp.h>

#include "distance.h"

typedef struct {
	int i;
	int j;
	float distance;
} dendrite;

void linkage(float *data, unsigned int n, unsigned int d, unsigned int k, unsigned int complete, int *assignment);

void dendrogram(int N, int complete, float *distance, dendrite *result);

void assignLaunch(dendrite *dendrogram, int k, int N, int *result);
void assign(dendrite *dendrogram, int line, int k, int N, int *result);

#endif