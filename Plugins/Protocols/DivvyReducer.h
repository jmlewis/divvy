//
//  DivvyReducer.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyPlugin.h"

@class DivvyDataset;

//  Defines the methods for a dimensionality reduction alogrithm
@protocol DivvyReducer <NSObject, DivvyPlugin>

- (NSString *) reducerID;

//  The dimensionality the reducer has reduced to
- (NSNumber *) d;

//  Figure out which d you'd like to use
- (void) calculateD:(DivvyDataset *)dataset;

//  Cluster the dataset and put the resulting reduction in reducedData
- (void) reduceDataset:(DivvyDataset *)dataset
             reducedData:(NSData *)reducedData;

@end
