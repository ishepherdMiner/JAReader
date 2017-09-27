//
//  JAReaderPageViewController.h
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAViewController.h"

@class MSBookModel,MSChapterModel;

/**
 * 分页视图控制器
 * 
 * 负责展示书籍内容 
 */
@interface JAReaderPageViewController : JAViewController

/// 书
@property (nonatomic,strong) MSBookModel *book;

/// 章节
@property (nonatomic,strong) MSChapterModel *chapter;

@property (nonatomic,assign) BOOL isDetail;
@property (nonatomic,assign) BOOL isLoadSuccess;
- (void)loadReader;

@end

/// 阅读器内容加载完成通知
UIKIT_EXTERN NSNotificationName MSReaderLoadedNotification;

UIKIT_EXTERN NSNotificationName MSReaderShelfLoadedNotification;

/// 改变主题通知
UIKIT_EXTERN NSNotificationName MSReaderChangeThemeNotification;

UIKIT_EXTERN NSNotificationName MSReaderDownloadedNotification;
