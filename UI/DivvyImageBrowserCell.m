//
//  DivvyImageBrowserCell.m
//  Divvy
//
//  Created by Joshua Lewis on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyImageBrowserCell.h"


@implementation DivvyImageBrowserCell

- (CALayer *) layerForType:(NSString*) type
{
	CGColorRef color;
	
	NSRect frame = [self frame];

	if(type == IKImageBrowserCellSelectionLayer){
    
		//create a selection layer
		CALayer *selectionLayer = [CALayer layer];
		selectionLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		
		const CGFloat fillComponents[4] = {0.824, 0.165, 0.071, 0.0};
		const CGFloat strokeComponents[4] = {0.824, 0.165, 0.071, 1.0};
		
		//set a background color
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		color = CGColorCreate(colorSpace, fillComponents);
		[selectionLayer setBackgroundColor:color];
		CFRelease(color);
		
		//set a border color
		color = CGColorCreate(colorSpace, strokeComponents);
		[selectionLayer setBorderColor:color];
		CFRelease(color);
    
		[selectionLayer setBorderWidth:7.0];
		[selectionLayer setCornerRadius:5];
		
		return selectionLayer;
	}
  else {
    return [super layerForType:type];
  }

}

- (NSRect) selectionFrame
{
	return NSInsetRect([self frame], -7.0, -7.0);
}

@end
