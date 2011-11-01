//
//  DivvyTSNE.h
//  Divvy
//
//  Created by Laurens van der Maaten on 8/18/11.
//  Copyright 2011 Delft University of Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyReducer.h"


@interface DivvyTSNE : NSManagedObject <DivvyReducer>

@property (nonatomic, retain) NSString *reducerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *d;

@property (nonatomic, retain) NSNumber *perplexity;

@end
