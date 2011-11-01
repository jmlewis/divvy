//
//  DivvyImageBrowserView.m
//  Divvy
//
//  Created by Joshua Lewis on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyImageBrowserView.h"
#import "DivvyImageBrowserCell.h"


@implementation DivvyImageBrowserView

- (IKImageBrowserCell *) newCellForRepresentedItem:(id) cell
{
	return [[DivvyImageBrowserCell alloc] init];
}


@end
