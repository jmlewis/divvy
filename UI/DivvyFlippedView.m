//
//  DivvyFlippedView.m
//  Divvy
//
//  Created by Joshua Lewis on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyFlippedView.h"


@implementation DivvyFlippedView

- (BOOL)isFlipped
{
	return YES;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
}

@end
