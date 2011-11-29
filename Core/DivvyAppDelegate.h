//
//  DivvyAppDelegate.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


@class DivvyDataset;
@class DivvyDatasetView;

@class DivvyDatasetViewPanel;
@class DivvyDatasetsPanel;
@class DivvyDatasetWindow;

@class DivvyPluginManager;
@class DivvyDelegateSettings;

//  DivvyAppDelegate manages application-wide resources and messages
@interface DivvyAppDelegate : NSObject <NSApplicationDelegate>

//  User interface controllers
@property (nonatomic, retain) DivvyDatasetViewPanel *datasetViewPanelController;
@property (nonatomic, retain) DivvyDatasetsPanel *datasetsPanelController;
@property (nonatomic, retain) DivvyDatasetWindow *datasetWindowController;
@property (nonatomic, retain) IBOutlet NSMenu *datasetViewContextMenu;

//  Pointers to the currently selected dataset and dataset view
@property (nonatomic, assign) DivvyDataset *selectedDataset;
@property (nonatomic, assign) DivvyDatasetView *selectedDatasetView;
@property (nonatomic, retain) NSIndexSet *selectedDatasets;

//  Plugin management
@property (nonatomic, retain) NSArray *pluginTypes;
@property (nonatomic, retain) NSArray *pluginDefaults;
@property (nonatomic, retain) DivvyPluginManager *pluginManager;

//  A managed object that stores top level settings
@property (nonatomic, retain) DivvyDelegateSettings *delegateSettings;

//  Core data support
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

//  The global operation queue--DivvyDatasetViewOperations are placed here for parallel execution
@property (nonatomic, retain) NSOperationQueue *operationQueue;

//  Support variables for the image browser cells
@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSImage *processingImage;


//  This is where the magic happens--create a Divvy operation and add it to the global queue
- (void) reloadDatasetView:(DivvyDatasetView *)datasetView;

//  Open and close dataset files
- (IBAction)openDatasets:(id)sender;
- (IBAction)closeDatasets:(id)sender;

//  Support for exporting .png and .csv representations of DivvyDatasetViews
- (IBAction)exportVisualization:(id)sender;
- (IBAction)exportData:(id)sender;

//  Open the help URL assigned to a plugin
- (IBAction) openHelp:url;

//  Dirty hack--will replace with better functionality
- (NSArray *)defaultSortDescriptors;

@end
