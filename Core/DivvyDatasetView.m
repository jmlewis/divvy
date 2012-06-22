//
//  DivvyDatasetView.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyDatasetView.h"

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"

#import "DivvyDatasetWindow.h"

#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"
#import "DivvyClusterer.h"
#import "DivvyReducer.h"

// Support for the dataset custom accessor.
@interface DivvyDatasetView (PrimitiveAccessors)
- (void)setPrimitiveDataset:(DivvyDataset *)newDataset;
@end

@implementation DivvyDatasetView

@dynamic uniqueID;
@synthesize version;
@dynamic dateCreated;

@dynamic dataset;

@dynamic datasetVisualizerIDs;
@dynamic pointVisualizerIDs;
@dynamic clustererIDs;
@dynamic reducerIDs;

@dynamic selectedDatasetVisualizerID;
@dynamic selectedPointVisualizerID;
@dynamic selectedClustererID;
@dynamic selectedReducerID;

@dynamic datasetVisualizerResults;
@dynamic pointVisualizerResults;
@dynamic clustererResults;
@dynamic reducerResults;

@dynamic pointLocations;

@synthesize datasetVisualizers;
@synthesize pointVisualizers;
@synthesize clusterers;
@synthesize reducers;

@synthesize selectedDatasetVisualizer;
@synthesize selectedPointVisualizer;
@synthesize selectedClusterer;
@synthesize selectedReducer;

@synthesize renderedImage;


#pragma mark -
#pragma mark 'IKImageBrowserItem' Protocol Methods
-(NSString *) imageTitle {
  return @"DivvyDatasetView";
}

- (NSString*) imageUID {
  
  // return uniqueID if it exists.
  NSString* uniqueID = self.uniqueID;
  if ( uniqueID ) return uniqueID;
  [self generateUniqueID];
  return self.uniqueID;
}

- (NSString *) imageRepresentationType {
  return IKImageBrowserNSImageRepresentationType;
}

- (id) imageRepresentation {
  return self.image;
}

- (NSUInteger) imageVersion {
  return [[self version] unsignedIntValue];
}

#pragma mark -
#pragma mark 'IKImageBrowserItem' support
- (void) generateUniqueID {
  
  NSString* uniqueID = self.uniqueID;
  if ( uniqueID != nil ) return;
  self.uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) setProcessingImage {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  self.renderedImage = delegate.processingImage;
  self.version = delegate.version;
}

- (void) reloadImage {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  self.renderedImage = nil;
  self.version = delegate.version;
}

#pragma mark -
#pragma mark Plugin management
- (void) createPlugins {
  // Could be cleaned up a bit
  DivvyAppDelegate *delegate = [NSApp delegate];
  NSManagedObjectContext* moc = self.managedObjectContext;
  NSManagedObjectModel* mom = delegate.managedObjectModel;
  NSArray *pluginTypes = delegate.pluginTypes;
  NSArray *pluginDefaults = delegate.pluginDefaults;
  
  NSMutableArray *pointLocations = [NSMutableArray array];
  
  for(NSString *pluginType in pluginTypes) {
    NSMutableArray *plugins = [NSMutableArray array];
    NSMutableArray *pluginIDs = [NSMutableArray array];
    [self setValue:plugins forKey:[NSString stringWithFormat:@"%@s", pluginType]];
    [self setValue:pluginIDs forKey:[NSString stringWithFormat:@"%@IDs", pluginType]];
    
    for(NSEntityDescription *anEntityDescription in [mom entities])
      if([anEntityDescription.propertiesByName objectForKey:[NSString stringWithFormat:@"%@ID", pluginType]]) {
        
        id anEntity = [NSEntityDescription insertNewObjectForEntityForName:anEntityDescription.name inManagedObjectContext:moc];
        
        [[self valueForKey:[NSString stringWithFormat:@"%@s", pluginType]] addObject:anEntity];
        [[self valueForKey:[NSString stringWithFormat:@"%@IDs", pluginType]] addObject:[anEntity valueForKey:[NSString stringWithFormat:@"%@ID", pluginType]]];
        
        if([anEntityDescription.name isEqual:[pluginDefaults objectAtIndex:[pluginTypes indexOfObject:pluginType]]]) {
          [self setValue:anEntity 
                  forKey:[NSString stringWithFormat:@"selected%@%@", 
                          [[pluginType substringToIndex:1] capitalizedString], 
                          [pluginType substringFromIndex:1]]];
        }
      }
    
    NSMutableArray *pluginResults = [NSMutableArray array];
    for(id aPlugin in [self valueForKey:[NSString stringWithFormat:@"%@s", pluginType]]) {
      [pluginResults addObject:[NSNull null]];
      if ([pluginType isEqualToString:@"datasetVisualizer"])
        [pointLocations addObject:[NSNull null]];
    }
    [self setValue:pluginResults forKey:[NSString stringWithFormat:@"%@Results", pluginType]];
  }
  self.pointLocations = pointLocations;
}

