//
//  JABottomMenuView.h
//  MStarReader
//
//  Created by Jason on 27/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JABottomMenuView,JABrightnessView,JAFontView;

@protocol JAButtomMenuViewDelegate <NSObject>

@optional

/// 目录
- (void)menuViewInvokeCatalog:(JABottomMenuView *)bottomMenu;

/// 跳转到指定章节
- (void)menuViewJumpProgress:(CGFloat)progress;
- (void)menuViewChapterToastWithProgress:(CGFloat)progress;

/// 改变字体大小
- (void)menuViewFontSize:(JABottomMenuView *)bottomMenu;

/// 评论页面
- (void)menuViewComment:(JABottomMenuView *)bottomMenu;

@end

@interface JABottomMenuView : UIView

@property (nonatomic,weak) id<JAButtomMenuViewDelegate> delegate;
@property (nonatomic,strong) UISlider *slider;

@property (nonatomic,weak) JABrightnessView *brightnessView;
@property (nonatomic,weak) JAFontView *fontView;

@end

@interface JAReadProgressView : UIView

/// 章节标题
@property (nonatomic,strong) UILabel *chapterLabel;

- (void)title:(NSString *)title progress:(NSString *)progress;

@end
