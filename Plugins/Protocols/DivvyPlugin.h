//
//  DivvyPlugin.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


//  Defined in DivvyAppDelegate.m
extern NSString * const kDivvyDatasetVisualizer;
extern NSString * const kDivvyPointVisualizer;
extern NSString * const kDivvyClusterer;
extern NSString * const kDivvyReducer;

extern NSString * const kDivvyDefaultDatasetVisualizer;
extern NSString * const kDivvyDefaultPointVisualizer;
extern NSString * const kDivvyDefaultClusterer;
extern NSString * const kDivvyDefaultReducer;

//  The base protocol for every plugin
@protocol DivvyPlugin

- (NSString *) name;

@optional
//  Define this if you want the little question mark bubble for your plugin to work.
- (NSString *) helpURL;

@end
