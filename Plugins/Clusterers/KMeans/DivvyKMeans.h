//
//  DivvyKMeans.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyClusterer.h"

//  Objective-C wrapper for the code in kmeans.c. Maintains parameter state using
//  Core Data.
@interface DivvyKMeans : NSManagedObject <DivvyClusterer>

//  Basic plugin properties.
@property (nonatomic, retain) NSString *clustererID;
@property (nonatomic, retain) NSString *name;

//  Defining this enables the question mark button in the plugin UI.
@property (nonatomic, retain) NSString *helpURL;

//  Parameters specific to k-means.
@property (nonatomic, retain) NSNumber *k;
@property (nonatomic, retain) NSNumber *numRestarts;
@property (nonatomic, retain) NSNumber *initCentroidsFromPointsInDataset;

//  Add observers that send the delegate appropriate messages when parameters change.
- (void) addObservers;

@end
