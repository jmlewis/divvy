//
//  DivvyDatasetWindow.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import <Quartz/Quartz.h>

@class DivvyDatasetsPanel;
@class DivvyDatasetViewPanel;
@class DivvyImageBrowserView;

//  Controller class for the main Divvy window
@interface DivvyDatasetWindow : NSWindowController

//  Image browser and the array of dataset views it displays
@property (retain) IBOutlet DivvyImageBrowserView *datasetViewsBrowser;
@property (retain) IBOutlet NSArrayController *datasetViewsArrayController;

//  View controllers for the sidebar subviews
@property (retain) IBOutlet DivvyDatasetsPanel *datasetsPanel;
@property (retain) IBOutlet DivvyDatasetViewPanel *datasetViewPanel;

//  Handles the +/- buttons in the bottom left of the window for adding and removing
//  views
- (IBAction)editDatasetViews:(id)sender;

//  Shows the export context menu on right click
- (void) imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index withEvent:(NSEvent *)event;

@end
