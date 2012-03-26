//
//  DivvyAppDelegate.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu

#import "DivvyAppDelegate.h"

#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

#import "DivvyPlugin.h"
#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"
#import "DivvyClusterer.h"
#import "DivvyReducer.h"

#import "DivvyPluginManager.h"
#import "DivvyDatasetViewOperation.h"
#import "DivvyDelegateSettings.h"

#import "DivvyDatasetViewPanel.h"
#import "DivvyDatasetsPanel.h"
#import "DivvyDatasetWindow.h"

// Define constants declared in DivvyPlugin.h
NSString * const kDivvyDatasetVisualizer = @"datasetVisualizer";
NSString * const kDivvyPointVisualizer = @"pointVisualizer";
NSString * const kDivvyClusterer = @"clusterer";
NSString * const kDivvyReducer = @"reducer";

NSString * const kDivvyDefaultDatasetVisualizer = @"ScatterPlot";
NSString * const kDivvyDefaultPointVisualizer = @"NilPointVisualizer";
NSString * const kDivvyDefaultClusterer = @"KMeans";
NSString * const kDivvyDefaultReducer = @"NilReducer";

@implementation DivvyAppDelegate

@synthesize datasetViewPanelController;
@synthesize datasetsPanelController;
@synthesize datasetWindowController;
@synthesize datasetViewContextMenu;

@synthesize selectedDataset;
@synthesize selectedDatasetView;

@synthesize selectedDatasets;

@synthesize pluginTypes;
@synthesize pluginDefaults;

@synthesize pluginManager;
@synthesize delegateSettings;

@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;

@synthesize operationQueue;

@synthesize version;
@synthesize processingImage;

#pragma mark -
#pragma mark Handle application-wide messages
- (void) reloadDatasetView:(DivvyDatasetView *)datasetView {
  [datasetView setProcessingImage];
  
  NSError *error = nil;
  [self.managedObjectContext save:&error]; // Save any changes to the persistent store
  if(error) {
    NSString *message = [NSString stringWithFormat:@"%@ [%@]",
                         [error description], ([error userInfo] ? [[error userInfo] description] : @"no user info")];
    NSLog(@"CBA Failure message: %@", message);        
  }
  
  NSManagedObjectID *datasetViewID = datasetView.objectID;
  DivvyDatasetViewOperation *datasetViewOperation = [[DivvyDatasetViewOperation alloc] initWithObjectID:datasetViewID];
  
  // Check for existing operations on the same dataset view
  // The one with a completion block is the final one
  for (DivvyDatasetViewOperation *op in operationQueue.operations)
    if (op.completionBlock != nil && op.datasetViewID == datasetViewID) {
      op.completionBlock = nil;
      [datasetViewOperation addDependency:op];
    }
  
  // Reload the DatasetView image in main thread once processing is complete.
  [datasetViewOperation setCompletionBlock:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      // Pull the changes from the persistent store
      [self.managedObjectContext refreshObject:datasetView mergeChanges:YES];
      // Catch updates to selectedReducer.d -- this is the only other thing that can change
      // in a DatasetViewOperation
      [self.managedObjectContext refreshObject:datasetView.selectedReducer mergeChanges:YES];
      
      // Unset the processing image
      [datasetView reloadImage];
      
      // Refresh the image browser
      [self.datasetWindowController.datasetViewsBrowser reloadData];
    });
  }];
  
  [operationQueue addOperation:datasetViewOperation];
  [datasetViewOperation release];
  
  // Refresh to show processing image
  [self.datasetWindowController.datasetViewsBrowser reloadData];
}

- (IBAction) openDatasets:(id)sender {
  int result;
  NSArray *fileTypes = [NSArray arrayWithObject:@"bin"];
  NSOpenPanel *oPanel = [NSOpenPanel openPanel];
  DivvyDataset *dataset;
  
  [oPanel setAllowsMultipleSelection:YES];
  [oPanel setAllowedFileTypes:fileTypes];
  result = [oPanel runModal];
  if (result == NSOKButton) {
    NSArray *filesToOpen = [oPanel URLs];
    int i, count = [filesToOpen count];
    for (i=0; i<count; i++) {
      dataset = [NSEntityDescription insertNewObjectForEntityForName:@"Dataset" inManagedObjectContext:self.managedObjectContext];
      [dataset loadDataAtURL:[filesToOpen objectAtIndex:i]];
    }
  }
  NSError *error = nil;
  [managedObjectContext save:&error];
}

