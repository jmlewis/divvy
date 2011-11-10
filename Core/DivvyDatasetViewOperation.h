//
//  DivvyPluginOperation.h
//  Divvy
//
//  Created by Joshua Lewis on 11/7/11.
//  Copyright (c) 2011 UCSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DivvyDatasetViewOperation : NSOperation

@property (nonatomic, retain) NSManagedObjectID *datasetViewID;

-(id) initWithObjectID:(NSManagedObjectID *)objectID;

@end
