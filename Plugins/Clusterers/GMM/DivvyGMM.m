//
//
//  DivvyGMM.m
//
//  Written in 2014 by Jeremy Karnowski at the UC San Diego Natural Computation Lab,
//  Based on code written in 2011 by Josh Lewis
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyGMM.h"

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

#include "gmm.h"

@implementation DivvyGMM

@dynamic clustererID;
@dynamic name;

@dynamic helpURL;

@dynamic k;
@dynamic numRestarts;
@dynamic initCentroidsFromPointsInDataset;
@dynamic threshold;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.name = @"Gaussian Mixture Model";
  self.clustererID = [[NSProcessInfo processInfo] globallyUniqueString];
  self.threshold = @"0.001";
  self.helpURL = @"http://en.wikipedia.org/wiki/Mixture_model#Multivariate_Gaussian_mixture_model";
  
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
  [self addObserver:self forKeyPath:@"threshold" options:0 context:nil];
}

- (void) willTurnIntoFault {
  [self removeObserver:self forKeyPath:@"k"];
  [self removeObserver:self forKeyPath:@"numRestarts"];
  [self removeObserver:self forKeyPath:@"initCentroidsFromPointsInDataset"];
  [self removeObserver:self forKeyPath:@"threshold"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  [delegate.selectedDatasetView clustererChanged];
  [delegate reloadDatasetView:delegate.selectedDatasetView];
}

- (void) clusterDataset:(DivvyDataset *)dataset
             assignment:(NSData *)assignment {
  
  // Map Objective-C parameters to the parameters of the C function
  gmm([dataset floatData],
         [[dataset n] unsignedIntValue], 
         [[dataset d] unsignedIntValue], 
         [[self k] unsignedIntValue],
         [[self numRestarts] unsignedIntValue],
         [[self threshold] floatValue],
         (int *)[assignment bytes]);
}

@end
