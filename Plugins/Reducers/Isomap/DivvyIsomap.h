//
//  DivvyIsomap.h
//  Divvy
//
//  Created by Laurens van der Maaten on 9/20/11.
//  Copyright 2011 Delft University of Technology. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "DivvyReducer.h"

@interface DivvyIsomap : NSManagedObject

@property (nonatomic, retain) NSString *reducerID;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSNumber *k;


@end
