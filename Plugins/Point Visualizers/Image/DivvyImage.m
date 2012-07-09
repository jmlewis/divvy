//
//  DivvyImage.m
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyImage.h"

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

#import "dispatch/dispatch.h"

@implementation DivvyImage

@dynamic pointVisualizerID;
@dynamic name;

@dynamic n;
@dynamic numberOfSamples;
@dynamic indices;

@dynamic imageHeight;
@dynamic imageHeights;

@dynamic rotation;
@dynamic magnification;

@dynamic blackIsTransparent;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.name = @"Image";
  self.pointVisualizerID = [[NSProcessInfo processInfo] globallyUniqueString];

  [self addObservers];
}

- (void) awakeFromFetch {
  [super awakeFromFetch];
  
  [self addObservers];
}

- (void) addObservers {
  [self addObserver:self forKeyPath:@"numberOfSamples" options:0 context:nil];
  [self addObserver:self forKeyPath:@"imageHeight" options:0 context:nil];
  [self addObserver:self forKeyPath:@"rotation" options:0 context:nil];
  [self addObserver:self forKeyPath:@"magnification" options:0 context:nil];
  [self addObserver:self forKeyPath:@"blackIsTransparent" options:0 context:nil];
}

- (void) willTurnIntoFault {
  [self removeObserver:self forKeyPath:@"numberOfSamples"];
  [self removeObserver:self forKeyPath:@"imageHeight"];
  [self removeObserver:self forKeyPath:@"rotation"];
  [self removeObserver:self forKeyPath:@"magnification"];
  [self removeObserver:self forKeyPath:@"blackIsTransparent"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqual:@"numberOfSamples"])
    [self resample];
  DivvyAppDelegate *delegate = [NSApp delegate];
  [delegate.selectedDatasetView  pointVisualizerChanged];
  [delegate reloadDatasetView:delegate.selectedDatasetView];
}

- (void) changeDataset:(DivvyDataset *)newDataset {
  self.n = [NSNumber numberWithInt:newDataset.n.intValue];
  
  NSMutableArray *heights = [NSMutableArray array];
  
  for (int i = floor(sqrt(newDataset.d.doubleValue)); i > 0; i--) {
    int test = newDataset.d.intValue % i;
    if (test == 0)
      [heights addObject:[NSNumber numberWithInt:i]];
  }
  
  self.imageHeights = heights;
  
  [self removeObserver:self forKeyPath:@"imageHeight"]; // Don't trigger a redraw here
  self.imageHeight = [heights objectAtIndex:0]; // Largest height
  [self addObserver:self forKeyPath:@"imageHeight" options:0 context:nil];  
  
  [self resample];
}

- (void) resample {
  int numSamples = self.numberOfSamples.intValue;
  int *newIndices = malloc(numSamples * sizeof(int));
  
  for (int i = 0; i < self.numberOfSamples.intValue; i++)
    newIndices[i] = rand() % self.n.intValue;
  
  self.indices = [NSData dataWithBytesNoCopy:newIndices length:numSamples * sizeof(int) freeWhenDone:YES];
}

