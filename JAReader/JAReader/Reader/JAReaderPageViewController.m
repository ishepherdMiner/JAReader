//
//  JAReaderPageViewController.m
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderPageViewController.h"
#import "JAReaderViewController.h"
#import "YYModel.h"
#import "MSChapterModel.h"
#import "JACategory.h"
#import "MSBookModel.h"
#import "MSUserModel.h"
#import "MSRecordModel.h"
#import "JADBManager.h"
#import "JAReaderParser.h"
#import "MSHTTPSessionManager.h"
#import "JAMenuView.h"
#import "MSBookDescViewController.h"
#import "JANavigationController.h"
#import "JAReaderConfig.h"
#import "MSRankCollectionCell.h"
#import "JABrightnessView.h"
#import "JAFontView.h"
#import "MSCommentViewController.h"
#import "UIImage+ImageEffects.h"
#import "JACatalogViewController.h"
#import "BackViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "JAToastButton.h"
#import "MSChapterListView.h"

NSNotificationName MSReaderShelfLoadedNotification = @"MSReaderShelfLoadedNotification";
NSNotificationName MSReaderLoadedNotification = @"MSReaderLoadedNotification";
NSNotificationName MSReaderChangeThemeNotification = @"MSReaderChangeThemeNotification";
NSNotificationName MSReaderDownloadedNotification = @"MSReaderDownloadedNotification";

@interface JAReaderPageViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate,
                            UIGestureRecognizerDelegate,JAMenuViewDelegate,
                            JAButtomMenuViewDelegate,JATopMenuViewDelegate,JAReadViewControllerDelegate,JACatalogViewControllerDelegate>


@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,strong) JAReaderViewController *readerViewController;
@property (nonatomic,strong) MSRankCollectionCell *detailView;

@property (nonatomic,strong) UIView * catalogView;  // 侧边栏背景
@property (nonatomic,strong) JAMenuView *menuView;  // 菜单栏
@property (nonatomic,strong) JACatalogViewController *catalogVC; // 目录
@property (nonatomic,assign) NSUInteger curPage;
@property (assign) BOOL pageIsAnimating;

/// 专门用于请求跳转时的章节内容
@property (nonatomic,strong) MSHTTPSessionManager *ChapterMg;

/// 本次阅读记录
@property (nonatomic,strong) MSRecordModel *recordModel;

@property (nonatomic,weak) JAReaderViewController *currentReaderViewController;

@property (nonatomic,strong) JAToastButton *toastBtn;

@property (nonatomic,assign) BOOL isAfter;
@property (nonatomic,assign) BOOL isBefore;
@property (nonatomic,assign) BOOL isAfterChapter;
@property (nonatomic,assign) BOOL isBeforeChapter;

@property (nonatomic,assign) CGFloat progress;

@end

@implementation JAReaderPageViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.pageViewController];
    _readerViewController = [[JAReaderViewController alloc] init];
    [self.pageViewController setViewControllers:@[_readerViewController] direction:UIPageViewControllerNavigationDirectionForward animated:true completion:NULL];
    
    [self.view addSubview:self.menuView];
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolMenu:)];
        tap.delegate = self;
        tap;
    })];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRecordAction:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRecordAction:) name:UIApplicationWillTerminateNotification object:nil];
    
    [self addChildViewController:self.catalogVC];
    [self.view addSubview:self.catalogView];
    [self.catalogView addSubview:self.catalogVC.view];
    
    _pageIsAnimating = false;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    statusBar.alpha = 0.0f;
    
    [self setPageContentWithPageViewController:_readerViewController
                                       chapter:_chapter
                                        record:_recordModel
                                      position:-1];
    
    self.catalogVC.component.readChapterNum = _recordModel.num;
    
    NSUserDefaults *msDefault = [NSUserDefaults standardUserDefaults];
    if ([msDefault objectForKey:@"firstRead"] == nil) {
        UIView *bgView = [[UIView alloc] initWithFrame:_readerViewController.readerView.bounds];
        UIImageView *guideView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"read_guide"]];
        // guideView.frame = _readerViewController.view.bounds;
        // guideView.contentMode = UIViewContentModeCenter;
        guideView.x = (bgView.w - guideView.w) * 0.5;
        guideView.y = (bgView.h - guideView.h) * 0.5;
        [bgView addSubview:guideView];
        [_readerViewController.readerView addSubview:bgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissGuideViewAction:)];
        [bgView addGestureRecognizer:tap];
        [msDefault setObject:@"1" forKey:@"firstRead"];
    }
    
    // 更新进度条
    self.progress = [_recordModel.num doubleValue] / [self.catalogVC.datas count];
    [self.menuView.bottomView.slider setValue:self.progress animated:true];
    _readerViewController.progress = self.progress;
}

