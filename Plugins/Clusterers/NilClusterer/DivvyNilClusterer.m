//
//  DivvyNilClusterer.m
//  Divvy
//
//  Created by Joshua Lewis on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
