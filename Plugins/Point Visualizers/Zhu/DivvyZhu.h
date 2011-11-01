//
//  DivvyZhu.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyPointVisualizer.h"


@interface DivvyZhu : NSManagedObject <DivvyPointVisualizer>

@property (nonatomic, retain) NSString *pointVisualizerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *lineWidth;

@end