- (void)dismissGuideViewAction:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:1.0 animations:^{
        sender.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [sender.view removeFromSuperview];
    }];
}
- (void)loadReader {
    
    dispatch_group_t g = dispatch_group_create();
    
    dispatch_group_enter(g);
    [self.catalogVC networkOfChapterListWithCompletion:^{
        dispatch_group_leave(g);
    }];
    
    dispatch_group_enter(g);
    MSRecordModel *record = [[MSUserModel sharedUser].records objectForKey:self.book.bookid];
    
    // 读取本地记录
    if (record) {
        _recordModel = record;
        _menuView.bottomView.slider.value = (CGFloat)[_recordModel.num integerValue] / self.catalogVC.component.cmodels.count;
    }else {
        _recordModel = [[MSRecordModel alloc] init];
        _recordModel.num = @"1";
        _recordModel.bid = self.book.bookid;
        _recordModel.start_index = @"0";
    }
    
    BOOL isDownloaded = [self storedToLocalWithNum:_recordModel.num lazyLoad:false];
    
    if (isDownloaded) {
        _chapter.content = [JAReaderParser parseMarkup:_chapter.content];
        dispatch_group_leave(g);
    }else {
    
        NSString *chapterids = [self requestQueueWithStartNum:_recordModel.num];
        NSString *url = [NSString stringWithFormat:@"chapter/%@/%@",self.book.bookid,chapterids];
        
        // NSLog(@"1");
        [[MSHTTPSessionManager manager] GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([responseObject isKindOfClass:[NSArray class]]) {
                [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MSChapterModel *m = [MSChapterModel yy_modelWithDictionary:obj];
                    m.cState = MSCharterStateDownloaded;
                    if ([_recordModel.num integerValue] == [m.num integerValue]) { _chapter = m; }
                    [self.dbMg insertObject:m];
                    [self updateBookWithChapter:m];
                    [[NSNotificationCenter defaultCenter] postNotificationName:MSReaderDownloadedNotification object:m];                    
                }];
                _chapter.content = [JAReaderParser parseMarkup:_chapter.content];
                // 设置内容
                dispatch_group_leave(g);
                self.isLoadSuccess = true;
                // NSLog(@"2");
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            self.isLoadSuccess = false;
            dispatch_group_leave(g);
        }];
    }

    dispatch_group_notify(g, dispatch_get_main_queue(), ^{
        if (self.isDetail) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MSReaderLoadedNotification object:self];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:MSReaderShelfLoadedNotification object:self];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Reader Core
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
//    NSLog(@"%s",__func__);
    if (_pageIsAnimating) { return nil; }
    
    if (_pageViewController.transitionStyle == UIPageViewControllerTransitionStylePageCurl) {
        if([viewController isKindOfClass:[JAReaderViewController class]]) {
            
            BackViewController *backViewController = [[BackViewController alloc] init];
            [backViewController updateWithViewController:viewController];
            return backViewController;
        }
    }
    
    JAReaderViewController *vc = [[JAReaderViewController alloc] init];
    _currentReaderViewController = vc;
    
    if (self.curPage > 0) {
        self.isAfter = false;
        self.isBefore = true;
        self.isAfterChapter = false;
        self.isBeforeChapter = false;
        // _currentReaderViewController = vc;
        
        [self setPageContentWithPageViewController:vc
                                           chapter:_chapter
                                            record:_recordModel
                                          position:self.curPage - 1];
        return vc;
        
    }else {
        if ([_recordModel.num integerValue] <= 1) { return nil;}
        
        self.isAfter = false;
        self.isBefore = false;
        self.isAfterChapter = false;
        self.isBeforeChapter = true;
        
        // 上一章
        for (int i = 0; i < self.catalogVC.component.cmodels.count; ++i) {
            if ([[self.catalogVC.component.cmodels[i] num] integerValue] == [_chapter.num integerValue]) {
                // 已经是最后一章了
                if (i == 0) {
                    return nil;
                }else {
                    _recordModel.num = [self.catalogVC.component.cmodels[i-1] num].stringValue;
                }
            }
        }
        
        BOOL isDownloaded = [self storedToLocalWithNum:_recordModel.num lazyLoad:false];
        _recordModel.start_index = _chapter.pages.lastObject;
        
        [self updateRecordAction:nil];
        if (isDownloaded) {
            _chapter.content = [JAReaderParser parseMarkup:_chapter.content];
            [self setPageContentWithPageViewController:vc
                                               chapter:_chapter
                                                record:_recordModel
                                              position:-1];
            
            NSString *recordNum = _recordModel.num;
            /// 首章前面没有章节了
            if ([_recordModel.num integerValue] == 1) { return vc; }
            
            /// 找到下一个待下载章节
            recordNum = @([recordNum integerValue] - 1).stringValue;
            if ([self storedToLocalWithNum:recordNum lazyLoad:true]) {
                _currentReaderViewController = vc;
                return vc;
            }
            
            if ([recordNum integerValue] == 1) {
                // self.curPage = _chapter.pages.count - 1;
                _currentReaderViewController = vc;
                return vc;
            }
//            while (true) {
//                
//            }
            [self loadChapterFromWebWithBookid:self.book.bookid num:recordNum immediateLoad:false];
        }else {
            // 被删除要重新下载
            [self loadChapterFromWebWithBookid:self.book.bookid num:_recordModel.num immediateLoad:true];
        }
        // self.curPage = _chapter.pages.count - 1;
        return vc;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
//    NSLog(@"%s",__func__);
    
    if (_pageIsAnimating) { return nil; }
    
    if (_pageViewController.transitionStyle == UIPageViewControllerTransitionStylePageCurl) {
        if([viewController isKindOfClass:[JAReaderViewController class]]) {
            BackViewController *backViewController = [[BackViewController alloc] init];
            [backViewController updateWithViewController:viewController];
            return backViewController;
        }
    }
    
    JAReaderViewController *vc = [[JAReaderViewController alloc] init];
    _currentReaderViewController = vc;
    
    if (self.curPage < _chapter.pages.count - 1) {
        
        self.isAfter = true;
        self.isBefore = false;
        self.isAfterChapter = false;
        self.isBeforeChapter = false;
        
        
        [self setPageContentWithPageViewController:vc
                                           chapter:_chapter
                                            record:_recordModel
                                          position:self.curPage+1];
        return vc;
        
    }else {
        
        self.isAfter = false;
        self.isBefore = false;
        self.isAfterChapter = true;
        self.isBeforeChapter = false;
        
        for (int i = 0; i < self.catalogVC.component.cmodels.count; ++i) {
            if ([[self.catalogVC.component.cmodels[i] num] integerValue] == [_chapter.num integerValue]) {
                // 已经是最后一章了
                if (i == self.catalogVC.component.cmodels.count - 1) {
                    return nil;
                }else {
                    _recordModel.num = [self.catalogVC.component.cmodels[i+1] num].stringValue;
                    break;
                }
            }
        }
        
        _recordModel.start_index = @"0";
        
        // 下一章
        // 查询章节表是否已经下载
        BOOL isDownloaded = [self storedToLocalWithNum:_recordModel.num lazyLoad:false];
        
        // 更新阅读记录
        [self updateRecordAction:nil];
        
        // _currentReaderViewController = vc;
        
        if (isDownloaded) {
            _chapter.content = [JAReaderParser parseMarkup:_chapter.content];
            
            [self setPageContentWithPageViewController:vc
                                               chapter:_chapter
                                                record:_recordModel
                                              position:-1];
            
            NSString *recordNum = _recordModel.num;
            /// 最后一个章节也已下载
            if ([_recordModel.num integerValue]+ 2 > self.catalogVC.component.cmodels.count) { return nil;}
            /// 找到下一个待下载章节
//            while (true) {
//                
//            }
            recordNum = @([recordNum integerValue] + 1).stringValue;
            if ([self storedToLocalWithNum:recordNum lazyLoad:true]) {
                _currentReaderViewController = vc;
                return vc;
            }
            
            if ([recordNum integerValue] == self.catalogVC.component.cmodels.count) {
                // self.curPage = 0;
                _currentReaderViewController = vc;
                return vc;
            }
            [self loadChapterFromWebWithBookid:self.book.bookid num:recordNum immediateLoad:false];
        }else {
            
            // 被删除重新下载该章节
            [self loadChapterFromWebWithBookid:self.book.bookid num:_recordModel.num immediateLoad:true];
        }
        // self.curPage = 0;
        
        return vc;
    }
}

