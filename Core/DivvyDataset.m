//
//  DivvyDataset.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu

#import "DivvyDataset.h"

@implementation DivvyDataset 

@dynamic d;
@dynamic data;
@dynamic n;
@dynamic title;
@dynamic zoomValue;

@dynamic datasetViews;
@dynamic selectedDatasetViews;

- (void) loadDataAtURL:(NSURL *)url {
  NSString *path = [url path];
  
  self.title = [[path lastPathComponent] stringByDeletingPathExtension];
  self.data = [NSData dataWithContentsOfFile:path];
  self.selectedDatasetViews = [NSIndexSet indexSet];
  
  unsigned int n;
  unsigned int d;
  
  [self.data getBytes:&n range:NSMakeRange(0, 4)];
  [self.data getBytes:&d range:NSMakeRange(4, 4)];
  
  self.n = [NSNumber numberWithUnsignedInt:n];
  self.d = [NSNumber numberWithUnsignedInt:d];
}

- (float *) floatData {
  return (float *)(self.data.bytes + 8); // Offset by 8 bytes to avoid header info
}

@end
