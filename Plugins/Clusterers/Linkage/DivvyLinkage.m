//
//  DivvyLinkage.m
//  Divvy
//
//  Created by Joshua Lewis on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyLinkage.h"

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

#include "linkage.h"


@implementation DivvyLinkage

@dynamic clustererID;
@dynamic name;

@dynamic k;
@dynamic isComplete;

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
  [self addObserver:self forKeyPath:@"isComplete" options:0 context:nil];
}

- (void) willTurnIntoFault {
  [self removeObserver:self forKeyPath:@"k"];
  [self removeObserver:self forKeyPath:@"isComplete"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  [delegate.selectedDatasetView clustererChanged];
  [delegate reloadDatasetView:delegate.selectedDatasetView];
}

- (void) clusterDataset:(DivvyDataset *)dataset
             assignment:(NSData *)assignment {
  
  linkage([dataset floatData], 
          [[dataset n] unsignedIntValue], 
          [[dataset d] unsignedIntValue], 
          [[self k] unsignedIntValue],
          [[self isComplete] unsignedIntValue],
          (int *)[assignment bytes]);
}

@end
