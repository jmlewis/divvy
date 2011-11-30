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
  NSColor *startingColor = [NSColor colorWithCalibratedRed:0.85f green:0.85f blue:0.85f alpha:1.0f];
  NSColor *endingColor = [NSColor colorWithCalibratedRed:0.7f green:0.7f blue:0.7f alpha:1.0f];  
  
  NSGradient* aGradient = [[NSGradient alloc]
                           initWithStartingColor:startingColor
                           endingColor:endingColor];
  [aGradient drawInRect:[self bounds] angle:270];}

@end
