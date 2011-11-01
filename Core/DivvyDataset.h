//
//  DivvyDataset.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the New BSD License.
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu
//  
//  DivvyDataset manages the data and metadata associated with a single dataset.
//  It maintains a set of DivvyDatasetViews that represent alternative
//  visualizations, clusterings and embeddings of the dataset.


#import <CoreData/CoreData.h>


@interface DivvyDataset :  NSManagedObject  

// The dimensionality of the dataset
@property (nonatomic, retain) NSNumber *d;
// The number of samples in the dataset
@property (nonatomic, retain) NSNumber *n;
// The raw data loaded in from a Divvy-compatible file
@property (nonatomic, retain) NSData *data;

// The title of the dataset -- this is the string the user sees, by default the filename
@property (nonatomic, retain) NSString *title;
// The zoom level for dataset view images in the dataset window
@property (nonatomic, retain) NSNumber *zoomValue;

// The set of dataset views associated with this dataset
@property (nonatomic, retain) NSSet *datasetViews;
@property (nonatomic, retain) NSIndexSet *selectedDatasetViews;

// Load data from a file
- (void) loadDataAtURL:(NSURL *)url;

// A pointer to the beginning of the floats in data, after n and d
- (float *) floatData;

@end