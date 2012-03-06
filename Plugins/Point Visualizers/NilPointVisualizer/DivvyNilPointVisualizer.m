//
//  DivvyNilPointVisualizer.m
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyNilPointVisualizer.h"

@implementation DivvyNilPointVisualizer

@dynamic pointVisualizerID;
@dynamic name;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.pointVisualizerID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) drawImage:(NSImage *) image 
    pointLocations:(NSData *)pointLocations
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset
        assignment:(NSData *)assignment {
  // Just leave the image alone
}

@end