- (IBAction) openSampleDatasets:(id)sender {
  DivvyDataset *dataset;
  NSMenuItem *menuItem = (NSMenuItem *)sender;
  NSString *datasetName;
  
  switch (menuItem.tag) {
    case 0: // 3D Clusters
      datasetName = @"3dclust";
      break;
    case 1: // Swiss Roll
      datasetName = @"swissroll";
      break;
    case 2: // COIL 20
      datasetName = @"coil20";
      break;
    case 3: // Faces
      datasetName = @"faces";
      break;
    default:
      return;
  }
  
  dataset = [NSEntityDescription insertNewObjectForEntityForName:@"Dataset" inManagedObjectContext:self.managedObjectContext];
  [dataset loadDataAtURL:[[NSBundle mainBundle] URLForResource:datasetName withExtension:@"bin"]];

  NSError *error = nil;
  [managedObjectContext save:&error];
}

- (IBAction) closeDatasets:(id)sender {
  NSArray *datasets = [self.datasetsPanelController.datasetsArrayController arrangedObjects];
  
  NSError *error = nil;
  
  for (id dataset in [datasets objectsAtIndexes:self.selectedDatasets]) {
    for (id datasetView in [[dataset datasetViews] allObjects])
      [managedObjectContext deleteObject:datasetView];
    [managedObjectContext deleteObject:dataset];
    [managedObjectContext save:&error];
  }
}

- (IBAction)exportVisualization:(id)sender {
  NSArray *fileTypes = [NSArray arrayWithObject:@"png"];
  NSSavePanel *savePanel = [NSSavePanel savePanel];

  [savePanel setAllowedFileTypes:fileTypes];
  
  [savePanel beginSheetModalForWindow:datasetWindowController.window completionHandler:^(NSInteger result) {
    if (result == NSFileHandlingPanelOKButton) {
      NSData *imageData = self.selectedDatasetView.renderedImage.TIFFRepresentation;
      NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
      imageData = [imageRep representationUsingType:NSPNGFileType properties:nil];
      [imageData writeToURL:savePanel.URL atomically:NO];   
    }
  }];
}

- (IBAction)exportData:(id)sender {
  NSArray *fileTypes = [NSArray arrayWithObject:@"csv"];
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  NSMenuItem *menuItem = (NSMenuItem *)sender;
  [savePanel setAllowedFileTypes:fileTypes];
  
  [savePanel beginSheetModalForWindow:datasetWindowController.window completionHandler:^(NSInteger result) {
    if (result == NSFileHandlingPanelOKButton) {
      DivvyDatasetView *datasetView = self.selectedDatasetView;
      NSData *csvData;
      int n, d;
      n = datasetView.dataset.n.intValue;

      if (menuItem.tag == 0) { // Reduction
        csvData = (NSData *)[datasetView.reducerResults objectAtIndex:[datasetView.reducers indexOfObject:datasetView.selectedReducer]];
        d = datasetView.selectedReducer.d.intValue;
      }
      else { // Clustering
        csvData = (NSData *)[datasetView.clustererResults objectAtIndex:[datasetView.clusterers indexOfObject:datasetView.selectedClusterer]];
        d = 1;
      }
      
      NSMutableString *csvString = [NSMutableString string];
      
      
      // Each line is a dimension, columns are samples
      for (int i = 0; i < d; i++) {
        for (int j = 0; j < n; j++) {
          if (menuItem.tag == 0) {
            [csvString appendFormat:@"%f%@", ((float *)csvData.bytes)[j * d + i], (j < n - i ? @"," : @"")];
          } else {
            [csvString appendFormat:@"%d%@", ((int *)csvData.bytes)[j * d + i], (j < n - i ? @"," : @"")];
          }
        }
        [csvString appendString:@"\n"];
      }
      
      [csvString writeToURL:savePanel.URL atomically:NO encoding:NSASCIIStringEncoding error:nil];
    }
  }];
}

