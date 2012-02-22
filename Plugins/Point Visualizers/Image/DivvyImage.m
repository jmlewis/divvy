//
//  DivvyImage.m
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyImage.h"
#import "DivvyDataset.h"

@implementation DivvyImage

@dynamic pointVisualizerID;
@dynamic name;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.name = @"Image";
  self.pointVisualizerID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) drawImage:(NSImage *) image 
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset {
  
}

@end
