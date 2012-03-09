//
//  DivvyDatasetView.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


@class DivvyDataset;

@protocol DivvyDatasetVisualizer;
@protocol DivvyPointVisualizer;
@protocol DivvyClusterer;
@protocol DivvyReducer;

//  Represents a dataset via a set of four plugins: a clusterer, a reducer,
//  a point visualizer and a dataset visualizer. The dataset view uses these
//  plugins to draw a visual representation of the dataset.
@interface DivvyDatasetView : NSManagedObject

//  These are used by the image browser
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, readonly) NSImage *image;

//  The internal cached image for the image browser
@property (nonatomic, retain) NSImage *renderedImage;

//  The dataset represented by the dataset view
@property (nonatomic, retain) DivvyDataset *dataset;

//  IDs used to retrieve plugin objects from the managed object context when the
//  dataset view is fetched. We can't model this as a traditional Core Data 
//  relationship due to the plugin architecture and distinct persistent stores.
@property (nonatomic, retain) NSArray *datasetVisualizerIDs;
@property (nonatomic, retain) NSArray *pointVisualizerIDs;
@property (nonatomic, retain) NSArray *clustererIDs;
@property (nonatomic, retain) NSArray *reducerIDs;
@property (nonatomic, retain) NSString *selectedDatasetVisualizerID;
@property (nonatomic, retain) NSString *selectedPointVisualizerID;
@property (nonatomic, retain) NSString *selectedClustererID;
@property (nonatomic, retain) NSString *selectedReducerID;

//  Cache plugin results to avoid unnecessary recomputation
@property (nonatomic, retain) NSArray *datasetVisualizerResults;
@property (nonatomic, retain) NSArray *pointVisualizerResults;
@property (nonatomic, retain) NSArray *clustererResults;
@property (nonatomic, retain) NSArray *reducerResults;

//  Cache the current set of point locations for each dataset visualizer to
//  coordinate with the point visualizer.
@property (nonatomic, retain) NSArray *pointLocations;

//  Refernces to the actual plugin objects
@property (nonatomic, retain) NSMutableArray *datasetVisualizers;
@property (nonatomic, retain) NSMutableArray *pointVisualizers;
@property (nonatomic, retain) NSMutableArray *clusterers;
@property (nonatomic, retain) NSMutableArray *reducers;
@property (nonatomic, assign) id <DivvyDatasetVisualizer> selectedDatasetVisualizer;
@property (nonatomic, assign) id <DivvyPointVisualizer> selectedPointVisualizer;
@property (nonatomic, assign) id <DivvyClusterer> selectedClusterer;
@property (nonatomic, assign) id <DivvyReducer> selectedReducer;


//  Grab a UUID for the image browser uniqueID
- (void) generateUniqueID;

//  Update the rendered image during and after computation
- (void) setProcessingImage;
- (void) reloadImage;

//  Make sure that the list of plugins is current and that the plugin objects are
//  populated on awake from insert and fetch.
- (void) createPlugins;
- (void) updatePlugins;

//  Go through the selected plugins and update them if their results are null,
//  normally as a result of a changed method being called.
- (void) checkForNullPluginResults;

//  Null out the relevant plugin result so that it will be recomputed.
//  Typically called when an algorithm parameter changes.
- (void) datasetVisualizerChanged;
- (void) pointVisualizerChanged;
- (void) clustererChanged;
- (void) reducerChanged;

//  Perform the relevant plugin computation to get a new result
- (void) datasetVisualizerUpdate;
- (void) pointVisualizerUpdate;
- (void) clustererUpdate;
- (void) reducerUpdate;

@end