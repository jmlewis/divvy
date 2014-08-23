//
//  DivvyImageController.h
//  Divvy
//
//  Created by Joshua Lewis on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DivvyImageAdjustController : NSViewController

@property (retain) IBOutlet NSArrayController *imageHeights;
@property (retain) IBOutlet NSObjectController *imageHeight;

- (IBAction) resample:(id)sender;

@end
