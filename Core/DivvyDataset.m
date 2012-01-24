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
  
  bool nanInf = false;
  
  // Look for NaNs & Infs
  for (int i = 0; i < n * d; i++)
    if (isnan(self.floatData[i]) || isinf(self.floatData[i])) {
      self.floatData[i] = 0.f;
      nanInf = true;
    }
  
  if (nanInf) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"This dataset contains the values NaN or Inf."];
    [alert setInformativeText:@"Divvy has relpaced the values with 0.0."];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
    [alert release];
  }
}

- (float *) floatData {
  return (float *)(self.data.bytes + 8); // Offset by 8 bytes to avoid header info
}

@end
