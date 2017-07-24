//
//  JACellModel.h
//  Summary
//
//  Created by Jason on 03/05/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,JATargetType) {
    JATargetTypePush,     // Push
    JATargetTypePresent,  // Present
    JATargetTypeURL,      // 跳转到指定的URL
    JATargetTypeURLInner, // 跳转到指定的URL(内部)
};

@interface JATarget : JAModel

/// 跳转类型
@property (nonatomic,assign) JATargetType type;

/// 跳转目标
@property (nonatomic,copy) NSString *go;

@end

@interface JACellModel : JAModel

/// 标题
@property (nonatomic,copy) NSString *cTitle;

/// 详情
@property (nonatomic,copy) NSString *detail;

/// 图片
@property (nonatomic,copy) NSString *img;


- (NSString *)viewControllerTitle;

@end

NS_ASSUME_NONNULL_END
