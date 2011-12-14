//
//  isomap.h
//  Divvy
//
//  Created by Laurens van der Maaten on 9/20/11.
//  Copyright 2011 Delft University of Technology. All rights reserved.
//

#ifndef Divvy_isomap_h
#define Divvy_isomap_h

void run_isomap(float* X, int N, int D, float* Y, int no_dims, int K);
void find_connected_components(int* irs, int N, int K, int* comp_no);
void find_largest_connected_component(int* comp_no, int N, int* max_ind, int* max_count);

#endif
