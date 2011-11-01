//
//  DivvyScatterPlotController.h
//  Divvy
//
//  Created by Joshua Lewis on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DivvyScatterPlotController : NSViewController

@property (nonatomic, retain) IBOutlet NSSlider *xAxisSlider;
@property (nonatomic, retain) IBOutlet NSSlider *yAxisSlider;

@end
