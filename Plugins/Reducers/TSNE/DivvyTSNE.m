//
//  DivvyTSNE.m
//  Divvy
//
//  Created by Laurens van der Maaten on 8/18/11.
//  Copyright 2011 Delft University of Technology. All rights reserved.
//

#import "DivvyTSNE.h"
#import "DivvyDataset.h"

#include "tsne.h"


@implementation DivvyTSNE

@dynamic reducerID;
@dynamic name;

@dynamic d;

@dynamic perplexity;

- (void) awakeFromInsert {
	[super awakeFromInsert];
	
	self.name = @"t-SNE";
	self.reducerID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) calculateD:(DivvyDataset *)dataset {
  // tSNE always stays with its default of 2
}

- (void) reduceDataset:(DivvyDataset *)dataset
           reducedData:(NSData *)reducedData {  
  
	float *newReducedData = (float*) [reducedData bytes];
    float cur_perplexity = [[self perplexity] floatValue];
    perform_tsne([dataset floatData], 
				[[dataset d] unsignedIntValue], 
				[[dataset n] unsignedIntValue], 
				newReducedData, [self.d unsignedIntValue], 
                cur_perplexity);
}

@end
