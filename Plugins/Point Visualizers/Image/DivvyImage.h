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

enum {
  DivvyRotationNone = 0,
  DivvyRotation90 = 1,
  DivvyRotation180 = 2,
  DivvyRotation270 = 3
};
typedef NSNumber DivvyRotation;

@property (nonatomic, retain) NSString *pointVisualizerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *numSamples;
@property (nonatomic, retain) NSNumber *imageHeight;
@property (nonatomic, retain) DivvyRotation *rotation;

@property (nonatomic, retain) NSData *samples;

- (void) addObservers;

@end
