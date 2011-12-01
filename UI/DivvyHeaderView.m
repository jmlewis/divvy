//
//  DivvyHeaderView.m
//  
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyHeaderView.h"

@implementation DivvyHeaderView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  NSColor *headerColor = [NSColor colorWithCalibratedRed:0.87f green:0.87f blue:0.87f alpha:1.0f];
  NSColor *borderColor = [NSColor colorWithCalibratedRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
  
  [headerColor drawSwatchInRect:self.bounds];
  
  [borderColor setStroke];
  NSBezierPath* aPath = [NSBezierPath bezierPath];
  
  [aPath moveToPoint:NSMakePoint(self.bounds.origin.x, self.bounds.origin.y)];
  [aPath lineToPoint:NSMakePoint(self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y)];
  [aPath moveToPoint:NSMakePoint(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height)];
  [aPath lineToPoint:NSMakePoint(self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y + self.bounds.size.height)];
  [aPath stroke];
}

@end
