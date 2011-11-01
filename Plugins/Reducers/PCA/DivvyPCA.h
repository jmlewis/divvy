//
//  DivvyPCA.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyReducer.h"


@interface DivvyPCA : NSManagedObject <DivvyReducer>

@property (nonatomic, retain) NSString *reducerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *d;

@end
