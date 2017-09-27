//
//  JAFontView.h
//  MStarReader
//
//  Created by Jason on 27/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JABottomMenuView.h"

@interface JAFontView : UIView

@property (nonatomic,strong) UIButton *plusBtn;
@property (nonatomic,strong) UIButton *minusBtn;
@property (nonatomic,strong) UIImageView *backImgView;

/// back按钮返回用
@property (nonatomic,weak) JABottomMenuView *bottomView;

@end
