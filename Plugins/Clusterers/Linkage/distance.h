/*
 *  distance.h
 *  Divvy
 *
 *  Created by Joshua Lewis on 8/22/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef DISTANCE_H
#define DISTANCE_H

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <dispatch/dispatch.h>

#include <vecLib/cblas.h>
#include <vecLib/clapack.h>

#include "indexing.h"

void distance(int N, int D, float *data, float *result);

#endif