- (void) updatePlugins {
  // If there are new plugins since the last time we ran Divvy, add them
  DivvyAppDelegate *delegate = [NSApp delegate];
  NSManagedObjectContext* moc = delegate.managedObjectContext;
  NSManagedObjectModel* mom = delegate.managedObjectModel;
  NSArray *pluginTypes = delegate.pluginTypes;
  
  NSMutableArray *pointLocations = [self.pointLocations mutableCopy];
  
  for(NSString *pluginType in pluginTypes) {
    NSMutableArray *plugins = [self valueForKey:[NSString stringWithFormat:@"%@s", pluginType]];
    NSMutableArray *pluginIDs = [self valueForKey:[NSString stringWithFormat:@"%@IDs", pluginType]];
    NSMutableArray *pluginResults = [self valueForKey:[NSString stringWithFormat:@"%@Results", pluginType]]; // These aren't mutable, but this seems to work... (could add mutableCopy logic)
    
    for(NSEntityDescription *anEntityDescription in [mom entities])
      if([anEntityDescription.propertiesByName objectForKey:[NSString stringWithFormat:@"%@ID", pluginType]]) {
        BOOL entityExists = FALSE;
        
        for(NSManagedObject *aPlugin in plugins)
          if ([aPlugin.entity isEqual:anEntityDescription])
            entityExists = TRUE;
        
        if(!entityExists) {
          id anEntity = [NSEntityDescription insertNewObjectForEntityForName:anEntityDescription.name inManagedObjectContext:moc];
          
          // Set dataset if the plugin responds to changeDataset.
          if ([anEntity respondsToSelector:@selector(changeDataset:)]) {
            [anEntity changeDataset:self.dataset];
          }
          
          [plugins addObject:anEntity];
          [pluginIDs addObject:[anEntity valueForKey:[NSString stringWithFormat:@"%@ID", pluginType]]];
          [pluginResults addObject:[NSNull null]];
          if ([pluginType isEqualToString:@"datasetVisualizer"])
            [pointLocations addObject:[NSNull null]];
        }
      }
    self.pointLocations = pointLocations;
  }
}

#pragma mark -
#pragma mark Invalidate and recompute plugin results
// This is the main recomputation method--it is the main call in DivvyDatasetOperation
- (void) checkForNullPluginResults {
  // We require a specific order, so we don't use the delegate version
  // Make this a (constant?) member of DatasetView so we don't have to recalculate it every time
  NSArray *pluginTypes = [[NSArray alloc] initWithObjects:kDivvyClusterer, kDivvyReducer, kDivvyDatasetVisualizer, kDivvyPointVisualizer, nil];
  
  for(NSString *pluginType in pluginTypes) {
    NSArray *plugins = [self valueForKey:[NSString stringWithFormat:@"%@s", pluginType]];
    NSArray *pluginResults = [self valueForKey:[NSString stringWithFormat:@"%@Results", pluginType]];
    id <DivvyPlugin> selectedPlugin = [self valueForKey:[NSString stringWithFormat:@"selected%@%@", 
                                           [[pluginType substringToIndex:1] capitalizedString], 
                                           [pluginType substringFromIndex:1]]];
    
    int index = [plugins indexOfObject:selectedPlugin];
    
    id result = [pluginResults objectAtIndex:index];
    
    if(result == [NSNull null]) {
      SEL pluginUpdate = NSSelectorFromString([NSString stringWithFormat:@"%@Update", pluginType]);
      [self performSelector:pluginUpdate];
    }
  }
    
  [pluginTypes release];
}

