//
//
//  DivvyKMeans.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyKMeans.h"

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

#include "kmeans.h"

@implementation DivvyKMeans

@dynamic clustererID;
@dynamic name;

@dynamic helpURL;

@dynamic k;
@dynamic numRestarts;
@dynamic initCentroidsFromPointsInDataset;

- (void) awakeFromInsert {
  [super awakeFromInsert];  
  
  self.clustererID = [[NSProcessInfo processInfo] globallyUniqueString];
  
  [self addObservers];
}

- (void) awakeFromFetch {
  [super awakeFromFetch];
  
  [self addObservers];
}

- (void) addObservers {
  [self addObserver:self forKeyPath:@"k" options:0 context:nil];
  [self addObserver:self forKeyPath:@"numRestarts" options:0 context:nil];
  [self addObserver:self forKeyPath:@"initCentroidsFromPointsInDataset" options:0 context:nil];
}

- (void) willTurnIntoFault {
  [self removeObserver:self forKeyPath:@"k"];
  [self removeObserver:self forKeyPath:@"numRestarts"];
  [self removeObserver:self forKeyPath:@"initCentroidsFromPointsInDataset"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  [delegate.selectedDatasetView clustererChanged];
  [delegate reloadDatasetView:delegate.selectedDatasetView];
}

- (void) clusterDataset:(DivvyDataset *)dataset
             assignment:(NSData *)assignment {
  
  // Map Objective-C parameters to the parameters of the C function
  kmeans([dataset floatData], 
         [[dataset n] unsignedIntValue], 
         [[dataset d] unsignedIntValue], 
         [[self k] unsignedIntValue],
         [[self numRestarts] unsignedIntValue],
         (int *)[assignment bytes]);
}

@end