- (void) drawImage:(NSImage *) image 
    pointLocations:(NSData *)pointLocations
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset
        assignment:(NSData *)assignment {

  float *locations = (float *)[pointLocations bytes];
  float *data = dataset.floatData;
  unsigned int d = dataset.d.unsignedIntValue;
  
  float *normalizedImageData;
  int *indices = (int *)self.indices.bytes;
  
  NSRect rect;
  int width, height;
  height = self.imageHeight.intValue;
  width = d / height;
  
  int planes = 2; // Brightness and alpha
  int numSamples = self.numberOfSamples.intValue;
  
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
  
  int numBytes = numSamples * d * planes * sizeof(float);
  normalizedImageData = (float *)malloc(numBytes);
  
  dispatch_apply(numSamples, queue, ^(size_t i) {
    float maxValue = FLT_MIN;
    float *imageData = &data[indices[i] * d];
    int offset = i * d * planes;
    
    // Find the white point
    for(int j = 0; j < width * height; j++)
      if(imageData[j] > maxValue)
        maxValue = imageData[j];
    
    int index;
    
    // Normalize and rotate (NSBitmapImageRep wants images in row major format)
    for(int j = 0; j < height; j++)
      for(int k = 0; k < width; k++) {
        switch (self.rotation.intValue) {
          case DivvyRotationNone:
            index = k * planes + j * width * planes + offset;
            break;
          case DivvyRotation90:
            index = k * height * planes + (height - j - 1) * planes + offset;
            break;
          case DivvyRotation180:
            index = (width - k - 1) * planes + (height - j - 1) * width * planes + offset;
            break;
          case DivvyRotation270:
            index = (width - k - 1) * height * planes + j * planes + offset;
            break;
        }
        normalizedImageData[index] = imageData[k * height + j] / maxValue;
        if(self.blackIsTransparent.boolValue && normalizedImageData[index] < 0.05f)
          normalizedImageData[index + 1] = 0.0f;
        else
          normalizedImageData[index + 1] = 1.0f;
      }
  });
  
  
  int temp;
  switch (self.rotation.intValue) {
    case DivvyRotation90:
    case DivvyRotation270:
      temp = height;
      height = width;
      width = temp;
      break;
    case DivvyRotationNone:
    case DivvyRotation180:
      break;
  }
  
  rect.size.width = width * self.magnification.intValue;
  rect.size.height = height * self.magnification.intValue;
  
  [image lockFocus];
  
  for (int i = 0; i < numSamples; i++) {
    // Center images on their coordinates in the dataset visualization
    rect.origin.x = locations[2 * indices[i]] - rect.size.width / 2;
    rect.origin.y = locations[2 * indices[i] + 1] - rect.size.height / 2;
    
    unsigned char *sampleData = (unsigned char *)&normalizedImageData[i * d * planes];

    NSBitmapImageRep *rep = [NSBitmapImageRep alloc];
    [rep initWithBitmapDataPlanes:&sampleData
                       pixelsWide:width 
                       pixelsHigh:height
                    bitsPerSample:8 * sizeof(float)
                  samplesPerPixel:planes
                         hasAlpha:YES
                         isPlanar:NO
                   colorSpaceName:NSCalibratedWhiteColorSpace
                     bitmapFormat:NSFloatingPointSamplesBitmapFormat
                      bytesPerRow:0
                     bitsPerPixel:0];
    [rep autorelease];
    
    // I think this is needed for scaling to fit rect, but it seems heavy
    NSImage *sample = [[[NSImage alloc] initWithCGImage:[rep CGImage] size:NSZeroSize] autorelease];
    [sample drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  }

  [image unlockFocus];
}

- (void) drawPoint:(NSImage *) image
             index:(NSInteger) index
           dataset:(DivvyDataset *)dataset {
  float *data = dataset.floatData;
  unsigned int d = dataset.d.unsignedIntValue;
  
  float *normalizedImageData;
  
  NSRect rect;
  int width, height;
  height = self.imageHeight.intValue;
  width = d / height;
  
  int planes = 2; // Brightness and alpha
  
  int numBytes = d * planes * sizeof(float);
  normalizedImageData = (float *)malloc(numBytes);
  
  float maxValue = FLT_MIN;
  float *imageData = &data[index * d];
  
  // Find the white point
  for(int j = 0; j < width * height; j++)
    if(imageData[j] > maxValue)
      maxValue = imageData[j];
  
  int normIndex;
  
  // Normalize and rotate (NSBitmapImageRep wants images in row major format)
  for(int j = 0; j < height; j++)
    for(int k = 0; k < width; k++) {
      switch (self.rotation.intValue) {
        case DivvyRotationNone:
          normIndex = k * planes + j * width * planes;
          break;
        case DivvyRotation90:
          normIndex = k * height * planes + (height - j - 1) * planes;
          break;
        case DivvyRotation180:
          normIndex = (width - k - 1) * planes + (height - j - 1) * width * planes;
          break;
        case DivvyRotation270:
          normIndex = (width - k - 1) * height * planes + j * planes;
          break;
      }
      normalizedImageData[normIndex] = imageData[k * height + j] / maxValue;
      if(self.blackIsTransparent.boolValue && normalizedImageData[normIndex] < 0.05f)
        normalizedImageData[normIndex + 1] = 0.0f;
      else
        normalizedImageData[normIndex + 1] = 1.0f;
    }
  
  
  int temp;
  switch (self.rotation.intValue) {
    case DivvyRotation90:
    case DivvyRotation270:
      temp = height;
      height = width;
      width = temp;
      break;
    case DivvyRotationNone:
    case DivvyRotation180:
      break;
  }
  
  rect.size.width = image.size.width;
  rect.size.height = image.size.height;
  
  [image lockFocus];

  unsigned char *sampleData = (unsigned char *)normalizedImageData;
  
  NSBitmapImageRep *rep = [NSBitmapImageRep alloc];
  [rep initWithBitmapDataPlanes:&sampleData
                     pixelsWide:width 
                     pixelsHigh:height
                  bitsPerSample:8 * sizeof(float)
                samplesPerPixel:planes
                       hasAlpha:YES
                       isPlanar:NO
                 colorSpaceName:NSCalibratedWhiteColorSpace
                   bitmapFormat:NSFloatingPointSamplesBitmapFormat
                    bytesPerRow:0
                   bitsPerPixel:0];
  [rep autorelease];
  
  // I think this is needed for scaling to fit rect, but it seems heavy
  NSImage *sample = [[[NSImage alloc] initWithCGImage:[rep CGImage] size:NSZeroSize] autorelease];
  [sample drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  
  [image unlockFocus];
}

@end
