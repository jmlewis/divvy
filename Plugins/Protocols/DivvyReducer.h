//
//  DivvyReducer.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyPlugin.h"

@class DivvyDataset;

@protocol DivvyReducer <NSObject, DivvyPlugin>

- (NSString *) reducerID;

- (NSNumber *) d;

- (void) calculateD:(DivvyDataset *)dataset;

- (void) reduceDataset:(DivvyDataset *)dataset
             reducedData:(NSData *)reducedData;

@end
