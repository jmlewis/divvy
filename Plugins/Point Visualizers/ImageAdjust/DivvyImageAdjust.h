//
//  DivvyImage.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyPointVisualizer.h"


@interface DivvyImageAdjust : NSManagedObject <DivvyPointVisualizer>

enum {
  DivvyRotationNone = 0,
  DivvyRotation90 = 1,
  DivvyRotation180 = 2,
  DivvyRotation270 = 3
};

@property (nonatomic, retain) NSString *pointVisualizerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *n;
@property (nonatomic, retain) NSNumber *numberOfSamples;
@property (nonatomic, retain) NSData *indices;

@property (nonatomic, retain) NSArray *imageHeights;
@property (nonatomic, retain) NSString *imageHeight;

@property (nonatomic, retain) NSNumber *rotation;
@property (nonatomic, retain) NSNumber *magnification;

@property (nonatomic, retain) NSNumber *blackIsTransparent;

- (void) addObservers;
- (void) resample;

- (void) drawPoint:(NSImage *) image
             index:(NSInteger) index
           dataset:(DivvyDataset *)dataset;

@end
