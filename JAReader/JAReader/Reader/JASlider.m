//
//  JASlider.m
//  MStarReader
//
//  Created by Jason on 03/08/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JASlider.h"
#import "JACategory.h"

@implementation JASlider

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    CGPoint point = [touch locationInView:view];
    if (point.x > self.w) { point.x = self.w; }
    
    float progressValue = point.x / self.w;
    [self setValue:progressValue animated:true];
    if (self.moveBlock) {
        self.moveBlock(progressValue);
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self commonWithTouches:touches event:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self commonWithTouches:touches event:event];
}

- (void)commonWithTouches:(NSSet<UITouch *> *)touches event:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    CGPoint point = [touch locationInView:view];
    if (point.x > self.w) { point.x = self.w; }
    
    float progressValue = point.x / self.w;
    [self setValue:progressValue animated:true];
    if (self.refreshBlock) {
        self.refreshBlock(progressValue);
    }
}

@end
