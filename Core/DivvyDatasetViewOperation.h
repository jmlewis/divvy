//
//  DivvyDatasetViewOperation.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


@interface DivvyDatasetViewOperation : NSOperation

@property (nonatomic, retain) NSManagedObjectID *datasetViewID;

-(id) initWithObjectID:(NSManagedObjectID *)objectID;

@end
