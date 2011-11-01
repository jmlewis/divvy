//
//  DivvyTSNE.m
//  Divvy
//
//  Created by Laurens van der Maaten on 8/18/11.
//  Copyright 2011 Delft University of Technology. All rights reserved.
//

#import "DivvyIsomap.h"
#import "DivvyDataset.h"

#include "isomap.h"

struct IsomapImpl {};

@implementation DivvyIsomap

@dynamic reducerID;
@dynamic name;

@dynamic k;


- (void) awakeFromInsert {
	[super awakeFromInsert];
	
	self.name = @"Isomap";
	self.reducerID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) reduceDataset:(DivvyDataset *)dataset
           reducedData:(NSData *)reducedData {
	
	int no_dims = 2;
	float *newReducedData = (float*) [reducedData bytes];
    int cur_k = [[self k] intValue];
    run_isomap([dataset floatData], 
               [[dataset n] unsignedIntValue], 
               [[dataset d] unsignedIntValue], 
               newReducedData, no_dims, cur_k);     // this code is in C++
}


@end
