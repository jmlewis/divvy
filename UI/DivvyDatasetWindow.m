//
//  DivvyDatasetWindow.m
//  
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyDatasetWindow.h"

#import "DivvyAppDelegate.h"

#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

#import "DivvyImageBrowserView.h"

#import "DivvyDatasetsPanel.h"
#import "DivvyDatasetViewPanel.h"

#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"
#import "DivvyClusterer.h"

#import "DivvyAppDelegate.h"

@implementation DivvyDatasetWindow

@synthesize datasetViewsBrowser;
@synthesize datasetViewsArrayController;

@synthesize datasetsPanel;
@synthesize datasetViewPanel;

#pragma mark -
#pragma mark UI events
- (IBAction)editDatasetViews:(id)sender {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  NSInteger selectedSegment = [sender selectedSegment];
  NSInteger clickedSegmentTag = [[sender cell] tagForSegment:selectedSegment];

  if (clickedSegmentTag == 0) { // Add button
    DivvyDatasetView *datasetView = [NSEntityDescription insertNewObjectForEntityForName:@"DatasetView" inManagedObjectContext:delegate.managedObjectContext];
    datasetView.dataset = delegate.selectedDataset;
    [delegate reloadDatasetView:datasetView];
  }
  else { // Remove button
    for (id datasetView in [self.datasetViewsArrayController selectedObjects])
      [delegate.managedObjectContext deleteObject:datasetView];
  }
}

- (void) imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index withEvent:(NSEvent *)event {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  [NSMenu popUpContextMenu:delegate.datasetViewContextMenu withEvent:event forView:aBrowser];
}


#pragma mark -
#pragma mark Constrain panel subviews
// Don't let subviews completely obscure each other
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
  CGFloat min = 150.f;
  
  return min;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
  CGFloat max = splitView.frame.size.height - 150.f;
  
  return max;
}

#pragma mark -
#pragma mark loadWindow/dealloc
- (void) loadWindow {
  [super loadWindow];
  
  NSSortDescriptor *dateCreatedDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES] autorelease];
  NSArray *sortDescriptors = [NSArray arrayWithObjects:dateCreatedDescriptor, nil];
  
  [datasetViewsArrayController setSortDescriptors:sortDescriptors];
}

- (void) dealloc {
  [self.datasetViewsBrowser release];
  [self.datasetViewsArrayController release];
  
  [self.datasetsPanel release];
  [self.datasetViewPanel release];
  
  [super dealloc];
}

@end