// This code, and similar code below it, is obviously repetitive
- (void) datasetVisualizerChanged {
  int datasetVisualizerIndex = [self.datasetVisualizers indexOfObject:self.selectedDatasetVisualizer];
  NSMutableArray *results = [self.datasetVisualizerResults mutableCopy];
  [results replaceObjectAtIndex:datasetVisualizerIndex withObject:[NSNull null]];
  self.datasetVisualizerResults = results;
}
   
 - (void) pointVisualizerChanged {
   int pointVisualizerIndex = [self.pointVisualizers indexOfObject:self.selectedPointVisualizer];  
   NSMutableArray *results = [self.pointVisualizerResults mutableCopy];
   [results replaceObjectAtIndex:pointVisualizerIndex withObject:[NSNull null]];
   self.pointVisualizerResults = results;
 }

- (void) clustererChanged {
  int clustererIndex = [self.clusterers indexOfObject:self.selectedClusterer];
  NSMutableArray *results = [self.clustererResults mutableCopy];
  [results replaceObjectAtIndex:clustererIndex withObject:[NSNull null]];
  self.clustererResults = results;
}

- (void) reducerChanged {
  int reducerIndex = [self.reducers indexOfObject:self.selectedReducer];  
  NSMutableArray *results = [self.reducerResults mutableCopy];
  [results replaceObjectAtIndex:reducerIndex withObject:[NSNull null]];
  self.reducerResults = results;
}

- (void) datasetVisualizerUpdate {
  int datasetVisualizerIndex = [self.datasetVisualizers indexOfObject:self.selectedDatasetVisualizer];
  int clustererIndex = [self.clusterers indexOfObject:self.selectedClusterer];
  int reducerIndex = [self.reducers indexOfObject:self.selectedReducer];
  
  // If the current reducer or clusterer result is null, there's another computation pending and we don't have to draw
  NSData *reducerResult = [self.reducerResults objectAtIndex:reducerIndex];
  NSData *clustererResult = [self.clustererResults objectAtIndex:clustererIndex];
  
  if(reducerResult != (NSData *)[NSNull null] && clustererResult != (NSData *)[NSNull null]) {
    [reducerResult retain];
    [clustererResult retain];
    
    NSSize imageSize = NSMakeSize(1024, 1024); // Size of output image
    NSImage *newImage = [[NSImage alloc] initWithSize:imageSize];

    // Allocate memory for new point locations (could do this only once in setDataset/updatePlugins...)
    int numBytes = 2 * [self.dataset.n intValue] * sizeof(int);
    int *newAssignment = malloc(numBytes);
    NSData *newData = [[NSData alloc] initWithBytesNoCopy:newAssignment length:numBytes freeWhenDone:YES];
    NSMutableArray *locations = [self.pointLocations mutableCopy];
    [locations replaceObjectAtIndex:datasetVisualizerIndex withObject:newData];
    self.pointLocations = locations;
        
    [self.selectedDatasetVisualizer drawImage:newImage
                               pointLocations:[self.pointLocations objectAtIndex:datasetVisualizerIndex]
                                  reducedData:reducerResult
                                      dataset:self.dataset
                                   assignment:clustererResult];

    [reducerResult release];
    [clustererResult release];
    
    NSMutableArray *results = [self.datasetVisualizerResults mutableCopy];
    [results replaceObjectAtIndex:datasetVisualizerIndex withObject:newImage];
    self.datasetVisualizerResults = results;
    
    [newImage release];
  }
  
  [self pointVisualizerChanged];
}

