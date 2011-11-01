//
//  DivvyNilPointVisualizer.h
//  Divvy
//
//  Created by Joshua Lewis on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyPointVisualizer.h"


@interface DivvyNilPointVisualizer : NSManagedObject <DivvyPointVisualizer>

@property (nonatomic, retain) NSString *pointVisualizerID;
@property (nonatomic, retain) NSString *name;

@end
