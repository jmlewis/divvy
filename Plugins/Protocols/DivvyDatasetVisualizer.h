//
//  DivvyDatasetVisualizer.h
//  Divvy
//
//  Created by Joshua Lewis on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyPlugin.h"

@class DivvyDataset;

@protocol DivvyDatasetVisualizer <NSObject, DivvyPlugin>

- (NSString *) datasetVisualizerID;

- (void) drawImage:(NSImage *) image
       reducedData:(NSData *)reducedData
          reducedD:(NSNumber *)d
           dataset:(DivvyDataset *)dataset
        assignment:(NSData *)assignment;

@end