- (void)loadChapterFromWebWithBookid:(NSString *)bookid num:(NSString *)num immediateLoad:(BOOL)immediateLoad{
    
    [self loadChapterFromWebWithBookid:bookid
                                   num:num
                         immediateLoad:immediateLoad
                        networkManager:[MSHTTPSessionManager manager]
                  willPermanentTrigger:nil
                   didPermanentTrigger:nil];
}

- (void)loadChapterFromWebWithBookid:(NSString *)bookid
                                 num:(NSString *)num
                       immediateLoad:(BOOL)immediateLoad
                      networkManager:(MSHTTPSessionManager *)manager
                willPermanentTrigger:(void (^)(MSChapterModel *chapter))willTrigger
                 didPermanentTrigger:(void (^)(MSChapterModel *chapter))didTrigger{
    
    NSString *url = [NSString stringWithFormat:@"chapter/%@/%@",bookid,num];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSArray class]] && [responseObject count] > 0) {
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    MSChapterModel *m = [MSChapterModel yy_modelWithDictionary:obj];
                    m.cState = MSCharterStateDownloaded;

                    if (immediateLoad == true) { _chapter = m; }
                    
                    if (willTrigger) { willTrigger(m);}
                    
                    [self.dbMg insertObject:m];
                    [self updateBookWithChapter:m];
                    
                    // [self catalogViewController:nil record:self.recordModel];
                    [[NSNotificationCenter defaultCenter] postNotificationName:MSReaderDownloadedNotification object:m];
                    
                    if (didTrigger) { didTrigger(m); }
                });
            }];
            self.catalogVC.shouldReload = true;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)catalogViewController:(JACatalogViewController *)catalogVC record:(MSRecordModel *)record {
    if (catalogVC) {
        [self hiddenCatalog];
    }
    
    
}
- (void)catalogViewController:(JACatalogViewController *)catalogVC num:(NSString *)num {
    
    if (catalogVC) {
        [self hiddenCatalog];
    }
    
    _recordModel.num = num;
    // [self updateRecordAction:nil];
    
    _progress = [_recordModel.num doubleValue] / self.catalogVC.component.cmodels.count;
    
    [self.menuView.bottomView.slider setValue:_progress animated:true];
    
    if (_currentReaderViewController) {
        _currentReaderViewController.progress = _progress;
    }else {
        _readerViewController.progress = _progress;
        _currentReaderViewController = _readerViewController;
    }
    
    self.catalogVC.shouldReload = true;
    
    for (int i = 0; i < self.catalogVC.component.cmodels.count; ++i) {
        if([self.catalogVC.component.cmodels[i] cState] == MSCharterStateReading) {
            _chapter.cState = MSCharterStateDownloaded;
            [self.catalogVC.component.cmodels[i] setCState:MSCharterStateDownloaded];
        }
        if ([[self.catalogVC.component.cmodels[i] num].stringValue isEqualToString:num]) {
            _chapter.cState = MSCharterStateReading;
            [self.catalogVC.component.cmodels[i] setCState:MSCharterStateReading];
            self.catalogVC.component.readChapterNum = num;
        }
    }

    
    // 查询章节表是否已经下载
    BOOL isDownloaded = [self storedToLocalWithNum:_recordModel.num lazyLoad:false];
    
    
    // 重要 全局性的变量一定要注意
    self.curPage = 0;
    
    if (isDownloaded) {
        _chapter.content = [JAReaderParser parseMarkup:_chapter.content];
        
        [self setPageContentWithPageViewController:_currentReaderViewController ? : _readerViewController
                                           chapter:_chapter
                                            record:_recordModel
                                          position:0];
        
    }else {
        [self loadChapterFromWebWithBookid:self.book.bookid num:_recordModel.num immediateLoad:true networkManager:[MSHTTPSessionManager manager] willPermanentTrigger:^(MSChapterModel *chapter) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *chapterCopyContent = [_chapter.content copy];
                // 展示到界面上
                _chapter.content = [JAReaderParser parseMarkup:_chapter.content];
                [self setPageContentWithPageViewController:_currentReaderViewController ? :_readerViewController
                                                   chapter:_chapter
                                                    record:_recordModel
                                                  position:0];
                
                // 添加到数据库
                _chapter.content = chapterCopyContent;
                
            });
        } didPermanentTrigger:^(MSChapterModel *chapter) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 下一次的展示
                _chapter.content = [JAReaderParser parseMarkup:_chapter.content];
                
            });
        }];
    }
    
    
    //  请求前一章 & 后一章
    
    NSString *nextRecordNum = _recordModel.num;
    NSString *priorRecordNum = _recordModel.num;
    BOOL hasNext = false;
    BOOL hasPrior = false;
    
    /// 最后一个章节也已下载
    if ([nextRecordNum integerValue] + 1 > self.catalogVC.component.cmodels.count) { return;}
    /// 找到下一个待下载章节
    while (true) {
        nextRecordNum = @([nextRecordNum integerValue] + 1).stringValue;
        if (![self storedToLocalWithNum:nextRecordNum lazyLoad:true]) {
            hasNext = true;
            break;
        }
        
        if ([nextRecordNum integerValue] == self.catalogVC.component.cmodels.count) {
            break;
        }
    }
    
    /// 首章前面没有章节了
    if ([priorRecordNum integerValue] == 1) { return; }
    
    /// 找到下一个待下载章节
    while (true) {
        priorRecordNum = @([priorRecordNum integerValue] - 1).stringValue;
        if (![self storedToLocalWithNum:priorRecordNum lazyLoad:true]) {
            hasPrior = true;
            break;
        }
        
        if ([priorRecordNum integerValue] == 1) {
            break;
        }
    }
    
    NSMutableString *requestChapters = [NSMutableString string];
    if (hasPrior) {
        [requestChapters appendString:priorRecordNum];
        [requestChapters appendString:@","];
    }
    
    if (hasNext) {
        [requestChapters appendString:nextRecordNum];
    }
    
    [self loadChapterFromWebWithBookid:self.book.bookid num:requestChapters immediateLoad:false];
}

