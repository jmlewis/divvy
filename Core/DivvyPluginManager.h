//
//  DivvyPluginManager.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu
//
//  This class uses code based on the CDPlugin project on the Cocoa is my girlfriend 
//  blog

@interface DivvyPluginManager : NSObject

@property (nonatomic, retain) NSArray *pluginClasses;
@property (nonatomic, retain) NSArray *pluginModels;
@property (nonatomic, retain) NSArray *pluginModelsWithExistingStore;

+ (id)shared;

- (NSString*)applicationSupportDirectory;
- (void) initModels;

@end
