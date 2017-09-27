//
//  JAReaderViewController.m
//  MStarReader
//
//  Created by Jason on 22/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderViewController.h"
#import "JAConfigure.h"
#import "JACategory.h"
#import "MSChapterModel.h"
#import "JAReaderConfig.h"
#import "JABatteryStatusView.h"
#import "JAReaderPageViewController.h"

@interface JAReaderViewController ()

@property (nonatomic, strong) UILabel *chapterLabel;
@property (nonatomic,strong) JABatteryStatusView *statusView;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) NSTimer *timer;



@end

@implementation JAReaderViewController

- (instancetype)init {
    if (self = [super init]) {
        _progressLabel = [[UILabel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = [JAReaderConfig defaultConfig].bgColor;
    
    [[JAReaderConfig defaultConfig] addObserver:self forKeyPath:@"theme" options:NSKeyValueObservingOptionNew context:NULL];
    [[JAReaderConfig defaultConfig] addObserver:self forKeyPath:@"fontSize" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.view addSubview:self.readerView];
    [self.view addSubview:self.chapterLabel];
    
    _statusView = [[JABatteryStatusView alloc] initWithFrame:CGRectMake(10, UIScreen.h - 30, 30, 18)];
    [self.view addSubview:_statusView];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, UIScreen.h - 30, 40, 20)];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.text = [NSDate ja_stringFromDate:[NSDate date] withDateFormat:@"hh:mm"];
    [_timeLabel sizeToFit];
    [self.view addSubview:_timeLabel];
    _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(exec) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    // _progressLabel.frame = CGRectMake(UIScreen.w - 70, UIScreen.h - 30, 50, 20);
    _progressLabel.textAlignment = NSTextAlignmentRight;
    _progressLabel.font = [UIFont systemFontOfSize:13];    
    [self.view addSubview:_progressLabel];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(changeThemeAction:)
                                                name:MSReaderChangeThemeNotification
                                              object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        _statusView.backgroundColor = HexRGB(0xffffff);
        _timeLabel.textColor = HexRGB(0x1a1a1a);
        _progressLabel.textColor = HexRGB(0x1a1a1a);
    }else {
        _statusView.backgroundColor = HexRGB(0x1a1a1a);
        _timeLabel.textColor = [JAConfigure sharedCf].contentFontColor;
        _progressLabel.textColor = [JAConfigure sharedCf].contentFontColor;
    }
}

- (void)exec {
    _timeLabel.text = [NSDate ja_stringFromDate:[NSDate date] withDateFormat:@"hh:mm"];
    [_timeLabel sizeToFit];
    [_statusView setNeedsDisplay];
}

- (void)changeThemeAction:(NSNotification *)noti {
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        _statusView.backgroundColor = HexRGB(0xffffff);
    }else {
        _statusView.backgroundColor = HexRGB(0x1a1a1a);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_timer fire];
}

- (void)setProgress:(float)progress {
    _progress = progress;
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",progress * 100];
    [self.progressLabel sizeToFit];
    // UIScreen.w - 70, UIScreen.h - 30
    self.progressLabel.x = UIScreen.w - 70;
    self.progressLabel.y = UIScreen.h - 30;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)readViewEditeding:(JAReaderViewController *)readView {
    if ([self.delegate respondsToSelector:@selector(readViewEditeding:)]) {
        [self.delegate readViewEditeding:self];
    }
}

- (void)readViewEndEdit:(JAReaderViewController *)readView {
    if ([self.delegate respondsToSelector:@selector(readViewEndEdit:)]) {
        [self.delegate readViewEndEdit:self];
    }
}

- (void)setContent:(NSString *)content {
    _content = content;
    self.readerView.content = content;
}

- (void)setChapterTitle:(NSString *)chapterTitle {
    _chapterTitle = chapterTitle;
    self.chapterLabel.text = chapterTitle;
    
    [self.chapterLabel sizeToFit];
    self.chapterLabel.x = 10;
    self.chapterLabel.y = 10;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([object isKindOfClass:[JAReaderConfig class]]) {
        if ([keyPath isEqualToString:@"theme"]) {
            self.view.backgroundColor = [object bgColor];
            self.readerView.backgroundColor = [object bgColor];
        }else if ([keyPath isEqualToString:@"fontSize"]) {
            [self.chapter updateFont];
        }
    }
}

- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    @try {
        [[JAReaderConfig defaultConfig] removeObserver:self forKeyPath:@"theme"];
        [[JAReaderConfig defaultConfig] removeObserver:self forKeyPath:@"fontSize"];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

#pragma mark -
#pragma mark lazyload

- (JAReaderView *)readerView {
    if (!_readerView) {
        _readerView = [[JAReaderView alloc] initWithFrame:CGRectMake(20, kNavHeight + 5, UIScreen.w - 40, UIScreen.h - kNavHeight - 45)];
        // _readerView = [[JAReaderView alloc] initWithFrame:UIScreen.mainBounds];
        _readerView.backgroundColor = [JAReaderConfig defaultConfig].bgColor;
    }
    return _readerView;
}

- (UILabel *)chapterLabel {
    if (!_chapterLabel) {
        _chapterLabel = [[UILabel alloc] init];
        _chapterLabel.textColor = [JAConfigure sharedCf].contentFontColor;
        _chapterLabel.font = [UIFont systemFontOfSize:13];
    }
    return _chapterLabel;
}

@end
