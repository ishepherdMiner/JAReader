//
//  JAReaderConfig.h
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,JAReaderThemeType){
    JAReaderThemeTypeNormal,
    JAReaderThemeTypeNight,
    JAReaderThemeTypeCustom,
};

/// 阅读器配置
@interface JAReaderConfig : NSObject

@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat lineSpace;
@property (nonatomic,strong) UIColor *fontColor;
@property (nonatomic,strong) UIColor *themeColor;

/// 主题
@property (nonatomic,assign) JAReaderThemeType theme;


+ (instancetype)sharedReaderConfig;

@end

NS_ASSUME_NONNULL_END
