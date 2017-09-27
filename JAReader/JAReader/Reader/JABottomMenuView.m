//
//  JABottomMenuView.m
//  MStarReader
//
//  Created by Jason on 27/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JABottomMenuView.h"
#import "JACategory.h"
#import "JAConfigure.h"
#import "JAReaderConfig.h"
#import "JASlider.h"
#import "JABrightnessView.h"
#import "JAFontView.h"
#import "JAReaderPageViewController.h"
#import "MSConfig.h"

@interface JABottomMenuView ()

/// 快进时显示的进度视图
@property (nonatomic,strong) JAReadProgressView *progressView;

/// 上一章
@property (nonatomic,strong) UIImageView *lBracketImgView;

/// 下一章
@property (nonatomic,strong) UIImageView *rBracketImgView;

/// 字体
@property (nonatomic,strong) UIButton *fontBtn;

/// 亮度
@property (nonatomic,strong) UIButton *brightnessBtn;

/// 目录
@property (nonatomic,strong) UIButton *catalogBtn;

/// 评论
@property (nonatomic,strong) UIButton *commentBtn;

@end

@implementation JABottomMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
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
    
    [self addSubview:self.lBracketImgView];
    [self addSubview:self.rBracketImgView];
    [self addSubview:self.slider];
    [self addSubview:self.catalogBtn];
    [self addSubview:self.brightnessBtn];
    [self addSubview:self.fontBtn];
    [self addSubview:self.commentBtn];
    // [self addSubview:self.progressView];
    
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(changeThemeAction:)
                                                name:MSReaderChangeThemeNotification
                                              object:nil];
}