- (void)menuViewChapterToastWithProgress:(CGFloat)progress {
    NSString *num = @((int)(progress * self.catalogVC.component.cmodels.count)).stringValue;
    for (int i = 0; i < self.catalogVC.component.cmodels.count; ++i) {
        if ([[self.catalogVC.component.cmodels[i] num].stringValue isEqualToString:num]) {
            if(self.currentReaderViewController) {
//                self.currentReaderViewController.chapterTitle = [self.catalogVC.component.cmodels[i] charterTitle];
                // _menuView.topView.titleLabel.alpha = 1.0;
                // _menuView.topView.titleLabel.text = [self.catalogVC.component.cmodels[i] charterTitle];
                _menuView.titleLabelString = [self.catalogVC.component.cmodels[i] charterTitle];
            }else {
//                self.readerViewController.chapterTitle = [self.catalogVC.component.cmodels[i] charterTitle];
                // _menuView.topView.titleLabel.alpha = 1.0;
                // _menuView.topView.titleLabel.text = [self.catalogVC.component.cmodels[i] charterTitle];
                _menuView.titleLabelString = [self.catalogVC.component.cmodels[i] charterTitle];
            }
            
            [UIView animateWithDuration:1.0 animations:^{
                _menuView.titleLabel.alpha = 0.0;
            }];
        }
    }
}

- (void)menuViewJumpProgress:(CGFloat)progress {
    _recordModel.num = @((int)(progress * self.catalogVC.component.cmodels.count)).stringValue;
    _recordModel.start_index = @"0";
    
    // _progress = [_recordModel.num doubleValue] / self.catalogVC.component.cmodels.count;
    
    [self catalogViewController:nil num:_recordModel.num];
}

