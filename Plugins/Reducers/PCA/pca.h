/*
 *  pca.h
 *  Divvy
 *
 *  Created by Laurens van der Maaten on 8/16/11.
 *  Copyright 2011 Delft University of Technology. All rights reserved.
 *
 */

#ifndef PCA_H
#define PCA_H

void reduce_data(float* X, int D, int N, float* Y, int no_dims);

#endif