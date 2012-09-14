//
//  DivvyNilClustererController.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyNilClustererController.h"

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"
#import "DivvyDatasetView.h"
#import "DivvyNilClusterer.h"

@implementation DivvyNilClustererController

- (IBAction)addLabeling:(id)sender {
  DivvyAppDelegate *delegate = [NSApp delegate];
  //NSButton *button = (NSButton *)sender;

  NSArray *fileTypes = [NSArray arrayWithObjects:@"csv", nil];
  NSOpenPanel *oPanel = [NSOpenPanel openPanel];
  
  [oPanel setAllowsMultipleSelection:NO];
  [oPanel setAllowedFileTypes:fileTypes];
  
  int result = [oPanel runModal];
  if (result == NSOKButton) {
    int length = [delegate.selectedDataset.n intValue] * sizeof(int);
    int *newLabels = malloc(length);
    NSData *labels = [NSData dataWithBytesNoCopy:newLabels length:length freeWhenDone:TRUE];

    [self parseCSV:[[oPanel URLs] objectAtIndex:0] labels:labels];

    ((DivvyNilClusterer *)delegate.selectedDatasetView.selectedClusterer).labels = labels;
    
    NSError *error = nil;
    [delegate.managedObjectContext save:&error];
    if(error) {
      NSString *message = [NSString stringWithFormat:@"%@ [%@]",
                           [error description], ([error userInfo] ? [[error userInfo] description] : @"no user info")];
      NSLog(@"MOC save failure message (delegate): %@", message);        
    }
    [delegate.selectedDatasetView clustererChanged];
    [delegate reloadDatasetView:delegate.selectedDatasetView];
  }
}

- (void)parseCSV:(NSURL *)url labels:(NSData *)labels {
 
  NSError *error;
  NSStringEncoding enc;
  NSString *csv = [NSString stringWithContentsOfFile:[url path] usedEncoding:&enc error:&error];
  NSArray *cols = [csv componentsSeparatedByString:@","];

  int i = 0;
  for (NSString *col in cols)
    ((int *)labels.bytes)[i++] = [col intValue];
}

@end
