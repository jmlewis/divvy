//
//  DivvyNilPointVisualizer.m
//  Divvy
//
//  Created by Joshua Lewis on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyNilPointVisualizer.h"


@implementation DivvyNilPointVisualizer

@dynamic pointVisualizerID;
@dynamic name;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.pointVisualizerID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) drawImage:(NSImage *) image 
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset {
  // Just leave the image alone
}

@end
