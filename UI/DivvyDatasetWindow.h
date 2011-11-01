//
//  DivvyDatasetWindow.h
//  Divvy
//
//  Created by Joshua Lewis on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class DivvyDatasetsPanel;
@class DivvyDatasetViewPanel;
@class DivvyImageBrowserView;

@interface DivvyDatasetWindow : NSWindowController

@property (retain) IBOutlet DivvyImageBrowserView *datasetViewsBrowser;
@property (retain) IBOutlet NSArrayController *datasetViewsArrayController;

@property (retain) IBOutlet DivvyDatasetsPanel *datasetsPanel;
@property (retain) IBOutlet DivvyDatasetViewPanel *datasetViewPanel;

- (IBAction)editDatasetViews:sender;

@end
