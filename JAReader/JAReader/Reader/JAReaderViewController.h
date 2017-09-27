//
//  JAReaderViewController.h
//  MStarReader
//
//  Created by Jason on 22/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAViewController.h"
#import "JAReaderView.h"

@class MSChapterModel,JAReaderViewController;


@protocol JAReadViewControllerDelegate <NSObject>

- (void)readViewEditeding:(JAReaderViewController *)readView;
- (void)readViewEndEdit:(JAReaderViewController *)readView;

@end

/**
 * 单页视图控制器
 * 管理 JAReaderView对象
 */
@interface JAReaderViewController : JAViewController

/// 内容
@property (nonatomic,copy) NSString *content;

/// 标题
@property (nonatomic,copy) NSString *chapterTitle;

@property (nonatomic,assign) float progress;
@property (nonatomic,strong) UILabel *progressLabel;

@property (nonatomic,weak) MSChapterModel *chapter;

@property (nonatomic, strong) JAReaderView *readerView;

@property (nonatomic,weak) id<JAReadViewControllerDelegate> delegate;

@end
