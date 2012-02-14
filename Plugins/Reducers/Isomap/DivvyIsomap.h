//
//  DivvyIsomap.h
//  Divvy
//
//  Created by Laurens van der Maaten on 9/20/11.
//  Copyright 2011 Delft University of Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyReducer.h"


@interface DivvyIsomap : NSManagedObject <DivvyReducer>

@property (nonatomic, retain) NSString *reducerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSString *helpURL;

@property (nonatomic, retain) NSNumber *d;
@property (nonatomic, retain) NSNumber *k;

@end
