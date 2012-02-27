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

@implementation DivvyImage

@dynamic pointVisualizerID;
@dynamic name;

@dynamic rotation;

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
  [self addObserver:self forKeyPath:@"rotation" options:0 context:nil];
}

- (void) willTurnIntoFault {
  [self removeObserver:self forKeyPath:@"rotation"];
  
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  [delegate.selectedDatasetView  pointVisualizerChanged];
  [delegate reloadDatasetView:delegate.selectedDatasetView];
}

- (void) drawImage:(NSImage *) image 
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset {

  float *embedding = (float *)[reducedData bytes];
  float *data = dataset.floatData;
  float *imageData;
  unsigned int n = dataset.n.unsignedIntValue;
  
  NSRect bounds = image.alignmentRect;
  NSRect rect;
  float x, y, rectSize, maxValue;
  int imageWidth, imageHeight;
  rectSize = 80.0f;
  maxValue = FLT_MIN;
  imageWidth = 32;
  imageHeight = 32;
  
  rect.size.width = rectSize;
  rect.size.height = rectSize;

  [image lockFocus];

  int index;
  for(int i = 0; i < 30; i++) {
    index = rand() % n;
    imageData = &data[index * dataset.d.unsignedIntValue];
    
    // Find the white point
    for(int j = 0; j < imageWidth * imageHeight; j++)
      if(imageData[j] > maxValue)
        maxValue = imageData[j];
    
    // Normalize and rotate
    float *normalizedImageData = (float *)malloc(imageWidth * imageHeight * sizeof(float));
    for(int j = 0; j < imageHeight; j++)
      for(int k = 0; k < imageWidth; k++) {
        switch (self.rotation.intValue) {
          case DivvyRotationNone:
            normalizedImageData[k * imageHeight + j] = imageData[k * imageHeight + j] / maxValue;
            break;
          case DivvyRotation90:
            normalizedImageData[j * imageWidth + k] = imageData[k * imageHeight + j] / maxValue;
            break;
          case DivvyRotation180:
            normalizedImageData[k * imageHeight + (imageWidth - j - 1)] = imageData[k * imageHeight + j] / maxValue;
            break;
          case DivvyRotation270:
            normalizedImageData[(imageHeight - j - 1) * imageWidth + k] = imageData[k * imageHeight + j] / maxValue;
            break;
        }
      }

    
    x = embedding[index * 2];
    y = embedding[index * 2 + 1];
    rect.origin.x = bounds.size.width * x - rectSize / 2;
    rect.origin.y = bounds.size.height * y - rectSize / 2;
    
    NSBitmapImageRep *rep = [NSBitmapImageRep alloc];
    [rep initWithBitmapDataPlanes:(unsigned char **)&normalizedImageData
                       pixelsWide:32 
                       pixelsHigh:32
                    bitsPerSample:8 * sizeof(float)
                  samplesPerPixel:1
                         hasAlpha:NO
                         isPlanar:NO
                   colorSpaceName:NSCalibratedWhiteColorSpace
                     bitmapFormat:NSFloatingPointSamplesBitmapFormat
                      bytesPerRow:0
                     bitsPerPixel:0];
    [rep autorelease];
    
    // I think this is needed for scaling to fit rect, but it seems heavy
    NSImage *sample = [[[NSImage alloc] initWithCGImage:[rep CGImage] size:NSZeroSize] autorelease];
    [sample drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    free(normalizedImageData);
  }
  
  [image unlockFocus];
}

@end
