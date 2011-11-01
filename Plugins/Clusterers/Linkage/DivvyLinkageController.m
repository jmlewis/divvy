//
//  DivvyLinkageController.m
//  Divvy
//
//  Created by Joshua Lewis on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyLinkageController.h"
#import "DivvyAppDelegate.h"
#import "DivvyDatasetView.h"

@implementation DivvyLinkageController

-(IBAction) changeParameter:(id)sender {
  DivvyAppDelegate *delegate = [NSApp delegate];
  [delegate.selectedDatasetView  clustererChanged];
  [delegate reloadSelectedDatasetViewImage];
}

@end
