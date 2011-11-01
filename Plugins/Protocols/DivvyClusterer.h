//
//  DivvyClusterer.h
//  Divvy
//
//  Created by Joshua Lewis on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyPlugin.h"

@class DivvyDataset;

@protocol DivvyClusterer <NSObject, DivvyPlugin>

- (NSString *) clustererID;

- (void) clusterDataset:(DivvyDataset *)dataset
             assignment:(NSData *)assignment;

@end
