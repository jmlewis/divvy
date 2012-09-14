//
//  DivvyNilClusterer.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyNilClusterer.h"
#import "DivvyDataset.h"

@implementation DivvyNilClusterer

@dynamic clustererID;
@dynamic name;

@dynamic labels;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.clustererID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) clusterDataset:(DivvyDataset *)dataset
             assignment:(NSData *)assignment {
  if(self.labels == NULL) {
    int length = [dataset.n intValue] * sizeof(int);
    int *newLabels = malloc(length);
    self.labels = [NSData dataWithBytesNoCopy:newLabels length:length freeWhenDone:TRUE];
    for(int i = 0; i < [dataset.n intValue]; i++)
      ((int *)self.labels.bytes)[i] = 0;
  }
  for(int i = 0; i < [dataset.n intValue]; i++)
    ((int *)assignment.bytes)[i] = ((int *)self.labels.bytes)[i];
}

@end
