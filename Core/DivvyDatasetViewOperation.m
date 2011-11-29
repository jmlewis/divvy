//
//  DivvyDatasetViewOperation.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu

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
  // In case the user deletes the dataset or something in the mean time
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
