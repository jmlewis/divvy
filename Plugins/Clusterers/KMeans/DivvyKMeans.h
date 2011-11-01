//
//  DivvyKMeans.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyClusterer.h"

@interface DivvyKMeans : NSManagedObject <DivvyClusterer>

// Core Data Accessors
@property (nonatomic, retain) NSString *clustererID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSString *helpURL;

@property (nonatomic, retain) NSNumber *k;
@property (nonatomic, retain) NSNumber *numRestarts;
@property (nonatomic, retain) NSNumber *initCentroidsFromPointsInDataset;

- (void) addObservers;

@end
