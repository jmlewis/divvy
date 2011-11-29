//
//  DivvyPluginManager.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu
//
//  This class uses code based on the CDPlugin project on the Cocoa is my girlfriend 
//  blog

#import "DivvyPluginManager.h"

#import "DivvyPlugin.h"
#import "DivvyClusterer.h"
#import "DivvyReducer.h"
#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"

@implementation DivvyPluginManager

@synthesize pluginClasses;
@synthesize pluginModels;
@synthesize pluginModelsWithExistingStore;

+ (id)shared;
{
  static DivvyPluginManager *sharedInstance;
  if (!sharedInstance) {
    sharedInstance = [[DivvyPluginManager alloc] init]; // I think it's OK to just let this get destroyed at application termination--no need to balance with a release
  }
  return sharedInstance;
}

- (id)init
{
  if (!(self = [super init])) return nil;
  
  //Find the plugins
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *bundleFolder = [[NSBundle mainBundle] bundlePath];
  bundleFolder = [bundleFolder stringByAppendingString:@"/Contents/Resources/"];
  NSArray *plugins = [fileManager contentsOfDirectoryAtPath:bundleFolder error:nil];
  
  //Load all of the plugins
  NSMutableArray *loadArray = [NSMutableArray array];
  for (NSString *pluginPath in plugins) {
    if (![pluginPath hasSuffix:@".plugin"]) continue;

    NSString *bundlePath = [bundleFolder stringByAppendingString:pluginPath];
    
    NSBundle *pluginBundle = [NSBundle bundleWithPath:bundlePath];
    Class principalClass = [pluginBundle principalClass];
    
    if (![principalClass conformsToProtocol:@protocol(DivvyClusterer)] &&
        ![principalClass conformsToProtocol:@protocol(DivvyReducer)] &&
        ![principalClass conformsToProtocol:@protocol(DivvyDatasetVisualizer)] &&
        ![principalClass conformsToProtocol:@protocol(DivvyPointVisualizer)]) {
      NSLog(@"Plugin %@ does not conform to protocol.", pluginPath);
      continue;
    }

    [loadArray addObject:principalClass];
  }
  
  self.pluginClasses = loadArray;
  
  return self;
}

- (void) dealloc {
  [pluginClasses release];
  [pluginModels release];
  [pluginModelsWithExistingStore release];
  
  [super dealloc];
}

- (NSArray*)pluginModels;
{
  if (pluginModels) return pluginModels;
  
  [self initModels];
  
  return self.pluginModels;
}

- (NSArray*)pluginModelsWithExistingStore;
{
  if (pluginModelsWithExistingStore) return pluginModelsWithExistingStore;
  
  [self initModels];
  
  return self.pluginModelsWithExistingStore;
}

- (void) initModels {
  // FileManager for checking whether a store already exists
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSMutableArray *models = [NSMutableArray array];
  NSMutableArray *modelsWithExistingStore = [NSMutableArray array];
  
  for (Class aClass in [self pluginClasses]) {
    NSBundle *myBundle = [NSBundle bundleForClass:aClass];
    NSArray *bundles = [NSArray arrayWithObject:myBundle];
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:bundles] retain];
    [models addObject:managedObjectModel];
    
    NSString *path = [[self applicationSupportDirectory] stringByAppendingFormat:@"/%@.storedata", NSStringFromClass(aClass)];
    if ([fileManager fileExistsAtPath:path])
      [modelsWithExistingStore addObject:managedObjectModel];
    
    [managedObjectModel release];
  }
  
  self.pluginModels = models;
  self.pluginModelsWithExistingStore = modelsWithExistingStore;
  
}

- (NSString*)applicationSupportDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
  return [basePath stringByAppendingPathComponent:@"Divvy"];
}

@end
