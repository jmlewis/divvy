//
//  DivvyNilReducer.h
//  Divvy
//
//  Created by Joshua Lewis on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyReducer.h"


@interface DivvyNilReducer : NSManagedObject <DivvyReducer>

@property (nonatomic, retain) NSString *reducerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *d;

@end
