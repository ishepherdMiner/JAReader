//
//  JABrightnessView.h
//  MStarReader
//
//  Created by Jason on 27/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JABottomMenuView.h"

@interface JABrightnessView : UIView

@property (strong, nonatomic) UISlider *brightSlider;
@property (strong, nonatomic) UIImageView *lowImgView;
@property (strong, nonatomic) UIImageView *highImgView;
@property (strong, nonatomic) UIImageView *backImgView;

/// back按钮返回用
@property (nonatomic,weak) JABottomMenuView *bottomView;

@end
