//
//  DivvyGMMController.m
//
//  Written in 2014 by Jeremy Karnowski at the UC San Diego Natural Computation Lab,
//  Based on code written in 2011 by Josh Lewis
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


#import "DivvyGMMController.h"

#import "DivvyGMM.h"
#import "DivvyAppDelegate.h"
#import "DivvyDatasetView.h"

@implementation DivvyGMMController

- (IBAction)recompute:(id)sender {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  [delegate.selectedDatasetView clustererChanged];
  [delegate reloadDatasetView:delegate.selectedDatasetView];
}

@end
