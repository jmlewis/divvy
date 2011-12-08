% Export a Matlab matrix into Divvy format.
% The matrix should have samples in the columns and dimensions in the rows.
function matlabtodivvy(data, name)

samples = size(data, 2);
dimensions = size(data, 1);
filename = strcat(name, '.bin');

fid = fopen(filename, 'w');
fwrite(fid, samples, 'uint32');
fwrite(fid, dimensions, 'uint32');
fwrite(fid, data, 'float32');
fclose(fid);