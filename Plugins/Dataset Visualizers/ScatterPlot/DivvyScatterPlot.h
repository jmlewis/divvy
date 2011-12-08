//
//  DivvyScatterPlot.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyDatasetVisualizer.h"

@interface DivvyScatterPlot : NSManagedObject <DivvyDatasetVisualizer>

@property (nonatomic, retain) NSString *datasetVisualizerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *xAxis;
@property (nonatomic, retain) NSNumber *yAxis;
@property (nonatomic, retain) NSNumber *pointSize;

- (void) addObservers;

@end