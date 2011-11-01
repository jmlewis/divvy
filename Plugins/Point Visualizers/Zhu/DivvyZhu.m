//
//  DivvyZhu.m
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyZhu.h"
#import "DivvyDataset.h"

@implementation DivvyZhu

@dynamic pointVisualizerID;
@dynamic name;

@dynamic lineWidth;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.name = @"Zhu";
  self.pointVisualizerID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) drawImage:(NSImage *) image 
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset {
  
  float *data = (float *)[reducedData bytes];
  unsigned int n = [[dataset n] unsignedIntValue];
  
  [image lockFocus];
  
  NSColor* black = [NSColor blackColor];
  NSColor* white = [NSColor whiteColor];
  
  NSRect bounds = image.alignmentRect;
  
  NSRect rect, zhuVertical, zhuHorizontal;
  //NSBezierPath *path = [NSBezierPath bezierPath];
  
  float x, y, rectSize, frameSize;
  rectSize = 50.0f;
  frameSize = 10.0f;
  
  [white set];
  rect.size.width = rectSize;
  rect.size.height = rectSize;
  
  zhuVertical.size.width = [self.lineWidth intValue];
  zhuVertical.size.height = rectSize - frameSize;
  zhuHorizontal.size.width = rectSize - frameSize;
  zhuHorizontal.size.height = [self.lineWidth intValue];
  
  int index;
  for(int i = 0; i < 30; i++) {
    index = rand() % n;
    
    x = data[index * 2];
    y = data[index * 2 + 1];
    
    rect.origin.x = bounds.size.width * x - rectSize / 2;
    rect.origin.y = bounds.size.height * y - rectSize / 2;
    
    [white set];
    NSRectFill(rect);
    [black set];
    NSFrameRect(rect);
    
    
    zhuVertical.origin.x = rect.origin.x + frameSize / 2 + x * (rectSize - frameSize);
    zhuVertical.origin.y = rect.origin.y + frameSize / 2;
    NSRectFill(zhuVertical);
    zhuHorizontal.origin.x = rect.origin.x + frameSize / 2;
    zhuHorizontal.origin.y = rect.origin.y + frameSize / 2 + y * (rectSize - frameSize);
    NSRectFill(zhuHorizontal);
  }
  
  [image unlockFocus];
}

@end
