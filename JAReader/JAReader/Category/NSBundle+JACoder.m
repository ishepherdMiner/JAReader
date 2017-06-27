//
//  NSBundle+JACoder.m
//  Summary
//
//  Created by Jason on 21/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "NSBundle+JACoder.h"

@implementation NSBundle (JACoder)

+ (instancetype)frameworkBundle {
    
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"JAFramework" ofType:@"bundle"]];
    });
    
    return instance;
}

- (UIImage *)ja_imageWithName:(NSString *)imageName {
    
    NSString *imageNameWithSuffix = nil;
    
    if ([UIScreen mainScreen].scale <= 2.0) {
        imageNameWithSuffix = [NSString stringWithFormat:@"%@@2x",imageName];
    }else {
        imageNameWithSuffix = [NSString stringWithFormat:@"%@@3x",imageName];
    }
    
    return [UIImage imageWithContentsOfFile:[[NSBundle frameworkBundle] pathForResource:imageNameWithSuffix ofType:@"png"]];
}

@end
