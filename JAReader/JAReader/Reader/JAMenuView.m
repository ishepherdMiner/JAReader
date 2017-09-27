//
//  JAMenuView.m
//  MStarReader
//
//  Created by Jason on 26/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAMenuView.h"
#import "JAConfigure.h"
#import "JACategory.h"
#import "JAReaderConfig.h"
#import "JABrightnessView.h"
#import "JAFontView.h"

@implementation JAMenuView

- (instancetype)initWithFrame:(CGRect)frame {    
    if (self = [super initWithFrame:frame]) {
        [self setup];        
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addSubview:self.titleLabel];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenSelf)]];
}

- (JATopMenuView *)topView {
    if (!_topView) {
        _topView = [[JATopMenuView alloc] init];
        _topView.frame = CGRectMake(0, -kNavHeight, self.w,kNavHeight);
    }
    return _topView;
}

- (JABottomMenuView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[JABottomMenuView alloc] init];
        _bottomView.frame = CGRectMake(0, UIScreen.h, UIScreen.w,80);
    }
    return _bottomView;
}

- (void)setTitleLabelString:(NSString *)titleLabelString {
    _titleLabelString = titleLabelString;
    _titleLabel.text = titleLabelString;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleLabel sizeToFit];
    _titleLabel.w += 100;
    _titleLabel.h += 20;
    _titleLabel.alpha = 1.0;
    _titleLabel.x = (UIScreen.w - _titleLabel.w) * 0.5;
    _titleLabel.y = UIScreen.h - 150;
}

#pragma mark -
- (void)hiddenSelf {
    [self hiddenAnimation:true];
}

- (void)showAnimation:(BOOL)animation {
    self.hidden = false;
    [UIView animateWithDuration:animation?0.3:0 animations:^{
        _topView.frame = CGRectMake(0, 0, UIScreen.w, kNavHeight);
        _bottomView.frame = CGRectMake(0, UIScreen.h - 80, UIScreen.w,80);
        _bottomView.hidden = false;
        
    } completion:^(BOOL finished) {
        
    }];
    if ([self.delegate respondsToSelector:@selector(menuViewDidAppear:)]) {
        [self.delegate menuViewDidAppear:self];
    }
}

- (void)hiddenAnimation:(BOOL)animation {
    
    [UIView animateWithDuration:animation ? 0.3:0 animations:^{
        _topView.frame = CGRectMake(0, -kNavHeight, self.w, kNavHeight);
        _bottomView.frame = CGRectMake(0, UIScreen.h ,self.w,80);
    } completion:^(BOOL finished) {
        self.hidden = true;
        if (_bottomView.brightnessView) {
            [_bottomView.brightnessView removeFromSuperview];
        }
        if(_bottomView.fontView) {
            [_bottomView.fontView removeFromSuperview];
        }
    }];
    if ([self.delegate respondsToSelector:@selector(menuViewDidHidden:)]) {
        [self.delegate menuViewDidHidden:self];
    }
    
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    statusBar.alpha = 0.0f;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.alpha = 0.0;
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _titleLabel.textColor = HexRGB(0xffffff);
            _titleLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        }else {
            _titleLabel.textColor = [JAConfigure sharedCf].contentFontColor;
            _titleLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        }
    }
    return _titleLabel;
}

@end
