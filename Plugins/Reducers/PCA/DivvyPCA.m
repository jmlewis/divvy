//
//  DivvyPCA.m
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyPCA.h"
#import "DivvyDataset.h"

#include "pca.h"


@implementation DivvyPCA

@dynamic reducerID;
@dynamic name;

@dynamic d;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.name = @"Principal Components Analysis";
  self.reducerID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) calculateD:(DivvyDataset *)dataset {
  if([dataset.d compare:self.d] == NSOrderedAscending)
    self.d = dataset.d;
}

- (void) reduceDataset:(DivvyDataset *)dataset
           reducedData:(NSData *)reducedData {
	
	// Run PCA code
	float *newReducedData = (float*) [reducedData bytes];
	reduce_data([dataset floatData], 
				[[dataset d] unsignedIntValue], 
				[[dataset n] unsignedIntValue], 
				newReducedData, [self.d unsignedIntValue]);
	
	// Print out reduced data
	/*for(int i = 0; i < [[dataset n] unsignedIntValue]; i++) {
		for(int j = 0; j < [self.d unsignedIntValue]; j++) {
			printf("%f,", newReducedData[j * [[dataset n] unsignedIntValue] + i]);
		}
		printf("\n");
	}*/
}

@end