// Plugins can define a help URL--normally a web page--this opens it when the ? button is pressed
- (IBAction) openHelp:(NSString *)url {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

// Image browser cells need to update their version to have the browser reload them.
// Due to concurrency it's easier to just globally track versions here.
- (NSNumber *)version {
  self.version = [NSNumber numberWithInt:[version intValue] + 1];
  return version;
}

// Hack to get datasets to sort reasonably.
- (NSArray *)defaultSortDescriptors {
  return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
}

#pragma mark -
#pragma mark Update selection variables using KVO
// This stuff needs to be cleaned up, but it's an improvement over catching UI events.
// The observers are added in applicationDidFinishLaunching
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if([keyPath isEqual:@"selectedDatasets"]) {
    DivvyDataset *newDataset;

    if(self.selectedDatasets.count == 0)
      self.selectedDataset = nil;
    else {
      NSArray *datasets = [self.datasetsPanelController.datasetsArrayController arrangedObjects];
      newDataset = [datasets objectAtIndex:[self.selectedDatasets lastIndex]];

      NSIndexSet *cachedIndexes = [newDataset.selectedDatasetViews retain];
      
      // Don't update the selectedDatasetViews until after the ImageBrowser has nuked them and they've been restored
      [self removeObserver:self forKeyPath:@"selectedDataset.selectedDatasetViews"];
      self.selectedDataset = newDataset;
      [self addObserver:self forKeyPath:@"selectedDataset.selectedDatasetViews" options:0 context:nil];
      
      self.selectedDataset.selectedDatasetViews = cachedIndexes;
      [cachedIndexes release];
    }
  }
  
  if([keyPath isEqual:@"selectedDataset.selectedDatasetViews"]) {
    if(!self.selectedDataset || self.selectedDataset.selectedDatasetViews.count == 0)
        self.selectedDatasetView = nil;
    else {
      NSArray *datasetViews = [self.datasetWindowController.datasetViewsArrayController arrangedObjects];
      DivvyDatasetView *newDatasetView = [datasetViews objectAtIndex:[self.selectedDataset.selectedDatasetViews lastIndex]];

      // Fixes potential errors from uninitialized views when the bindings fire
      [newDatasetView willAccessValueForKey:nil];

      self.selectedDatasetView = newDatasetView;
    }
    [self.datasetViewPanelController reflow];
    [self.datasetViewPanelController.scrollView.documentView scrollPoint:NSMakePoint(0.0, 0.0)];
  }
}

#pragma mark -
#pragma mark Core Data support
- (NSString *)applicationSupportDirectory {
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
  return [basePath stringByAppendingPathComponent:@"Divvy"];
}


