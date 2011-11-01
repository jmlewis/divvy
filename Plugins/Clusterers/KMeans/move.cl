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
	
	if(count == 0)
		centroids[gid] = data[gid];
	else
		centroids[gid] = sum / count;
}