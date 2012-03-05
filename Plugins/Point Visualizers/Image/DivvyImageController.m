//
//  DivvyImageController.m
//  Divvy
//
//  Created by Joshua Lewis on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyImageController.h"

#import "DivvyImage.h"
#import "DivvyAppDelegate.h"
#import "DivvyDatasetView.h"

@implementation DivvyImageController

@synthesize imageHeights;
@synthesize imageHeight;

- (IBAction) imageHeightSelect:(id)sender {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  DivvyImage *imagePointVisualizer = (DivvyImage *)delegate.selectedDatasetView.selectedPointVisualizer;
  imagePointVisualizer.imageHeight = imageHeight.content;
}

- (IBAction) resample:(id)sender {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  DivvyImage *imagePointVisualizer = (DivvyImage *)delegate.selectedDatasetView.selectedPointVisualizer;
  [imagePointVisualizer resample];
  
  [delegate.selectedDatasetView  pointVisualizerChanged];
  [delegate reloadDatasetView:delegate.selectedDatasetView];
}

@end
