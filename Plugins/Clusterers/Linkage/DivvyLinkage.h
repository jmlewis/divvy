//
//  DivvyLinkage.h
//  Divvy
//
//  Created by Joshua Lewis on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyClusterer.h"

@interface DivvyLinkage : NSManagedObject <DivvyClusterer>

// Core Data Accessors
@property (nonatomic, retain) NSString *clustererID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *k;
@property (nonatomic, retain) NSNumber *isComplete;

@end
