//
//  DivvyLinkage.m
//  Divvy
//
//  Created by Joshua Lewis on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyLinkage.h"
#import "DivvyDataset.h"

#include "linkage.h"


@implementation DivvyLinkage

@dynamic clustererID;
@dynamic name;

@dynamic k;
@dynamic isComplete;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.clustererID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) clusterDataset:(DivvyDataset *)dataset
             assignment:(NSData *)assignment {
  
  linkage([dataset floatData], 
          [[dataset n] unsignedIntValue], 
          [[dataset d] unsignedIntValue], 
          [[self k] unsignedIntValue],
          [[self isComplete] unsignedIntValue],
          (int *)[assignment bytes]);
}

@end
