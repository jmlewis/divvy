//
//  DivvyKMeansController.h
//
//  Written in 2011 by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award SES #0963071.
//  Copyright 2011, UC San Diego Natural Computation Lab. All rights reserved.
//  Licensed under the MIT License. http://www.opensource.org/licenses/mit-license.php
//
//  Find the Divvy project on the web at http://divvy.ucsd.edu


//  Custom controller for k-means. Divvy requires a custom controller for each
//  plugin, but by default the controller doesn't have to do anything. The controller
//  is useful for handling UI events that don't change parameters (like the recompute 
//  here) and updating the plugin UI based on events in other plugins, e.g. the scatter 
//  plot controller updates its dimensionality sliders based on the selected reducer's 
//  d property. UI events that do change parameters are better handles by setting
//  observers in the wrapper class (in this case DivvyKMeans).
@interface DivvyKMeansController : NSViewController

- (IBAction)recompute:(id)sender;

@end