- (void) pointVisualizerUpdate {
  int datasetVisualizerIndex = [self.datasetVisualizers indexOfObject:self.selectedDatasetVisualizer];
  int pointVisualizerIndex = [self.pointVisualizers indexOfObject:self.selectedPointVisualizer];
  int clustererIndex = [self.clusterers indexOfObject:self.selectedClusterer];
  int reducerIndex = [self.reducers indexOfObject:self.selectedReducer];  
  
  // If the current reducer result is null, there's another computation pending and we don't have to draw
  NSData *reducerResult = [self.reducerResults objectAtIndex:reducerIndex];
  NSData *clustererResult = [self.clustererResults objectAtIndex:clustererIndex];
  
  if(reducerResult != (NSData *)[NSNull null] && clustererResult != (NSData *)[NSNull null]) {
    [reducerResult retain];
    [clustererResult retain];
    
    NSSize imageSize = NSMakeSize(1024, 1024); // Size of output image
    NSImage *newImage = [[NSImage alloc] initWithSize:imageSize];

    [self.selectedPointVisualizer drawImage:newImage
                             pointLocations:[self.pointLocations objectAtIndex:datasetVisualizerIndex]
                                reducedData:reducerResult
                                    dataset:self.dataset
                                 assignment:clustererResult];
    
    [reducerResult release];
    [clustererResult release];
    
    NSMutableArray *results = [self.pointVisualizerResults mutableCopy];
    [results replaceObjectAtIndex:pointVisualizerIndex withObject:newImage];
    self.pointVisualizerResults = results;
    
    [newImage release];
  }
}

- (void) clustererUpdate {
  int clustererIndex = [self.clusterers indexOfObject:self.selectedClusterer];  

  int numBytes = [self.dataset.n intValue] * sizeof(int);
  int *newAssignment = malloc(numBytes);
  NSData *newData = [[NSData alloc] initWithBytesNoCopy:newAssignment length:numBytes freeWhenDone:YES];
  
  [self.selectedClusterer clusterDataset:self.dataset
                              assignment:newData];
  
  NSMutableArray *results = [self.clustererResults mutableCopy];
  [results replaceObjectAtIndex:clustererIndex withObject:newData];
  self.clustererResults = results;
  
  [newData release];
  
  [self datasetVisualizerChanged];
  [self pointVisualizerChanged];
}

- (void) reducerUpdate {
  int reducerIndex = [self.reducers indexOfObject:self.selectedReducer];
  
  [self.selectedReducer calculateD:self.dataset];
  
  int numBytes = [self.dataset.n intValue] * [self.selectedReducer.d unsignedIntValue] * sizeof(float);
  int *newReducedData = malloc(numBytes);
  NSData *newData = [[NSData alloc] initWithBytesNoCopy:newReducedData length:numBytes freeWhenDone:YES];
  
  [self.selectedReducer reduceDataset:self.dataset
                          reducedData:newData];
  
  
  NSMutableArray *results = [self.reducerResults mutableCopy];
  [results replaceObjectAtIndex:reducerIndex withObject:newData];
  self.reducerResults = results;
  
  [newData release];
  
  [self datasetVisualizerChanged];
  [self pointVisualizerChanged];
}

- (NSImage *) image {
  if ( self.renderedImage ) return self.renderedImage;
  
  int datasetVisualizerIndex = [self.datasetVisualizers indexOfObject:self.selectedDatasetVisualizer];  
  int pointVisualizerIndex = [self.pointVisualizers indexOfObject:self.selectedPointVisualizer];  
  
  // Composite the dataset and point visualizers
  NSSize imageSize = NSMakeSize(1024, 1024); // Size of output image
  NSImage *image = [[NSImage alloc] initWithSize:imageSize];
  
  NSImage *datasetVisualizerImage = [self.datasetVisualizerResults objectAtIndex:datasetVisualizerIndex];
  NSImage *pointVisualizerImage = [self.pointVisualizerResults objectAtIndex:pointVisualizerIndex];
  
  [image lockFocus];
  if (datasetVisualizerImage != (NSImage *)[NSNull null])
    [datasetVisualizerImage drawAtPoint:NSMakePoint(0.f, 0.f) 
                               fromRect:NSZeroRect 
                              operation:NSCompositeSourceOver 
                               fraction:1.0];

  if (pointVisualizerImage != (NSImage *)[NSNull null])
    [pointVisualizerImage drawAtPoint:NSMakePoint(0.f, 0.f) 
                             fromRect:NSZeroRect 
                            operation:NSCompositeSourceOver 
                             fraction:1.0];  
  [image unlockFocus];
  
  self.renderedImage = image;
    
  [image release];
  
  return self.renderedImage;
}

- (void) renderPoint:(NSPoint) point {
  int reducerIndex = [self.reducers indexOfObject:self.selectedReducer];
  
  NSData *reducerResult = [self.reducerResults objectAtIndex:reducerIndex];

  NSInteger index = [self.selectedDatasetVisualizer pointNearestTo:point 
                                                       reducedData:reducerResult
                                                           dataset:self.dataset];
  
  NSLog(@"%ld", index);
}

