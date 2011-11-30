//
//  DivvyDatasetViewPanel.h
//  
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


//  Controller class for the plugin selection panel
@interface DivvyDatasetViewPanel : NSViewController

//  Views for the headers and bodies of the plugin control sections
@property (retain) IBOutlet NSView *datasetVisualizerHeader;
@property (retain) IBOutlet NSView *pointVisualizerHeader;
@property (retain) IBOutlet NSView *clustererHeader;
@property (retain) IBOutlet NSView *reducerHeader;
@property (retain) IBOutlet NSView *datasetVisualizerView;
@property (retain) IBOutlet NSView *pointVisualizerView;
@property (retain) IBOutlet NSView *clustererView;
@property (retain) IBOutlet NSView *reducerView;

//  Array controllers to represent the plugins attached to the selected dataset
//  view
@property (retain) IBOutlet NSArrayController *datasetVisualizerArrayController;
@property (retain) IBOutlet NSArrayController *pointVisualizerArrayController;
@property (retain) IBOutlet NSArrayController *clustererArrayController;
@property (retain) IBOutlet NSArrayController *reducerArrayController;

//  The selected plugins
@property (retain) IBOutlet NSObjectController *datasetVisualizerController;
@property (retain) IBOutlet NSObjectController *pointVisualizerController;
@property (retain) IBOutlet NSObjectController *clustererController;
@property (retain) IBOutlet NSObjectController *reducerController;

//  Displayed when no dataset view is selected
@property (retain) IBOutlet NSTextField *selectViewTextField;

// The scroll view that contains all the plugin control views
@property (retain) IBOutlet NSScrollView *scrollView;

//  Arrays that contain all the possible view controllers (one for each
//  plugin)
@property (retain) NSMutableArray *datasetVisualizerViewControllers;
@property (retain) NSMutableArray *pointVisualizerViewControllers;
@property (retain) NSMutableArray *clustererViewControllers;
@property (retain) NSMutableArray *reducerViewControllers;

//  Handlers for changing a plugin selection
- (IBAction) datasetVisualizerSelect:(id)sender;
- (IBAction) pointVisualizerSelect:(id)sender;
- (IBAction) clustererSelect:(id)sender;
- (IBAction) reducerSelect:(id)sender;

//  Loads the view controllers from the appropriate plugin bundles
- (void) loadPluginViewControllers;

//  Redraws the panel when anything changes
- (void) reflow;

@end
