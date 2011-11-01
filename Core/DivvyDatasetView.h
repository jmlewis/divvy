//
//  DivvyDatasetView.h
//  Divvy
//
//  Created by Joshua Lewis on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class DivvyDataset;

@protocol DivvyDatasetVisualizer;
@protocol DivvyPointVisualizer;
@protocol DivvyClusterer;
@protocol DivvyReducer;

@interface DivvyDatasetView : NSManagedObject

@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSDate *dateCreated;

@property (nonatomic, retain) DivvyDataset *dataset;

@property (nonatomic, retain) NSMutableArray *datasetVisualizerIDs;
@property (nonatomic, retain) NSMutableArray *pointVisualizerIDs;
@property (nonatomic, retain) NSMutableArray *clustererIDs;
@property (nonatomic, retain) NSMutableArray *reducerIDs;

@property (nonatomic, retain) NSString *selectedDatasetVisualizerID;
@property (nonatomic, retain) NSString *selectedPointVisualizerID;
@property (nonatomic, retain) NSString *selectedClustererID;
@property (nonatomic, retain) NSString *selectedReducerID;

@property (nonatomic, retain) NSMutableArray *datasetVisualizerResults;
@property (nonatomic, retain) NSMutableArray *pointVisualizerResults;
@property (nonatomic, retain) NSMutableArray *clustererResults;
@property (nonatomic, retain) NSMutableArray *reducerResults;

@property (nonatomic, retain) NSMutableArray *datasetVisualizers;
@property (nonatomic, retain) NSMutableArray *pointVisualizers;
@property (nonatomic, retain) NSMutableArray *clusterers;
@property (nonatomic, retain) NSMutableArray *reducers;

@property (nonatomic, assign) id <DivvyDatasetVisualizer> selectedDatasetVisualizer;
@property (nonatomic, assign) id <DivvyPointVisualizer> selectedPointVisualizer;
@property (nonatomic, assign) id <DivvyClusterer> selectedClusterer;
@property (nonatomic, assign) id <DivvyReducer> selectedReducer;

@property (nonatomic, retain) NSOperationQueue *operationQueue;

@property (nonatomic, retain) NSImage *renderedImage;
@property (nonatomic, readonly) NSImage *image;

- (void) generateUniqueID;

- (void) setProcessingImage;
- (void) reloadImage;

- (void) createPlugins;
- (void) updatePlugins;

- (void) checkForNullPluginResults;

- (void) datasetVisualizerChanged;
- (void) pointVisualizerChanged;
- (void) clustererChanged;
- (void) reducerChanged;

- (void) datasetVisualizerUpdate;
- (void) pointVisualizerUpdate;
- (void) clustererUpdate;
- (void) reducerUpdate;

@end