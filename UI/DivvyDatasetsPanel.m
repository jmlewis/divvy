//
//  DivvyDatasetPanel.m
//  Divvy
//
//  Created by Joshua Lewis on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyAppDelegate.h"
#import "DivvyDatasetsPanel.h"
#import "DivvyDataset.h"

@implementation DivvyDatasetsPanel

@synthesize datasetsTable;
@synthesize datasetsArrayController;

- (IBAction) editDatasets:(id)sender {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  NSInteger selectedSegment = [sender selectedSegment];
  NSInteger clickedSegmentTag = [[sender cell] tagForSegment:selectedSegment];
  
  if (clickedSegmentTag == 0) // Add button
    [delegate openDatasets:sender];
  else // Remove button
    [delegate closeDatasets:sender];
}

- (void) dealloc {
  [datasetsTable release];
  [datasetsArrayController release];
  
  [super dealloc];
}

@end