- (void)setPageContentWithPageViewController:(JAReaderViewController *)readerViewController
                                     chapter:(MSChapterModel *)chapter
                                      record:(MSRecordModel *)record
                                    position:(NSInteger)position {
    
    // 手动指定[比如开头]
    if (position != -1) {
        record.start_index = @([chapter.pages[position] integerValue]).stringValue;
        if (_currentReaderViewController) {
            _currentReaderViewController.content = [chapter stringOfPage:position];
            _currentReaderViewController.chapterTitle = chapter.charterTitle;
            _currentReaderViewController.chapter = chapter;
//             _menuView.topView.titleLabel.alpha = 1.0;
//            _menuView.topView.titleLabel.text = _chapter.charterTitle;
            // _menuView.titleLabelString = _chapter.charterTitle;
            
        }else {
            readerViewController.content = [chapter stringOfPage:position];
            readerViewController.chapterTitle = chapter.charterTitle;
            readerViewController.chapter = chapter;
            // _menuView.topView.titleLabel.alpha = 1.0;
            // _menuView.topView.titleLabel.text = _chapter.charterTitle;
            //_menuView.titleLabelString = _chapter.charterTitle;
        }
        
//        [UIView animateWithDuration:1.0 animations:^{
//            _menuView.titleLabel.alpha = 0.0;
//        }];
        
        return;
    }
    
    // 自动计算
    for (int i = 0; i < chapter.pages.count; ++i) {
        if ([record.start_index integerValue] <= [chapter.pages[i] integerValue]) {
            if (_currentReaderViewController) {
                _currentReaderViewController.content = [chapter stringOfPage:i];
                _currentReaderViewController.chapterTitle = chapter.charterTitle;
                _currentReaderViewController.chapter = chapter;
                // _menuView.topView.titleLabel.alpha = 1.0;
                // _menuView.topView.titleLabel.text = _chapter.charterTitle;
                _menuView.titleLabelString = _chapter.charterTitle;
            }else {
                readerViewController.content = [chapter stringOfPage:i];
                _menuView.topView.titleLabel.alpha = 1.0;
                readerViewController.chapterTitle = chapter.charterTitle;
                readerViewController.chapter = chapter;
                _menuView.titleLabelString = _chapter.charterTitle;
            }
            [UIView animateWithDuration:1.0 animations:^{
                _menuView.titleLabel.alpha = 0.0;
            }];
            [self.view setNeedsLayout];
            self.curPage = i;
            break;
        }
    }
}

/**
 num章节是否已下载到本地
 
 @param num 章节号
 @return 是否已下载
 */
- (BOOL)storedToLocalWithNum:(NSString *)num lazyLoad:(BOOL)isLazyload {
    BOOL isDownloaded = false;
    NSString *chapterid = nil;
    
    JASql *chapterSql = [JASql select:nil from:[MSChapterModel class] where:[NSString stringWithFormat:@"bookid = %@ AND num = %@",_recordModel.bid,num]];
    NSArray *chapters = [self.dbMg selectObjects:[MSChapterModel class] sql:chapterSql];
    if ([chapters isKindOfClass:[MSChapterModel class]]) {
        chapters = @[chapters];
    }
    for (int i = 0; i < chapters.count; ++i) {
        if ([[chapters[i] num].stringValue isEqualToString:num]) {
            isDownloaded = true;
            chapterid = [chapters[i] charterid];
            break;
        }
    }

    
    if (isDownloaded) {
        if(isLazyload == false) {
            _chapter = [self.dbMg selectObject:[MSChapterModel class] withValue:chapterid];
        }
    }
    
    return isDownloaded;
}


- (NSString *)requestQueueWithStartNum:(NSString *)startNum {
    NSMutableArray *chapterGroupNums = [NSMutableArray array];
    if ([startNum integerValue] > 1) {
        NSUInteger lastNum = [startNum integerValue];
        NSUInteger nextNum = [startNum integerValue];
        while (true) {
            lastNum = lastNum - 1;
            if (![self storedToLocalWithNum:@(lastNum).stringValue lazyLoad:true]) { break; }
        }
        while (true) {
            nextNum = nextNum + 1;
            if (![self storedToLocalWithNum:@(nextNum).stringValue lazyLoad:true]) { break; }
        }
        
        if (lastNum != [startNum integerValue]) {
            [chapterGroupNums addObject:@(lastNum).stringValue];
        }
        
        [chapterGroupNums addObject:startNum];
        
        if (nextNum != [startNum integerValue]) {
            [chapterGroupNums addObject:@(nextNum).stringValue];
        }
        
    }else if ([startNum integerValue] == 1) {
        NSUInteger nextNum = [startNum integerValue];
        while (true) {
            nextNum = nextNum + 1;
            if (![self storedToLocalWithNum:@(nextNum).stringValue lazyLoad:true]) { break; }
        }
        
        NSUInteger nextMoreNum = nextNum;
        while (true) {
            nextMoreNum = nextMoreNum + 1;
            if (![self storedToLocalWithNum:@(nextMoreNum).stringValue lazyLoad:true]) { break; }
        }
        
        [chapterGroupNums addObject:startNum];
        [chapterGroupNums addObject:@(nextNum).stringValue];
        [chapterGroupNums addObject:@(nextMoreNum).stringValue];
    }
    
    return [chapterGroupNums componentsJoinedByString:@","];
}

- (void)updateRecordAction:(NSNotification *)noti {
    
    JASql *sql = [JASql select:@" * "
                          from:[MSRecordModel class]
                         where:[NSString stringWithFormat:@"bid = %@",_recordModel.bid]];
    
    MSRecordModel *record = [self.dbMg selectObjects:[MSRecordModel class] sql:sql];
    
    if (record == nil) {
        [self.dbMg insertObject:_recordModel];
        record = [self.dbMg selectObjects:[MSRecordModel class] sql:sql];
    }else {
        _recordModel.recordId = record.recordId;
        [self.dbMg updateTableWithObject:_recordModel];
        record = [self.dbMg selectObjects:[MSRecordModel class] sql:sql];
    }
    
    MSUserModel *userModel = [MSUserModel sharedUser];
    [userModel.records setObject:record forKey:_recordModel.bid];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.dbMg updateTableWithObject:userModel onProperities:@[@"records"]];
        [userModel persistence];
    });
    
    
    
}

