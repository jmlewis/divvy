__kernel void assignment(
	__global float *data,
	__global float *centroids,
	__global int *min_index,
	__local float *shared_data,
	__local float *shared_centroids,
	__private int D,
	__private int k)
{
	int gid = get_global_id(0);
	int lsize = get_local_size(0);
	int lid = get_local_id(0);
	
	int i, j;
	int local_min_index = -1;
	float sum, diff;
	float min_distance = MAXFLOAT;
	
	// Load the workgroup data into local memory
	for(i = 0; i < D; i++)
		shared_data[i * lsize + lid] = data[gid * D + i];
	
	// Load the centroids into local memory
	for(i = 0; i < k * D; i += lsize)
		if (i + lid < k * D)
			shared_centroids[i + lid] = centroids[i + lid];
			
	// Ensure that no part of the following loop gets executed while centroids are still
	// being loaded into local memory 
	barrier(CLK_LOCAL_MEM_FENCE);
	
	// Loop through the centroids
	for(i = 0; i < k; i++)
	{
		sum = 0.f;

		// Accumulate distance from centroid i in sum
		for(j = 0; j < D; j++)
		{
			//if(i == 0) // Load the workgroup data into local memory on the first pass (slower by ~10ms/pass)
			//	shared_data[j * lsize + lid] = data[gid * D + j];
			diff = shared_data[j * lsize + lid] - shared_centroids[i * D + j]; // Use local memory
			//sum += pown(diff, 2);
			sum += diff * diff; // ~6x faster/pass than pown(diff, 2)
		}

		if(sum < min_distance) // Update closest centroid
		{
			min_distance = sum;
			local_min_index = i;
		}
	}
	
	min_index[gid] = local_min_index; // Write result to global mem
}