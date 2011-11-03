//
//  DivvyHeaderView.m
//  Divvy
//
//  Created by Joshua Lewis on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
  NSColor *endingColor = [NSColor colorWithCalibratedRed:0.75f green:0.75f blue:0.75f alpha:1.0f];  
  
  NSGradient* aGradient = [[NSGradient alloc]
                           initWithStartingColor:startingColor
                           endingColor:endingColor];
  [aGradient drawInRect:[self bounds] angle:270];}

@end
