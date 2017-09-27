//
//  JABrightnessView.m
//  MStarReader
//
//  Created by Jason on 27/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JABrightnessView.h"
#import "JACategory.h"
#import "JAConfigure.h"
#import "JAReaderConfig.h"
#import "JAReaderPageViewController.h"
#import "MSConfig.h"

@implementation JABrightnessView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.backImgView];
        [self addSubview:self.lowImgView];
        [self addSubview:self.highImgView];
        [self addSubview:self.brightSlider];                
        
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
        _lowImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_7"]];
        _highImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_7"]];
        _backImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_reading_left"]];
        self.backgroundColor = HexRGB(0xffffff);
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, -0.5);
        self.layer.shadowOpacity = 1.0;
        self.clipsToBounds = false;
        // self.layer.shadowColor = [UIColor grayColor].CGColor;
    }else {
       _lowImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_7"]];
        _highImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_7"]];
        _backImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_reading_left"]];
        self.backgroundColor = HexRGB(0x1a1a1a);
        self.clipsToBounds = true;
        // self.layer.shadowColor = HexRGB(0x333232).CGColor;
    }
}

- (UIImageView *)lowImgView {
    if (!_lowImgView) {
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _lowImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_7"]];
        }else {
            _lowImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_7"]];
        }        
        _lowImgView.x = 50;
        _lowImgView.y = _backImgView.y;
        _lowImgView.w = 15;
        _lowImgView.h = 15;
    }
    return _lowImgView;
}

- (UIImageView *)highImgView {
    if (!_highImgView) {
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _highImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_7"]];
        }else {
            _highImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_7"]];
        }        
        _highImgView.x = UIScreen.w - 37;
        _highImgView.y = _backImgView.y - 3.5;
        _highImgView.w = 22;
        _highImgView.h = 22;
    }
    return _highImgView;
}

- (UIImageView *)backImgView {
    if (!_backImgView) {
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _backImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_reading_left"]];
        }else {
            _backImgView = [[UIImageView alloc] initWithImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_reading_left"]];
        }
        
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

- (UISlider *)brightSlider {
    if (!_brightSlider) {
        _brightSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lowImgView.frame) + 5, _backImgView.y - 2.5, CGRectGetMinX(_highImgView.frame) - CGRectGetMaxX(_lowImgView.frame) - 10, 20)];
        _brightSlider.minimumValue = 0;
        _brightSlider.maximumValue = 1;
        _brightSlider.minimumTrackTintColor = [JAConfigure sharedCf].themeColor;
        _brightSlider.maximumTrackTintColor = [JAConfigure sharedCf].contentFontColor;
        
        [_brightSlider setThumbImage:[self thumbImage] forState:UIControlStateNormal];
        [_brightSlider setThumbImage:[self thumbImage] forState:UIControlStateHighlighted];
        [_brightSlider addTarget:self action:@selector(changeMsg:) forControlEvents:UIControlEventValueChanged];
        _brightSlider.value = UIScreen.mainScreen.brightness;
    }
    return _brightSlider;
}

- (void)backAction:(UITapGestureRecognizer *)sender {
    [UIView transitionFromView:self toView:self.bottomView duration:0.33 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        self.y += self.h;
    }];
}

- (void)changeMsg:(UISlider *)sender {
    UIScreen.mainScreen.brightness = sender.value;
}

- (UIImage *)thumbImage {
    CGRect rect = CGRectMake(0, 0, 15,15);
    //
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 5;

    [path addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:7.5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    
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

@end
