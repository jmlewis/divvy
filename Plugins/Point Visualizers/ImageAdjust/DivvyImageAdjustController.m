//
//  DivvyImageController.m
//  Divvy
//
//  Created by Joshua Lewis on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyImageAdjustController.h"

#import "DivvyImageAdjust.h"
#import "DivvyAppDelegate.h"
#import "DivvyDatasetView.h"

@implementation DivvyImageAdjustController

@synthesize imageHeights;
@synthesize imageHeight;

- (IBAction) resample:(id)sender {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  DivvyImageAdjust *imagePointVisualizer = (DivvyImageAdjust *)delegate.selectedDatasetView.selectedPointVisualizer;
  [imagePointVisualizer resample];
  
  [delegate.selectedDatasetView  pointVisualizerChanged];
  [delegate reloadDatasetView:delegate.selectedDatasetView];
}

@end
