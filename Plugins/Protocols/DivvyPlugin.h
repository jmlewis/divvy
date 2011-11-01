//
//  DivvyPlugin.h
//  Divvy
//
//  Created by Joshua Lewis on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const kDivvyDatasetVisualizer;
extern NSString * const kDivvyPointVisualizer;
extern NSString * const kDivvyClusterer;
extern NSString * const kDivvyReducer;

extern NSString * const kDivvyDefaultDatasetVisualizer;
extern NSString * const kDivvyDefaultPointVisualizer;
extern NSString * const kDivvyDefaultClusterer;
extern NSString * const kDivvyDefaultReducer;

@protocol DivvyPlugin

- (NSString *) name;

@optional
- (NSString *) helpURL;

@end