#pragma mark -
#pragma mark Core Data awake
- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.dateCreated = [NSDate date];
   
  [self createPlugins];
  
  [self generateUniqueID];
}

- (void) awakeFromFetch {
  [super awakeFromFetch];
  
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  // Reconnect datasetView with its components.
  // This could be simpler for fetches inside DivvyDatasetViewOperation
  NSManagedObjectContext *moc = self.managedObjectContext;
  NSManagedObjectModel *mom = delegate.managedObjectModel;
  NSError *error = nil;
  
  NSArray *pluginTypes = [delegate pluginTypes];
  
  for(NSString *pluginType in pluginTypes) {
    [self setValue:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%@s", pluginType]];
    
    NSMutableArray *plugins = [self valueForKey:[NSString stringWithFormat:@"%@s", pluginType]];
    
    NSArray *pluginIDs = [self valueForKey:[NSString stringWithFormat:@"%@IDs", pluginType]];
    
    NSString *pluginIDString = [NSString stringWithFormat:@"%@ID", pluginType];
    NSString *selectedPluginString = [NSString stringWithFormat:@"selected%@%@", 
                                      [[pluginType substringToIndex:1] capitalizedString], 
                                      [pluginType substringFromIndex:1]];
    
    NSString *selectedPluginIDString = [NSString stringWithFormat:@"selected%@%@ID", 
                                        [[pluginType substringToIndex:1] capitalizedString], 
                                        [pluginType substringFromIndex:1]];
    
    for(NSString *anID in pluginIDs)
      for(NSEntityDescription *anEntityDescription in mom.entities) {
        if([anEntityDescription.propertiesByName objectForKey:pluginIDString]) {
          NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
          NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"(%K LIKE %@)", pluginIDString, anID];
          
          [request setEntity:anEntityDescription];
          [request setPredicate:idPredicate];
          
          NSArray *pluginArray = [moc executeFetchRequest:request error:&error];
          
          for(id aPlugin in pluginArray) { // Should only be one
            [plugins addObject:aPlugin];
            
            if([[self valueForKey:selectedPluginIDString] isEqual:[aPlugin valueForKey:pluginIDString]])
              [self setValue:aPlugin forKey:selectedPluginString];
          }
        }
    }
  }
}

- (void) setSelectedDatasetVisualizer:(id <DivvyDatasetVisualizer>)aDatasetVisualizer {
  self.selectedDatasetVisualizerID = aDatasetVisualizer.datasetVisualizerID;
  selectedDatasetVisualizer = aDatasetVisualizer;
}

- (void) setSelectedPointVisualizer:(id <DivvyPointVisualizer>)aPointVisualizer {
  self.selectedPointVisualizerID = aPointVisualizer.pointVisualizerID;
  selectedPointVisualizer = aPointVisualizer;
}

- (void) setSelectedClusterer:(id <DivvyClusterer>)aClusterer {
  self.selectedClustererID = aClusterer.clustererID;
  selectedClusterer = aClusterer;
}

- (void) setSelectedReducer:(id <DivvyReducer>)aReducer {
  self.selectedReducerID = aReducer.reducerID;
  selectedReducer = aReducer;
}

- (void) setDataset:(DivvyDataset *)newDataset {
  [self willChangeValueForKey:@"dataset"];
  [self setPrimitiveDataset:newDataset];
  
  if ([newDataset isNotEqualTo:nil]) { // Core Data members are set to nil when deleted from the context
    DivvyAppDelegate *delegate = [NSApp delegate];
    NSArray *pluginTypes = [delegate pluginTypes];
    
    for(NSString *pluginType in pluginTypes) {
      NSArray *plugins = [self valueForKey:[NSString stringWithFormat:@"%@s", pluginType]];
      // Set dataset if the plugin responds to changeDataset.
      for (id aPlugin in plugins)
        if ([aPlugin respondsToSelector:@selector(changeDataset:)])
          [aPlugin changeDataset:newDataset];
    }
  }
  
  [self didChangeValueForKey:@"dataset"];
}

@end