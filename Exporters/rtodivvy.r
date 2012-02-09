#### R data.frame to Divvy binary file export written by Tom Wisdom
#### & Josh Lewis 2012
rtodivvy <- function(inputData, name) {
	# Data must be dense and real-valued. Check for this in the future.
	# Dimensions are in columns & samples are in rows unlike the Matlab
	# exporter but as per R convention.
	dimensions <- length(inputData[1,])
	samples <- length(inputData[,1])
	# Concatenate rows (after converting data.frame to matrix and values to double)
	inputData_vec <- as.double(t(as.matrix(inputData)))

	filename <- paste(name, ".bin", sep="")
	fid <- file(description = filename, open = "wb")

	writeBin(samples, fid, size=4)
	writeBin(dimensions, fid, size=4)
	writeBin(inputData_vec, fid, size=4)

	close(fid)
}