//
//  DivvyScatterPlot.m
//  Divvy
//
//  Created by Joshua Lewis on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyScatterPlot.h"

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

@implementation DivvyScatterPlot

@dynamic datasetVisualizerID;
@dynamic name;

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

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  [delegate.selectedDatasetView  datasetVisualizerChanged];
  [delegate reloadSelectedDatasetViewImage];
}

- (void) drawImage:(NSImage *) image 
       reducedData:(NSData *)reducedData
          reducedD:(NSNumber *)reducedD
           dataset:(DivvyDataset *)dataset
        assignment:(NSData *)assignment {
  
  float *data = (float *)[reducedData bytes];
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

  float x, y, rectSize;
  int d = [reducedD intValue];
  int xD = [self.xAxis intValue];
  int yD = [self.yAxis intValue];
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
    x = data[i * d + xD];
    y = data[i * d + yD];

    // x and y are guaranteed to be between 0 and 1
    x = bounds.size.width * x;
    y = bounds.size.height * y;

    rect.origin.x = x;
    rect.origin.y = y;

    [(NSColor *)[clusterColors objectAtIndex:cluster_assignment[i]] set];
    NSRectFill(rect); // Make this a NSRectFillListWithColors in the future
  }

  [image unlockFocus];
  
  [clusterColors release];
}

@end
