//
//  DivvyDelegateSettings.m
//  Divvy
//
//  Created by Joshua Lewis on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDelegateSettings.h"


@implementation DivvyDelegateSettings

@dynamic selectedDatasets;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.selectedDatasets = nil;
}

@end
