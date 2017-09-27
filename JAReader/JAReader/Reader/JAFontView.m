//
//  JAFontView.m
//  MStarReader
//
//  Created by Jason on 27/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAFontView.h"
#import "JACategory.h"
#import "JAConfigure.h"
#import "JAReaderConfig.h"
#import "JAReaderPageViewController.h"

@interface JAFontView ()
@property (nonatomic,strong) UILabel *fontLabel;
@end

@implementation JAFontView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.backImgView];
        [self addSubview:self.minusBtn];
        [self addSubview:self.plusBtn];
        [self addSubview:self.fontLabel];
        
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            self.backgroundColor = HexRGB(0xffffff);
            self.layer.shadowColor = [UIColor grayColor].CGColor;
            self.layer.shadowOffset = CGSizeMake(1, -0.5);
            self.layer.shadowOpacity = 1.0;
            self.clipsToBounds = false;
        }else {
            self.backgroundColor = HexRGB(0x1a1a1a);
            // self.layer.shadowColor = HexRGB(0x333232).CGColor;
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(changeThemeAction:)
                                                    name:MSReaderChangeThemeNotification
                                                  object:nil];
    }
    return self;
}

- (void)changeThemeAction:(NSNotification *)noti {
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        self.backgroundColor = HexRGB(0xffffff);
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, -0.5);
        self.layer.shadowOpacity = 1.0;
        self.clipsToBounds = false;
        _minusBtn.backgroundColor = [UIColor whiteColor];
        [_minusBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _plusBtn.backgroundColor = [UIColor whiteColor];
        [_plusBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else {
        self.backgroundColor = HexRGB(0x1a1a1a);
        self.clipsToBounds = true;
        _minusBtn.backgroundColor = HexRGB(0x1a1a1a);
        [_minusBtn setTitleColor:HexRGB(0x657076) forState:UIControlStateNormal];
        _plusBtn.backgroundColor = HexRGB(0x1a1a1a);
        [_plusBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (UIButton *)minusBtn {
    if (!_minusBtn) {
        _minusBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, (self.h - 30) * 0.5, UIScreen.w * 0.3,30)];
        [_minusBtn setTitleColor:[JAConfigure sharedCf].titleFontColor forState:UIControlStateNormal];
        _minusBtn.layer.borderColor = [JAConfigure sharedCf].strongFontColor.CGColor;
        _minusBtn.layer.borderWidth = 1;
        [_minusBtn setTitle:@"A-" forState:UIControlStateNormal];
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _minusBtn.backgroundColor = [UIColor whiteColor];
            [_minusBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }else{
            _minusBtn.backgroundColor = HexRGB(0x1a1a1a);
            [_minusBtn setTitleColor:HexRGB(0x657076) forState:UIControlStateNormal];
        }
        [_minusBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _minusBtn;
}

- (UIButton *)plusBtn {
    if (!_plusBtn) {
        _plusBtn = [[UIButton alloc] initWithFrame:CGRectMake(UIScreen.w * 0.7 - 10, (self.h - 30) * 0.5, UIScreen.w * 0.3, 30)];
        [_plusBtn setTitleColor:[JAConfigure sharedCf].titleFontColor forState:UIControlStateNormal];
        _plusBtn.layer.borderColor = [JAConfigure sharedCf].strongFontColor.CGColor;
        _plusBtn.layer.borderWidth = 1;
        [_plusBtn setTitle:@"A+" forState:UIControlStateNormal];
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _plusBtn.backgroundColor = [UIColor whiteColor];
            [_plusBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }else{
            _plusBtn.backgroundColor = HexRGB(0x1a1a1a);
            [_plusBtn setTitleColor:HexRGB(0x657076) forState:UIControlStateNormal];
        }
        [_plusBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusBtn;
}

- (UILabel *)fontLabel {
    if (!_fontLabel) {
        _fontLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_minusBtn.frame) + 5,_backImgView.y - 12.5 ,CGRectGetMinX(_plusBtn.frame) - CGRectGetMaxX(_minusBtn.frame) - 10 , 40)];
        _fontLabel.font = [UIFont systemFontOfSize:19];
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _fontLabel.textColor = [JAConfigure sharedCf].strongFontColor;
        }else {
            _fontLabel.textColor = HexRGB(0x657076);
        }
        _fontLabel.text = @([JAReaderConfig defaultConfig].fontSize).stringValue;
        _fontLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _fontLabel;
}

- (UIImageView *)backImgView {
    if (!_backImgView) {
        _backImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back_l"]];
        _backImgView.h = 15;
        _backImgView.w = 40;
        _backImgView.x = 10;
        _backImgView.y = (self.h - _backImgView.h) * 0.5;
        _backImgView.contentMode = UIViewContentModeLeft;
        _backImgView.userInteractionEnabled = true;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backAction:)];
        [_backImgView addGestureRecognizer:tap];
    }
    return _backImgView;
}

- (void)backAction:(UITapGestureRecognizer *)sender {
    
    [UIView transitionFromView:self toView:self.bottomView duration:0.33 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        self.y += self.h;
    }];
}

- (void)btnAction:(UIButton *)sender {
    BOOL isTooBig = false;
    BOOL isTooSmall = false;
    if ([_fontLabel.text integerValue] > 25) {
        if (sender == _plusBtn) {
            _plusBtn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
            _plusBtn.userInteractionEnabled = false;
            isTooBig = true;
        }
    }else {
        _plusBtn.layer.borderColor = [JAConfigure sharedCf].strongFontColor.CGColor;
        _plusBtn.userInteractionEnabled = true;
    }
    
    if ([_fontLabel.text integerValue] < 11) {
        if (sender == _minusBtn) {
            _minusBtn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
            _minusBtn.userInteractionEnabled = false;
            isTooSmall = true;
        }
    }else {
        _minusBtn.layer.borderColor = [JAConfigure sharedCf].strongFontColor.CGColor;
        _minusBtn.userInteractionEnabled = true;
    }
    
    if (isTooSmall || isTooBig) { return ; }
    
    if (sender == _minusBtn) {
        // 缩小
        [JAReaderConfig defaultConfig].fontSize -= 1;
        _fontLabel.text = @([_fontLabel.text integerValue] - 1).stringValue;
    }else {
        // 放大
        [JAReaderConfig defaultConfig].fontSize += 1;
        _fontLabel.text = @([_fontLabel.text integerValue] + 1).stringValue;
    }
    [self.bottomView.delegate menuViewFontSize:self.bottomView];
}

@end