- (void)updateBookWithChapter:(MSChapterModel *)chapter {
    MSBookModel *b = [self.dbMg selectObject:[MSBookModel class] withValue:self.book.bookid];
    
    // 更新这本书的charters字段,表示该章节已下载过
    if (b) {
        __block BOOL isInDb = false;
        NSMutableArray *bM = [NSMutableArray arrayWithArray:b.charters];
        
        [b.charters enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isEqualToString:chapter.charterid]) {
                isInDb = true;
                *stop = true;
            }
        }];
        
        if (isInDb == false) {
            [bM addObject:chapter.charterid];
            b.charters = [bM copy];
            [self.dbMg updateTableWithObject:b];
        }
        self.book = b;
    }
}

#pragma mark - Read View Controller Delegate
- (void)readViewEndEdit:(JAReaderViewController *)readView {
    for (UIGestureRecognizer *ges in self.pageViewController.view.gestureRecognizers) {
        if ([ges isKindOfClass:[UIPanGestureRecognizer class]]) {
            ges.enabled = YES;
            break;
        }
    }
}

- (void)readViewEditeding:(JAReaderViewController *)readView {
    for (UIGestureRecognizer *ges in self.pageViewController.view.gestureRecognizers) {
        if ([ges isKindOfClass:[UIPanGestureRecognizer class]]) {
            ges.enabled = NO;
            break;
        }
    }
}

#pragma mark - 
#pragma mark Events

- (void)showToolMenu:(UITapGestureRecognizer *)sender {
    // 取消选择状态
    [_readerViewController.readerView cancelSelected];
    [self.menuView showAnimation:true];
    
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    statusBar.alpha = 1.0f;
    
    //
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        
        [statusBar setValue:HexRGB(0x000000) forKey:@"foregroundColor"];
    }else {
        [statusBar setValue:HexRGB(0xffffff) forKey:@"foregroundColor"];
    }
    
}

- (void)catalogShowState:(BOOL)show {
    show?({
        _catalogView.hidden = !show;
        
        if (self.catalogVC.isShouldReload) {
            [self.catalogVC.component onStart];
            self.catalogVC.shouldReload = false;
        }
        [UIView animateWithDuration:0.3 animations:^{
            _catalogView.frame = CGRectMake(0, 0,2 * self.view.w,self.view.h);
            
        } completion:^(BOOL finished) {
            [_catalogView insertSubview:[[UIImageView alloc] initWithImage:[self blurredSnapshot]] atIndex:0];
        }];
    }):({
        if ([_catalogView.subviews.firstObject isKindOfClass:[UIImageView class]]) {
            [_catalogView.subviews.firstObject removeFromSuperview];
        }
        [UIView animateWithDuration:0.3 animations:^{
            _catalogView.frame = CGRectMake(-self.view.w, 0, 2*self.view.w, self.view.h);
        } completion:^(BOOL finished) {
            _catalogView.hidden = !show;
            
        }];
    });
}

-(void)hiddenCatalog{
    [self catalogShowState:NO];
}

- (UIImage *)blurredSnapshot {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)), NO, 1.0f);
    [self.view drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    UIGraphicsEndImageContext();
    return blurredSnapshotImage;
}

#pragma mark - 
#pragma mark JAMenuViewDelegate...

- (void)menuViewShowMore:(JATopMenuView *)topMenu {
    if (!_detailView) {
        _detailView = [[NSBundle mainBundle] loadNibNamed:@"MSRankCollectionCell" owner:nil options:nil].lastObject;
        _detailView.y = UIScreen.h;
        _detailView.backgroundColor = [UIColor whiteColor];
        [_menuView addSubview:_detailView];
        
        [UIView transitionWithView:topMenu duration:0.33 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _detailView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -_detailView.h);
        } completion:^(BOOL finished) {
            _detailView.layer.shadowColor = [UIColor grayColor].CGColor;
            _detailView.layer.shadowOffset = CGSizeMake(1, -2);
            _detailView.layer.shadowOpacity = 1.0;
            _detailView.backgroundColor = HexRGB(0xffffff);
            _detailView.clipsToBounds = false;
        }];
        
        _detailView.shelfBookModel = self.book;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailAciton:)];
        [_detailView addGestureRecognizer:tap];
        
    }else {
        [UIView transitionWithView:topMenu duration:0.33 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _detailView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [_detailView removeFromSuperview];
            _detailView = nil;
        }];
    }
}