- (NSManagedObjectModel *)managedObjectModel {
  
  if (managedObjectModel) return managedObjectModel;
  
  NSMutableArray *models = [NSMutableArray array];
  [models addObject:[NSManagedObjectModel mergedModelFromBundles:nil]];
  [models addObjectsFromArray:[pluginManager pluginModels]];
  
  managedObjectModel = [[NSManagedObjectModel modelByMergingModels:models] retain];
  
  return managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
  
  if (persistentStoreCoordinator) return persistentStoreCoordinator;
  
  NSString *storeType = NSSQLiteStoreType;
  
  NSManagedObjectModel *mom = [self managedObjectModel];
  if (!mom) {
    NSAssert(NO, @"Managed object model is nil");
    NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
    return nil;
  }
  
  NSManagedObjectModel *momWithExistingStore = nil;
  
  // We will need to migrate if a new plugin has been added
  if(pluginManager.pluginModels.count != pluginManager.pluginModelsWithExistingStore.count) {
    NSMutableArray *modelsWithExistingStore = [NSMutableArray array];
    [modelsWithExistingStore addObject:[NSManagedObjectModel mergedModelFromBundles:nil]];
    [modelsWithExistingStore addObjectsFromArray:[pluginManager pluginModelsWithExistingStore]];
    
    momWithExistingStore = [NSManagedObjectModel modelByMergingModels:modelsWithExistingStore];
  }
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *applicationSupportDirectory = [self applicationSupportDirectory];
  NSError *error;
  
  if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
      NSAssert(NO, @"Failed to create App Support directory");
      NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
      return nil;
		}
  }
  
  NSMutableArray *configArray = [NSMutableArray array];
  [configArray addObject:@"DivvyCore"];
  
  for(Class aClass in [pluginManager pluginClasses])
    [configArray addObject:NSStringFromClass(aClass)];
  
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
  
  NSString *filePath;
  NSString *migrationFilePath;
  for (NSString *configName in configArray) {
    filePath = [configName stringByAppendingPathExtension:@"storedata"];
    filePath = [applicationSupportDirectory stringByAppendingPathComponent:filePath];

    NSURL *url = [NSURL fileURLWithPath:filePath];
        
    if (momWithExistingStore && [fileManager fileExistsAtPath:filePath]) {
      // Migrate the existing store
      NSURL *migrationURL;
      NSMappingModel *mappingModel;
      NSMigrationManager *manager;      
      
      mappingModel = [NSMappingModel inferredMappingModelForSourceModel:momWithExistingStore
                                                                       destinationModel:mom error:&error];
      if (!mappingModel) {
        NSString *message = [NSString stringWithFormat:@"Inferring failed %@ [%@]",
                             [error description], ([error userInfo] ? [[error userInfo] description] : @"no user info")];
        NSLog(@"Failure message: %@", message);
      }
      
      // Move the store file
      migrationFilePath = [configName stringByAppendingPathExtension:@"storedataprevious"];
      migrationFilePath = [applicationSupportDirectory stringByAppendingPathComponent:migrationFilePath];
      
      migrationURL = [NSURL fileURLWithPath:migrationFilePath];
      
      if(![fileManager moveItemAtURL:url toURL:migrationURL error:&error]) {
        NSString *message = [NSString stringWithFormat:@"File move failed %@ [%@]",
                             [error description], ([error userInfo] ? [[error userInfo] description] : @"no user info")];
        NSLog(@"Failure message: %@", message);        
      }
      
      
      NSValue *classValue = [[NSPersistentStoreCoordinator registeredStoreTypes] objectForKey:storeType];
      Class storeClass = (Class)[classValue pointerValue];
      Class storeMigrationManagerClass = [storeClass migrationManagerClass];
      
      manager = [[storeMigrationManagerClass alloc]
                                     initWithSourceModel:momWithExistingStore destinationModel:mom];

      if (![manager migrateStoreFromURL:migrationURL type:storeType
                                options:nil withMappingModel:mappingModel toDestinationURL:url
                        destinationType:storeType destinationOptions:nil error:&error]) {
        
        NSString *message = [NSString stringWithFormat:@"Migration failed %@ [%@]",
                             [error description], ([error userInfo] ? [[error userInfo] description] : @"no user info")];
        NSLog(@"Failure message: %@", message);
      }
      
      [manager release];
      
      // Delete the old store file
      [fileManager removeItemAtURL:migrationURL error:&error];
    }
    
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:storeType 
                                                  configuration:configName 
                                                            URL:url 
                                                        options:nil 
                                                          error:&error]){
      [[NSApplication sharedApplication] presentError:error];
      [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
      return nil;
    }
    
  }
  
  return persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
  
  if (managedObjectContext) return managedObjectContext;
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (!coordinator) { // Try deleting storedata
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error;
    
    [fileManager removeItemAtPath:applicationSupportDirectory error:&error];
    
    coordinator = [self persistentStoreCoordinator];
    if (!coordinator) { // That wasn't the problem--go ahead and present the error
      NSMutableDictionary *dict = [NSMutableDictionary dictionary];
      [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
      [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
      NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
      [[NSApplication sharedApplication] presentError:error];
      return nil;
    }
  }
  managedObjectContext = [[NSManagedObjectContext alloc] init];
  [managedObjectContext setPersistentStoreCoordinator: coordinator];
  [managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
  
  return managedObjectContext;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
  return [[self managedObjectContext] undoManager];
}

#pragma mark -
#pragma mark Init/dealloc &c.
- (id)init
{
  if (!(self = [super init])) return nil;
  
  pluginTypes = [[NSArray alloc] initWithObjects:kDivvyDatasetVisualizer, kDivvyPointVisualizer, kDivvyClusterer, kDivvyReducer, nil];
  pluginDefaults = [[NSArray alloc] initWithObjects:kDivvyDefaultDatasetVisualizer, kDivvyDefaultPointVisualizer, kDivvyDefaultClusterer, kDivvyDefaultReducer, nil];
  
  pluginManager = [DivvyPluginManager shared];
  
  operationQueue = [[NSOperationQueue alloc] init];
  //[operationQueue setMaxConcurrentOperationCount:24] // Base this on number of cores/threads per core?
  
  version = [NSNumber numberWithInt:0];
  
  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.processingImage = [[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"processing" withExtension:@"png"]] autorelease];  
  
  // Load UI
  DivvyDatasetWindow *datasetWindow;
  datasetWindow = [[DivvyDatasetWindow alloc] initWithWindowNibName:@"DatasetWindow"];
  [datasetWindow showWindow:nil];
  self.datasetWindowController = datasetWindow;
  self.datasetsPanelController = datasetWindow.datasetsPanel;
  self.datasetViewPanelController = datasetWindow.datasetViewPanel;
  [datasetWindow release];
  
  // Load the datasets from the managed object context early so that we can set the saved selection in applicationDidFinishLaunching
  NSError *error = nil;
  [self.datasetsPanelController.datasetsArrayController fetchWithRequest:nil merge:NO error:&error];
  
  NSEntityDescription *datasetViewEntityDescription = [self.managedObjectModel.entitiesByName objectForKey:@"DatasetView"];
  NSFetchRequest *datasetViewRequest = [[[NSFetchRequest alloc] init] autorelease];
  [datasetViewRequest setEntity:datasetViewEntityDescription];
  NSArray *datasetViewArray = [self.managedObjectContext executeFetchRequest:datasetViewRequest error:&error];
  
  // Fetch the dataset views and start drawing them
  for (DivvyDatasetView *datasetView in datasetViewArray) {
    [datasetView updatePlugins]; // Check if there are any new plugins since last time Divvy launched
    [self reloadDatasetView:datasetView];
  }
  
  [self.datasetViewPanelController loadPluginViewControllers];
  
  // Connect to delegateSettings
  NSEntityDescription *delegateSettingsEntityDescription = [self.managedObjectModel.entitiesByName objectForKey:@"DelegateSettings"];
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  [request setEntity:delegateSettingsEntityDescription];
  NSArray *delegateSettingsArray = [self.managedObjectContext executeFetchRequest:request error:&error];
  
  if(delegateSettingsArray.count == 0)
    self.delegateSettings = [NSEntityDescription insertNewObjectForEntityForName:delegateSettingsEntityDescription.name inManagedObjectContext:self.managedObjectContext];
  else {
    self.delegateSettings = [delegateSettingsArray objectAtIndex:0];
  }
  
  [self addObserver:self forKeyPath:@"selectedDatasets" options:0 context:nil];
  [self addObserver:self forKeyPath:@"selectedDataset.selectedDatasetViews" options:0 context:nil];
  
  if(self.delegateSettings.selectedDatasets)
    self.selectedDatasets = self.delegateSettings.selectedDatasets;
  else
    [self.datasetViewPanelController reflow];
  
}



- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {    
  // Save the selected datasets.
  self.delegateSettings.selectedDatasets = self.selectedDatasets;
  
  // Don't save all the images between sessions--it makes things slow and takes up a lot of disk
  // Maybe we can do this by internally representing images with .pngs.
  unsigned int i;
  NSMutableArray *results;
  for(DivvyDataset *dataset in self.datasetsPanelController.datasetsArrayController.arrangedObjects)
    for(DivvyDatasetView *datasetView in dataset.datasetViews.allObjects) {
      results = [datasetView.datasetVisualizerResults mutableCopy];
      for(i = 0; i < results.count; i++)
        [results replaceObjectAtIndex:i withObject:[NSNull null]];
      datasetView.datasetVisualizerResults = results;

      results = [datasetView.pointVisualizerResults mutableCopy];
      for(i = 0; i < results.count; i++)
        [results replaceObjectAtIndex:i withObject:[NSNull null]];
      datasetView.pointVisualizerResults = results;
    }
  
  // Stops a bunch of CoreGraphics errors from the binding between the dataset window
  // title and the selected dataset title. There's probably a better way to fix them though.  
  self.selectedDataset = nil;
  
  if (!managedObjectContext) return NSTerminateNow;
  
  if (![managedObjectContext commitEditing]) {
    NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
    return NSTerminateCancel;
  }
  
  if (![managedObjectContext hasChanges]) return NSTerminateNow;
  
  NSError *error = nil;
  if (![managedObjectContext save:&error]) {
    BOOL result = [sender presentError:error];
    if (result) return NSTerminateCancel;
    
    NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
    NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
    NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
    NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:question];
    [alert setInformativeText:info];
    [alert addButtonWithTitle:quitButton];
    [alert addButtonWithTitle:cancelButton];
    
    NSInteger answer = [alert runModal];
    [alert release];
    alert = nil;
    
    if (answer == NSAlertAlternateReturn) return NSTerminateCancel;
    
  }
  
  return NSTerminateNow;
}

- (void)dealloc {
  [datasetsPanelController release];
  [datasetViewPanelController release];
  [datasetWindowController release];
  [datasetViewContextMenu release];
  
  [selectedDatasets release];
  
  [pluginTypes release];
  [pluginDefaults release];
  
  [pluginManager release];
  [delegateSettings release];
  
  [managedObjectContext release];
  [persistentStoreCoordinator release];
  [managedObjectModel release];
  
  [operationQueue release];
  
  [version release];
  [processingImage release];
  
  [super dealloc];
}

@end