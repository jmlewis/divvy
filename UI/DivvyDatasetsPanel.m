//
//  DivvyDatasetPanel.m
//  
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


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
