//
//  DivvyNilClusterer.h
//  Divvy
//
//  Created by Joshua Lewis on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyClusterer.h"

@interface DivvyNilClusterer : NSManagedObject <DivvyClusterer>

@property (nonatomic, retain) NSString *clustererID;
@property (nonatomic, retain) NSString *name;

@end
