//
//  DivvyScatterPlot.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyScatterPlot.h"

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

@implementation DivvyScatterPlot

@dynamic datasetVisualizerID;
@dynamic name;

@dynamic helpURL;

@dynamic xAxis;
@dynamic yAxis;
@dynamic pointSize;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.datasetVisualizerID = [[NSProcessInfo processInfo] globallyUniqueString];
  
  [self addObservers];
}

- (void) awakeFromFetch {
  [super awakeFromFetch];
  
  [self addObservers];
}

- (void) addObservers {
  [self addObserver:self forKeyPath:@"xAxis" options:0 context:nil];
  [self addObserver:self forKeyPath:@"yAxis" options:0 context:nil];
  [self addObserver:self forKeyPath:@"pointSize" options:0 context:nil];
}

- (void) willTurnIntoFault {
  [self removeObserver:self forKeyPath:@"xAxis"];
  [self removeObserver:self forKeyPath:@"yAxis"];
  [self removeObserver:self forKeyPath:@"pointSize"];

}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  [delegate.selectedDatasetView  datasetVisualizerChanged];
  [delegate reloadDatasetView:delegate.selectedDatasetView];
}

- (NSInteger) pointNearestTo:(NSPoint *) point
                 reducedData:(NSData *)reducedData
                     dataset:(DivvyDataset *)dataset {
  
  float *data = (float *)[reducedData bytes];
  unsigned int n = [[dataset n] unsignedIntValue];
  unsigned int d = reducedData.length / (n * sizeof(float));
  
  unsigned int xD = [self.xAxis unsignedIntValue];
  unsigned int yD = [self.yAxis unsignedIntValue];
  
  float minDistance = FLT_MAX;
  float distance;
  NSInteger index;
  
  // Should parallelize this
  for(int i = 0; i < n; i++) {
    // The reduced data are guaranteed to be between 0 and 1
    distance = pow(pow((*point).x - data[i * d + xD], 2) + pow((*point).y - data[i * d + yD], 2), .5);
    if (distance < minDistance) {
      minDistance = distance;
      index = i;
    }
  }
  
  // Adjust point to match actual location
  // Maybe this should be passed through a separate argument
  (*point).x = data[index * d + xD];
  (*point).y = data[index * d + yD];
  
  return index;
}

- (void) drawImage:(NSImage *) image 
    pointLocations:(NSData *)pointLocations
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset
        assignment:(NSData *)assignment {
  
  float *data = (float *)[reducedData bytes];
  float *locations = (float *)[pointLocations bytes];
  int *cluster_assignment = (int *)[assignment bytes];
  unsigned int n = [[dataset n] unsignedIntValue];

  [image lockFocus];
   
  NSColor* black = [NSColor blackColor];
  NSColor* white = [NSColor whiteColor];
  
  NSArray* clusterColors = [[NSArray alloc] initWithObjects:
                            [NSColor whiteColor], [NSColor blueColor], 
                            [NSColor redColor], [NSColor greenColor], 
                            [NSColor yellowColor], [NSColor magentaColor],
                            [NSColor brownColor], [NSColor grayColor],
                            [NSColor orangeColor], [NSColor cyanColor],
                            [NSColor purpleColor], nil];

  NSRect rect;

  float rectSize;
  unsigned int d = reducedData.length / (n * sizeof(float));
  unsigned int xD = [self.xAxis unsignedIntValue];
  unsigned int yD = [self.yAxis unsignedIntValue];
  rectSize = [self.pointSize floatValue];

  // get the view geometry and fill the background.

  NSRect bounds = image.alignmentRect;    
  [black set];
  NSRectFill ( bounds );

  bounds = NSInsetRect(bounds, rectSize, rectSize);

  [white set];
  rect.size.width = rectSize;
  rect.size.height = rectSize;
  
  for(int i = 0; i < n; i++) {
    // The reduced data are guaranteed to be between 0 and 1
    rect.origin.x = locations[2 * i] = data[i * d + xD] * bounds.size.width;
    rect.origin.y = locations[2 * i + 1] = data[i * d + yD] * bounds.size.height;

    [(NSColor *)[clusterColors objectAtIndex:cluster_assignment[i]] set];
    NSRectFill(rect); // Make this a NSRectFillListWithColors in the future
  }

  [image unlockFocus];
  
  [clusterColors release];
}

@end
