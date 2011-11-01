//
//  DivvyDatasetPanel.h
//  Divvy
//
//  Created by Joshua Lewis on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DivvyDatasetsPanel : NSViewController <NSTableViewDelegate>

@property (retain) IBOutlet NSTableView *datasetsTable;
@property (retain) IBOutlet NSArrayController *datasetsArrayController;

-(IBAction)editDatasets:sender;

@end
