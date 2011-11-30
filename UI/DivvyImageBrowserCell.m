//
//  DivvyImageBrowserCell.m
//  
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyImageBrowserCell.h"

@implementation DivvyImageBrowserCell

- (CALayer *) layerForType:(NSString*) type
{
	CGColorRef color;
	
	NSRect frame = [self frame];

	if(type == IKImageBrowserCellSelectionLayer){
    
		// Create a selection layer
		CALayer *selectionLayer = [CALayer layer];
		selectionLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		
		const CGFloat strokeComponents[4] = {0.33, 0.66, 1.0, 1.0};
		
		// Set a border color
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		color = CGColorCreate(colorSpace, strokeComponents);
		[selectionLayer setBorderColor:color];
		CFRelease(color);
        
        CFRelease(colorSpace);
    
		[selectionLayer setBorderWidth:5.0];
		[selectionLayer setCornerRadius:5];
		
		return selectionLayer;
	}
  else {
    return [super layerForType:type];
  }

}

- (NSRect) selectionFrame
{
	return NSInsetRect([self frame], -8.0, -8.0);
}

@end
