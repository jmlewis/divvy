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
  
  if ([[path pathExtension] isEqualToString:@"csv"]) {
    self.data = [self parseCSV:url];
  } else {
    self.data = [NSData dataWithContentsOfFile:path];
  }
  
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

// The following code uses a fragment from the Cocoa for Scientists article "Parsing CSV Data"
// http://www.macresearch.org/cocoa-scientists-part-xxvi-parsing-csv-data
- (NSData *) parseCSV:(NSURL *)url {
  NSError *error;
  NSStringEncoding enc;
  NSString *csv = [NSString stringWithContentsOfFile:[url path] usedEncoding:&enc error:&error];
  
  unsigned int n;
  unsigned int d;
  
  // Get newline character set
  NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
  [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];

  NSArray *rows = [csv componentsSeparatedByCharactersInSet:newlineCharacterSet];
  n = [rows count];
  if ([[rows lastObject] isEqualToString:@""]) // Trailing newline
    n--;
  
  NSArray *cols = [[rows objectAtIndex:0] componentsSeparatedByString:@","];
  d = [cols count];
  
  // The following might not be that portable...
  NSMutableData *data = [NSMutableData dataWithCapacity:2 * sizeof(int) + n * d * sizeof(float)];
  [data appendBytes:&n length:sizeof(int)];
  [data appendBytes:&d length:sizeof(int)];
  
  float val;
  for (NSString *row in rows) {
    if (![row isEqualToString:@""]) {
      cols = [row componentsSeparatedByString:@","];
      for (NSString *col in cols) {
        val = [col floatValue];
        [data appendBytes:&val length:sizeof(float)];
      }
    }
  }
  
  return data;
}

@end