- (void)menuViewAdd2Bookshelf:(JATopMenuView *)topMenu {
    if ([MSUserModel sharedUser].state == MSLoginStateNone) {
        NSMutableArray *bookshelfM = [NSMutableArray arrayWithArray:[MSUserModel sharedUser].bookshelf];
        __block BOOL isInShelf = false;
        [[MSUserModel sharedUser].bookshelf enumerateObjectsUsingBlock:^(MSBookModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj bookid] isEqualToString:self.book.bookid]) {
                isInShelf = true;
                *stop = true;
            }
        }];
        if (isInShelf == false) {
            [bookshelfM addObject:self.book];
            [MSUserModel sharedUser].bookshelf = [bookshelfM copy];
            [self.dbMg updateTableWithObject:[MSUserModel sharedUser]];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
            hud.label.text = @"添加成功";
            [hud showAnimated:true];
            [hud hideAnimated:true afterDelay:kDelayTime];
            // [[NSNotificationCenter defaultCenter] postNotificationName:kIsInShelfNotification object:nil];
        }else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
            hud.label.text = @"已在书架";
            [hud showAnimated:true];
            [hud hideAnimated:true afterDelay:kDelayTime];
        }
        return;
    }else {
        NSString *url = [NSString stringWithFormat:@"shelf?api-token=%@",[MSUserModel sharedUser].api_token];
        NSDictionary *params = @{@"bid":self.book.bookid};
        [[MSHTTPSessionManager manager] POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
                hud.label.text = responseObject;
                [hud showAnimated:true];
                [hud hideAnimated:true afterDelay:kDelayTime];
            }
    
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }
    //    if ([MSUserModel sharedUser].state == MSLoginStateNone) {
    //        // self.mainBookModel
    //
    //        MSUserModel *u = [self.dbMg selectObject:[MSUserModel class] withValue:@"0"];
    //        NSMutableArray *bookshelfM = [NSMutableArray array];
    //        for (int i = 0; i < u.bookshelf.count; ++i) {
    //            [bookshelfM addObject:u.bookshelf[i]];
    //        }
    //        [bookshelfM addObject:self.mainBookModel];
    //        u.bookshelf = [bookshelfM copy];
    //        [self.dbMg updateTableWithObject:u];
    //        return;
    //    }
    //    NSString *url = [NSString stringWithFormat:@"http://api.xyreader.com/shelf?api-token=%@",[MSUserModel sharedUser].api_token];
    //    NSDictionary *params = @{@"bid":[[(JAViewController *)self.cctrl context] objectForKey:@"bookid"]};
    //    [[MSHTTPSessionManager manager] POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    //        if (responseObject) {
    //            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    //            hud.label.text = responseObject;
    //            [hud showAnimated:true];
    //            [hud hideAnimated:true afterDelay:kDelayTime];
    //        }
    //
    //
    //    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    //        
    //    }];
}

- (void)showDetailAciton:(UIBarButtonItem *)sender {
    MSBookDescViewController *bookVC = [[MSBookDescViewController alloc] init];
    bookVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]  style:UIBarButtonItemStyleDone target:self action:@selector(menuViewBack:)];
    JANavigationController *navC = [[JANavigationController alloc] initWithRootViewController:bookVC];
    [bookVC.context setObject:self.book.bookid forKey:@"bookid"];
    [bookVC.context setObject:@(1) forKey:@"isReading"];
    
    [self presentViewController:navC animated:true completion:NULL];
}

- (void)menuViewBack:(JATopMenuView *)topMenu {
    [self dismissViewControllerAnimated:true completion:^{
        UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
        statusBar.alpha = 1.0f;
        // [self preferredStatusBarStyle];
        // NSLog(@"%@",[statusBar valueForKey:@"styleDelegate"]);
        // NSLog(@"%@",[statusBar valueForKey:@"statusBarWindow"]);
        [statusBar setValue:HexRGB(0x000000) forKey:@"foregroundColor"];
    }];
    
    // 更新记录
    // 通过back退出界面
    [self updateRecordAction:nil];
}

- (void)menuViewChangeMode:(JATopMenuView *)topMenu sender:(UIButton *)sender {
    JAReaderThemeType themeType = [JAReaderConfig defaultConfig].theme;
    if (themeType == JAReaderThemeTypeNormal) {
        [JAReaderConfig defaultConfig].theme = JAReaderThemeTypeNight;
    }else if (themeType == JAReaderThemeTypeNight){
       [JAReaderConfig defaultConfig].theme = JAReaderThemeTypeNormal;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MSReaderChangeThemeNotification
                                                        object:nil];
}

