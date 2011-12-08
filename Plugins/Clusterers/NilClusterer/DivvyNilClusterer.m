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

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.clustererID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) clusterDataset:(DivvyDataset *)dataset
             assignment:(NSData *)assignment {
  for(int i = 0; i < [dataset.n intValue]; i++)
    ((int *)assignment.bytes)[i] = 0;
}

@end
