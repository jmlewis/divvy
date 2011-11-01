//
//  DivvyScatterPlotController.m
//  Divvy
//
//  Created by Joshua Lewis on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyScatterPlotController.h"

#import "DivvyAppDelegate.h"
#import "DivvyDatasetView.h"
#import "DivvyReducer.h"

#import "DivvyScatterPlot.h"


@implementation DivvyScatterPlotController

@synthesize xAxisSlider;
@synthesize yAxisSlider;

- (id)init
{
  if (!(self = [super init])) return nil;
 
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  [delegate addObserver:self forKeyPath:@"selectedDatasetView.selectedReducer.d" options:0 context:nil];
  
  return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  if(delegate.selectedDatasetView.selectedReducer) {
    int d = [delegate.selectedDatasetView.selectedReducer.d intValue] - 1; // The slider is zero based
    
    NSArray *sliders = [NSArray arrayWithObjects:xAxisSlider, yAxisSlider, nil];
    
    for(NSSlider *slider in sliders) {
      int value = [slider intValue];
      
      slider.maxValue = d;
      slider.numberOfTickMarks = d + 1;
      if (value > d)
        slider.intValue = d;
    }
    
    // If we're moving from low d to higher d, the NSSlider binding for the xAxis and yAxis values fire before this does.
    // The following code updates the slider positions to compensate. Maybe there's a better way to do this.
    for (id <DivvyDatasetVisualizer> datasetVisualizer in delegate.selectedDatasetView.datasetVisualizers) {
      if ([datasetVisualizer isKindOfClass:[DivvyScatterPlot class]]) {
        DivvyScatterPlot *scatterPlot = datasetVisualizer;
        xAxisSlider.intValue = scatterPlot.xAxis.intValue;
        yAxisSlider.intValue = scatterPlot.yAxis.intValue;
      }
    }
  }
}

- (void) dealloc {
  [xAxisSlider release];
  [yAxisSlider release];
  
  [super dealloc];
}

@end
