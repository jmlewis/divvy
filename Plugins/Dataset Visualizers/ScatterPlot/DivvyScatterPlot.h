//
//  DivvyScatterPlot.h
//  Divvy
//
//  Created by Joshua Lewis on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyDatasetVisualizer.h"


@interface DivvyScatterPlot : NSManagedObject <DivvyDatasetVisualizer>

@property (nonatomic, retain) NSString *datasetVisualizerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *xAxis;
@property (nonatomic, retain) NSNumber *yAxis;
@property (nonatomic, retain) NSNumber *pointSize;

- (void) addObservers;

@end