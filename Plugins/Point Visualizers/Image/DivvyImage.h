//
//  DivvyImage.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyPointVisualizer.h"


@interface DivvyImage : NSManagedObject <DivvyPointVisualizer>

@property (nonatomic, retain) NSString *pointVisualizerID;
@property (nonatomic, retain) NSString *name;

@end
