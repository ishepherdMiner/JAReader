//
//  NSBundle+JACoder.h
//  Summary
//
//  Created by Jason on 21/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (JACoder)

+ (instancetype)frameworkBundle;
- (UIImage *)ja_imageWithName:(NSString *)imageName;

@end
