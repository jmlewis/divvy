//
//  DivvyPointVisualizer.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyPlugin.h"

@class DivvyDataset;

@protocol DivvyPointVisualizer <NSObject, DivvyPlugin>

- (NSString *) pointVisualizerID;

- (void) drawImage:(NSImage *) image
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset;

@end
