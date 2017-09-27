//
//  JATopMenuView.m
//  MStarReader
//
//  Created by Jason on 26/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JATopMenuView.h"
#import "JACategory.h"
#import "MSUtils.h"
#import "JAConfigure.h"
#import "JAReaderConfig.h"
#import "MSRankCollectionCell.h"
#import "MSBookDescViewController.h"
#import "MSBookModel.h"
#import "JANavigationController.h"
#import "MSConfig.h"
#import "JAReaderPageViewController.h"
#import "MSUserModel.h"
#import "JADBManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MSHTTPSessionManager.h"

@interface JATopMenuView ()

@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) UIButton *moreBtn;
@property (nonatomic,strong) UIButton *modeBtn;
@property (nonatomic,strong) UIButton *bookshelf;
@property (nonatomic,weak) JADBManager *dbMg;
@end

@implementation JATopMenuView

#pragma mark -
#pragma mark Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        self.backgroundColor = HexRGB(0xffffff);
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, -2);
        self.layer.shadowOpacity = 1.0;
        self.clipsToBounds = false;
    }else {
        self.backgroundColor = HexRGB(0x1a1a1a);
        // self.layer.shadowColor = HexRGB(0x333232).CGColor;
    }
    [self addSubview:self.backBtn];
    [self addSubview:self.moreBtn];
    [self addSubview:self.modeBtn];
    [self addSubview:self.titleLabel];
    [self addSubview:self.bookshelf];
    
    
    
    [self.titleLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(changeThemeAction:)
                                                name:MSReaderChangeThemeNotification
                                              object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _backBtn.frame = CGRectMake(10, 30, 35, 20);
    _moreBtn.frame = CGRectMake(UIScreen.w - 30, 24, 30, 33);
    _moreBtn.contentMode = UIViewContentModeScaleAspectFill;
    _modeBtn.frame = CGRectMake(UIScreen.w - 70, 24, 28, 34);
    _modeBtn.contentMode = UIViewContentModeScaleAspectFill;
    _bookshelf.frame = CGRectMake(UIScreen.w - 110, 30, 22, 22);
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow) {
        [UIView transitionWithView:self duration:0.33 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -self.h);
        } completion:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"text"]) {
        [_titleLabel sizeToFit];
        _titleLabel.y = 35;
        _titleLabel.x = (self.w  - _titleLabel.w) * 0.5;
    }
}

#pragma mark - 
#pragma mark Events

- (void)showMoreAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(menuViewShowMore:)]) {
        [self.delegate menuViewShowMore:self];
    }
}

- (void)backAction:(UIBarButtonItem *)sender {
    if([self.delegate respondsToSelector:@selector(menuViewBack:)]) {
        [self.delegate menuViewBack:self];
    }
}

- (void)changeModeAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(menuViewChangeMode:sender:)]) {
        [self.delegate menuViewChangeMode:self sender:self.modeBtn];
    }
}

- (void)changeThemeAction:(NSNotification *)noti {
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        [_backBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_1"]  forState:UIControlStateNormal];
        [_moreBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_3"] forState:UIControlStateNormal];
        [_modeBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateNormal];

        self.backgroundColor = HexRGB(0xffffff);
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, -2);
        self.layer.shadowOpacity = 1.0;
        self.clipsToBounds = false;
        // self.layer.shadowColor = [UIColor grayColor].CGColor;
    }else {
        [_backBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_1"]  forState:UIControlStateNormal];
        [_moreBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_3"] forState:UIControlStateNormal];
        
        [_modeBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateNormal];

        self.backgroundColor = HexRGB(0x1a1a1a);
        self.clipsToBounds = true;
        // self.layer.shadowColor = HexRGB(0x333232).CGColor;
    }
    
    
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    statusBar.alpha = 1.0f;
    
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        [statusBar setValue:HexRGB(0x000000) forKey:@"foregroundColor"];
    }else {
        [statusBar setValue:HexRGB(0xffffff) forKey:@"foregroundColor"];
    }
    
    // [self setNeedsLayout];
}

#pragma mark -
#pragma mark LazyLoad
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [MSUtils commonButtonSEL:@selector(backAction:) target:self];
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            [_backBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_1"]  forState:UIControlStateNormal];
        }else {
            [_backBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_1"]  forState:UIControlStateNormal];
        }
    }
    return _backBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [MSUtils commonButtonSEL:@selector(showMoreAction:) target:self];
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            [_moreBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_3"] forState:UIControlStateNormal];
        }else {
            [_moreBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_3"] forState:UIControlStateNormal];
        }
    }
    return _moreBtn;
}

- (UIButton *)bookshelf {
    if (!_bookshelf) {
        _bookshelf = [[UIButton alloc] init];
        [_bookshelf setImage:[UIImage imageNamed:@"add_bookdesk_ic_normal"] forState:UIControlStateNormal];
        [_bookshelf addTarget:self action:@selector(addToBookshelfAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bookshelf;
}

- (void)addToBookshelfAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(menuViewAdd2Bookshelf:)]) {
        [self.delegate menuViewAdd2Bookshelf:self];
    }
}

- (UIButton *)modeBtn {
    if (!_modeBtn) {
        _modeBtn = [MSUtils commonButtonSEL:@selector(changeModeAction:) target:self];
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            [_modeBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateNormal];
            [_modeBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateHighlighted];
            [_modeBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateSelected];
            [_modeBtn setImage:[[MSConfig sharedConfig].dayBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateSelected | UIControlStateHighlighted];
            // _modeBtn.backgroundColor = [UIColor clearColor];
        }else {
            [_modeBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateNormal];
            [_modeBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateHighlighted];
            [_modeBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateSelected];
            [_modeBtn setImage:[[MSConfig sharedConfig].nightBundle ja_imageWithName:@"icon_read_2"] forState:UIControlStateSelected | UIControlStateHighlighted];
            // _modeBtn.backgroundColor = [UIColor clearColor];
        }
    }
    return _modeBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
            _titleLabel.textColor = HexRGB(0x1a1a1a);
        }else {
            _titleLabel.textColor = [JAConfigure sharedCf].contentFontColor;
        }
    }
    return _titleLabel;
}

- (JADBManager *)dbMg {
    if (!_dbMg) {
        _dbMg = [JADBManager sharedDBManager];
    }
    return _dbMg;
}

- (void)dealloc {
    [self.titleLabel removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
