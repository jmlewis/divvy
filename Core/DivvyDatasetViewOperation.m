//
//  DivvyPluginOperation.m
//  Divvy
//
//  Created by Joshua Lewis on 11/7/11.
//  Copyright (c) 2011 UCSD. All rights reserved.
//

#import "DivvyDatasetViewOperation.h"

#import "DivvyDatasetView.h"
#import "DivvyAppDelegate.h"

@implementation DivvyDatasetViewOperation

@synthesize datasetViewID;

-(id) initWithObjectID:(NSManagedObjectID *)objectID {
  if(self = [super init])  
    self.datasetViewID = objectID;
  
  return self;
}

-(void) dealloc {
  [datasetViewID release];
  
  [super dealloc];
}

-(void) main {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
  [moc setUndoManager:nil];
  [moc setPersistentStoreCoordinator: delegate.persistentStoreCoordinator];
  [moc setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
  
  NSError *error = nil;
  DivvyDatasetView *datasetView = (DivvyDatasetView *)[moc existingObjectWithID:datasetViewID error:&error];
  if(error) {
    NSString *message = [NSString stringWithFormat:@"%@ [%@]",
                         [error description], ([error userInfo] ? [[error userInfo] description] : @"no user info")];
    NSLog(@"Failure message: %@", message);        
  }
  
  [datasetView checkForNullPluginResults];
  
  [moc save:&error];
  if(error) {
    NSString *message = [NSString stringWithFormat:@"%@ [%@]",
                         [error description], ([error userInfo] ? [[error userInfo] description] : @"no user info")];
    NSLog(@"ABC Failure message: %@", message);        
  }

  [moc release];
  [pool release];
}

@end
