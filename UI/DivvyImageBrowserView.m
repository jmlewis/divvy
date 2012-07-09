//
//  DivvyImageBrowserView.m
//  
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyImageBrowserView.h"
#import "DivvyImageBrowserCell.h"
#import "DivvyDatasetView.h"

@implementation DivvyImageBrowserView

- (IKImageBrowserCell *) newCellForRepresentedItem:(id) cell
{
	return [[DivvyImageBrowserCell alloc] init];
}

- (void)mouseDown:(NSEvent *)event {
  NSPoint eventLocation = [event locationInWindow];
  eventLocation = [self convertPoint:eventLocation fromView:nil];
  NSInteger index = [self indexOfItemAtPoint:eventLocation];
  if (index != NSNotFound) {
    IKImageBrowserCell *cell = [self cellForItemAtIndex:index];
    
    if ([cell isSelected]) {
      // Better way to do this?
      NSPoint positionInCell;
      positionInCell.x = (eventLocation.x - cell.frame.origin.x) / cell.frame.size.width;
      positionInCell.y = (eventLocation.y - cell.frame.origin.y) / cell.frame.size.height;
      
      DivvyDatasetView *view = cell.representedItem;
      [view renderPoint:positionInCell inRect:cell.frame ofView:self];
    }
  }
  
  [super mouseDown:event]; // Switch selection
}

@end
