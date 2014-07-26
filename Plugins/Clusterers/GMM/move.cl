//
//  move.cl
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


//  OpenCL code for updating cluster centroid position. Currently we only use the CPU
//  implementation.
__kernel void move(
	__global float *data,
	__global float *centroids,
	__global int *min_index,
	int D,
	int N)
{
	int gid = get_global_id(0);
	
	int k = floor((float)gid / D);
	int d = gid % D;
	
	int i;
	int count = 0;
	float sum = 0.f;
	
	for(i = 0; i < N; i++)
		if(min_index[i] == k)
		{	
			sum += data[i * D + d];
			count++;
		}
	
	if(count == 0) // Resample
		centroids[gid] = data[gid];
	else
		centroids[gid] = sum / count;
}