- (void)changeThemeAction:(NSNotification *)noti {
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        [_catalogBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_6"] forState:UIControlStateNormal];
        [_catalogBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        [_brightnessBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_7"] forState:UIControlStateNormal];
        [_brightnessBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        [_fontBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_8"] forState:UIControlStateNormal];
        [_fontBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        [_commentBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_9"]forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        _lBracketImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_reading_left"]];
        _rBracketImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_reading_right"]];
        
        self.backgroundColor = HexRGB(0xffffff);
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, -0.5);
        self.layer.shadowOpacity = 1.0;
        self.clipsToBounds = false;
        
    }else {
        [_catalogBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_6"] forState:UIControlStateNormal];
        [_catalogBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        [_brightnessBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_7"] forState:UIControlStateNormal];
        [_brightnessBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        [_fontBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_8"] forState:UIControlStateNormal];
        [_fontBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        [_commentBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_9"]forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        _lBracketImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_reading_left"]];
        _rBracketImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_reading_right"]];
        
        self.backgroundColor = HexRGB(0x1a1a1a);
        self.clipsToBounds = true;
        // self.layer.shadowColor = HexRGB(0x333232).CGColor;

    }
}

- (UIButton *)catalogBtn {
    if (!_catalogBtn) {
        _catalogBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 35, UIScreen.w / 4 , 45)];
        _catalogBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        _catalogBtn.imageView.contentMode = UIViewContentModeCenter;
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            [_catalogBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_6"] forState:UIControlStateNormal];
            [_catalogBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        }else {
            [_catalogBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_6"] forState:UIControlStateNormal];
            [_catalogBtn setTitleColor:HexRGB(0x657076) forState:UIControlStateNormal];
        }
        
        [_catalogBtn setTitle:@"目录" forState:UIControlStateNormal];
        [_catalogBtn setImagePosition:JAMImagePositionTop spacing:0];
        [_catalogBtn addTarget:self action:@selector(catalogAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _catalogBtn;
}

- (UIButton *)brightnessBtn {
    if (!_brightnessBtn) {
        _brightnessBtn = [[UIButton alloc] initWithFrame:CGRectMake(UIScreen.w / 4, 35, UIScreen.w / 4, 45)];
        _brightnessBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        _brightnessBtn.imageView.contentMode = UIViewContentModeCenter;
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            [_brightnessBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_7"] forState:UIControlStateNormal];
            [_brightnessBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        }else {
            [_brightnessBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_7"] forState:UIControlStateNormal];
            [_brightnessBtn setTitleColor:HexRGB(0x657076) forState:UIControlStateNormal];
        }
        
        [_brightnessBtn setTitle:@"亮度" forState:UIControlStateNormal];
        [_brightnessBtn setImagePosition:JAMImagePositionTop spacing:0];
        [_brightnessBtn addTarget:self action:@selector(brightnessAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _brightnessBtn;
}

- (UIButton *)fontBtn {
    if (!_fontBtn) {
        _fontBtn = [[UIButton alloc] initWithFrame:CGRectMake(UIScreen.w / 2, 35, UIScreen.w / 4, 45)];
        _fontBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        _fontBtn.imageView.contentMode = UIViewContentModeCenter;
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            [_fontBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_8"] forState:UIControlStateNormal];
            [_fontBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        }else {
            [_fontBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_8"] forState:UIControlStateNormal];
            [_fontBtn setTitleColor:HexRGB(0x657076) forState:UIControlStateNormal];
        }
        
        [_fontBtn setTitle:@"字体" forState:UIControlStateNormal];
        [_fontBtn setImagePosition:JAMImagePositionTop spacing:0];
        [_fontBtn addTarget:self action:@selector(fontAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fontBtn;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(UIScreen.w  - UIScreen.w / 4, 35, UIScreen.w / 4, 45)];
        _commentBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        _commentBtn.imageView.contentMode = UIViewContentModeCenter;
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            [_commentBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_9"]forState:UIControlStateNormal];
            [_commentBtn setTitleColor:[JAReaderConfig defaultConfig].fontColor forState:UIControlStateNormal];
        }else {
            [_commentBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_9"]forState:UIControlStateNormal];
            [_commentBtn setTitleColor:HexRGB(0x657076) forState:UIControlStateNormal];
        }
        
        [_commentBtn setTitle:@"评论" forState:UIControlStateNormal];
        [_commentBtn setImagePosition:JAMImagePositionTop spacing:0];
        
        [_commentBtn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _commentBtn;
}

- (UIImageView *)lBracketImgView {
    if (!_lBracketImgView) {
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _lBracketImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_reading_left"]];
        }else {
            _lBracketImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_reading_left"]];
        }
        _lBracketImgView.frame = CGRectMake(10, 10, 35, 20);
        _lBracketImgView.contentMode = UIViewContentModeCenter;
    }
    return _lBracketImgView;
}

- (UIImageView *)rBracketImgView {
    if (!_rBracketImgView) {
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _rBracketImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_reading_right"]];
        }else {
            _rBracketImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_reading_right"]];
        }
        
        _rBracketImgView.frame = CGRectMake(UIScreen.w - 45, 10, 35, 20);
        _rBracketImgView.contentMode = UIViewContentModeCenter;
    }
    return _rBracketImgView;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[JASlider alloc] initWithFrame:CGRectMake(40, 10, UIScreen.w - 80, 20)];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        // _slider.continuous = false;
        _slider.minimumTrackTintColor = [JAConfigure sharedCf].themeColor;
        _slider.maximumTrackTintColor = [JAConfigure sharedCf].contentFontColor;
        [_slider setThumbImage:[self thumbImage] forState:UIControlStateNormal];
        [_slider setThumbImage:[self thumbImage] forState:UIControlStateHighlighted];
        
    }
    return _slider;
}

- (UIImage *)thumbImage {
    CGRect rect = CGRectMake(0, 0, 25,25);
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 5;
    [path addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:12.5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    {
        [[JAConfigure sharedCf].contentFontColor setFill];
        [path fill];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
    }
    UIGraphicsEndImageContext();
    return image;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:[JASlider class]]) {
        JASlider *slider = (JASlider *)view;
        if (slider.refreshBlock == nil) {
            slider.refreshBlock = ^(float value) {
                if([self.delegate respondsToSelector:@selector(menuViewJumpProgress:)]) {
                    [self.delegate menuViewJumpProgress:value];
                }
            };
        }
        
        if (slider.moveBlock == nil) {
            slider.moveBlock = ^(float value) {
                if([self.delegate respondsToSelector:@selector(menuViewChapterToastWithProgress:)]) {
                    [self.delegate menuViewChapterToastWithProgress:value];
                }
            };
        }
    }
    return view;
}

#pragma mark -
- (void)brightnessAction:(UIButton *)sender {
    JABrightnessView *bView = [[JABrightnessView alloc] initWithFrame:CGRectMake(0, UIScreen.h, UIScreen.w, 80)];
    bView.bottomView = self;
    [self.superview addSubview:bView];
    
    [UIView transitionFromView:self toView:bView duration:0.33 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        bView.y -= bView.h;
    }];
    _brightnessView = bView;
    
}

- (void)fontAction:(UIButton *)sender {
    JAFontView *fView = [[JAFontView alloc] initWithFrame:CGRectMake(0, UIScreen.h , UIScreen.w, 80)];
    fView.bottomView = self;
    [self.superview addSubview:fView];
    [UIView transitionFromView:self toView:fView duration:0.33 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        fView.y -= fView.h;
    }];
    _fontView = fView;
}

- (void)commentAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(menuViewComment:)]) {
        [self.delegate menuViewComment:self];
    }
}

- (void)catalogAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(menuViewInvokeCatalog:)]) {
        [self.delegate menuViewInvokeCatalog:self];
    }
}

@end

@implementation JAReadProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _chapterLabel = [[UILabel alloc] init];
        _chapterLabel.textColor = HexRGB(0xffffff);
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.6];
        [self addSubview:_chapterLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _chapterLabel.frame = CGRectMake(40, 10, self.w - 60, 30);
}

- (void)title:(NSString *)title progress:(NSString *)progress {
    _chapterLabel.text = [NSString stringWithFormat:@"%@ %@",title,progress];
}

@end