- (void)menuViewComment:(JABottomMenuView *)bottomMenu {
    MSCommentViewController *vc = [[MSCommentViewController alloc] init];
    [vc.context setObject:self.book.bookid forKey:@"bid"];
    JANavigationController *navC = [[JANavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navC animated:true completion:NULL];
}

- (void)menuViewFontSize:(JABottomMenuView *)bottomMenu {
    
    [self.chapter updateFont];
    JAReaderViewController *vc = _currentReaderViewController ? _currentReaderViewController : _readerViewController;
    [_pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:NULL];
    
    [self setPageContentWithPageViewController:vc
                                       chapter:_chapter
                                        record:_recordModel
                                      position:-1];
}

- (void)menuViewInvokeCatalog:(JABottomMenuView *)bottomMenu {
    [(JAMenuView *)[bottomMenu superview] hiddenAnimation:false];
    [self catalogShowState:true];
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
//    NSLog(@"%s",__func__);
    _pageIsAnimating = true;
    
    if(self.isAfter) {
        _progress = ((CGFloat)(self.curPage+1) / self.chapter.pages.count / self.catalogVC.component.cmodels.count + [[_chapter num] doubleValue]) / [self.catalogVC.component.cmodels count];
        
    }
    
    if (self.isBefore) {
        _progress = ((CGFloat)(self.curPage-1) / self.chapter.pages.count / self.catalogVC.component.cmodels.count + [[_chapter num] doubleValue]) / [self.catalogVC.component.cmodels count];
        
    }
    
    if (self.isAfterChapter) {
        _progress = [_chapter.num doubleValue] / [self.catalogVC.component.cmodels count];
    }
    
    if (self.isBeforeChapter) {
        _progress = [_chapter.num doubleValue] / [self.catalogVC.component.cmodels count];
    }
    _currentReaderViewController.progress = _progress;
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.pageViewController.doubleSided = YES;
    return UIPageViewControllerSpineLocationMin;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
//    NSLog(@"%s",__func__);
    
    /// 完成了翻页操作
    /// 太快会认为是两次,这个下次优化
    if (completed) {
        if(self.isAfter) {
            self.curPage++;
            // _progress = ((CGFloat)self.curPage / self.chapter.pages.count / self.catalogVC.component.cmodels.count + [[_chapter num] doubleValue]) / [self.catalogVC.component.cmodels count];
            
        }
        
        if (self.isBefore) {
            self.curPage--;
            // _progress = ((CGFloat)self.curPage / self.chapter.pages.count / self.catalogVC.component.cmodels.count + [[_chapter num] doubleValue]) / [self.catalogVC.component.cmodels count];
                        
        }
        
        if (self.isAfterChapter) {
            self.curPage = 0;
            // _progress = [_chapter.num doubleValue] / [self.catalogVC.component.cmodels count];
            for (int i = 0; i < self.catalogVC.component.cmodels.count; ++i) {
                if([self.catalogVC.component.cmodels[i] cState] == MSCharterStateReading) {
                    _chapter.cState = MSCharterStateDownloaded;
                    [self.catalogVC.component.cmodels[i] setCState:MSCharterStateDownloaded];
                }
                if ([[self.catalogVC.component.cmodels[i] num].stringValue isEqualToString:_recordModel.num]) {
                    _chapter.cState = MSCharterStateReading;
                    [self.catalogVC.component.cmodels[i] setCState:MSCharterStateReading];
                    self.catalogVC.component.readChapterNum = _recordModel.num;
                }
            }
            self.catalogVC.shouldReload = true;
        }
        
        if (self.isBeforeChapter) {
            self.curPage = _chapter.pages.count - 1;
            // _progress = [_chapter.num doubleValue] / [self.catalogVC.component.cmodels count];
            for (int i = 0; i < self.catalogVC.component.cmodels.count; ++i) {
                if([self.catalogVC.component.cmodels[i] cState] == MSCharterStateReading) {
                    _chapter.cState = MSCharterStateDownloaded;
                    [self.catalogVC.component.cmodels[i] setCState:MSCharterStateDownloaded];
                }
                if ([[self.catalogVC.component.cmodels[i] num].stringValue isEqualToString:_recordModel.num]) {
                    _chapter.cState = MSCharterStateReading;
                    [self.catalogVC.component.cmodels[i] setCState:MSCharterStateReading];
                    self.catalogVC.component.readChapterNum = _recordModel.num;
                }
            }
            self.catalogVC.shouldReload = true;
        }
        [self.menuView.bottomView.slider setValue:_progress animated:true];
        // _currentReaderViewController.progress = _progress;
    }
    
    if (completed || finished) {   // Turn is either finished or aborted
        _pageIsAnimating = false;
    }
}

#pragma mark -  UIGestureRecognizer Delegate

// 解决TabView与Tap手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    // || [touch.view isKindOfClass:[UISlider class]]
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [touch.view isKindOfClass:[MSChapterListView class]]) {
        return false;
    }
    return  true;
}

#pragma mark -
#pragma mark lazyLoad

- (JAMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[JAMenuView alloc] initWithFrame:self.view.frame];
        _menuView.hidden = true;
        _menuView.topView.bookModel = self.book;
        _menuView.delegate = self;
        _menuView.topView.delegate = self;
        _menuView.bottomView.delegate = self;
    }
    return _menuView;
}

- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        
        if (_pageViewController.transitionStyle == UIPageViewControllerTransitionStylePageCurl) {
            _pageViewController.doubleSided = true;
        }
        
        [self.view addSubview:_pageViewController.view];
    }
    return _pageViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        return UIStatusBarStyleDefault;
    }else {
        return UIStatusBarStyleLightContent;
    }
//    return UIStatusBarStyleDefault;
}
- (MSHTTPSessionManager *)ChapterMg {
    if (!_ChapterMg) {
        _ChapterMg = [MSHTTPSessionManager manager];
        _ChapterMg.operationQueue.maxConcurrentOperationCount = 3;
    }
    return _ChapterMg;
}

- (JACatalogViewController *)catalogVC {
    if (!_catalogVC) {
        _catalogVC = [[JACatalogViewController alloc] init];
        _catalogVC.delegate = self;
        if (self.book) {
            [_catalogVC.context setObject:self.book forKey:@"book"];
        }
    }
    return _catalogVC;
}

- (UIView *)catalogView {
    if (!_catalogView) {
        _catalogView = [[UIView alloc] init];
        _catalogView.backgroundColor = [UIColor clearColor];
        _catalogView.hidden = YES;
        [_catalogView addGestureRecognizer:({
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenCatalog)];
            tap.delegate = self;
            tap;
        })];
    }
    return _catalogView;
}

@end
