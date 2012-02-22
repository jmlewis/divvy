//
//  DivvyImage.m
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyImage.h"
#import "DivvyDataset.h"

@implementation DivvyImage

@dynamic pointVisualizerID;
@dynamic name;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.name = @"Image";
  self.pointVisualizerID = [[NSProcessInfo processInfo] globallyUniqueString];
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

  //double rotateDeg = 0;
  [image lockFocus];
  //NSAffineTransform *rotate = [[NSAffineTransform alloc] init];
  //NSGraphicsContext *context = [NSGraphicsContext currentContext];
  
  //[context saveGraphicsState];
  //[rotate rotateByDegrees:rotateDeg];
  //[rotate concat];
    
  int index;
  for(int i = 0; i < 30; i++) {
    index = rand() % n;
    imageData = &data[index * dataset.d.unsignedIntValue];
    
    // Find the white point
    for(int j = 0; j < imageWidth * imageHeight; j++)
      if(imageData[j] > maxValue)
        maxValue = imageData[j];
    
    float *normalizedImageData = (float *)malloc(imageWidth * imageHeight * sizeof(float));
    for(int j = 0; j < imageWidth * imageHeight; j++)
      normalizedImageData[j] = imageData[j] / maxValue;
    
    
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
    
    free(normalizedImageData);
    
    // I think this is needed for scaling to fit rect, but it seems heavy
    NSImage *sample = [[[NSImage alloc] initWithCGImage:[rep CGImage] size:NSZeroSize] autorelease];
    
    [sample drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  }
  
  //[rotate release];
  //[context restoreGraphicsState];  
  [image unlockFocus];
  
}

@end
