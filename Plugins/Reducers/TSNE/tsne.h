/*
 *  tsne.h
 *  Divvy
 *
 *  Created by Laurens van der Maaten on 8/18/11.
 *  Copyright 2011 Delft University of Technology. All rights reserved.
 *
 */

#ifndef TSNE_H
#define TSNE_H

void perform_tsne(float* X, int D, int N, float* Y, int No_dims, float perplexity);
void normalize_data(float* X, int N, int D);
void zero_mean(float* X, int N, int D);
void compute_squared_euclidean_distance(float* X, int N, int D, float* DD);
void compute_gaussian_perplexity(float* X, int N, int D, float* P, float perplexity);
void compute_student(float* X, int N, int D, float* P, float* unnorm_P);
void compute_stiffnesses(float* P, float* Q, float* unnorm_Q, int N);
void compute_gradient(float* Y, float* Z, float* dY, int N, int D);
float evaluate_error(float* P, float* Q, int N);
float randn();

#endif