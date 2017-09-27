//
//  JATopMenuView.h
//  MStarReader
//
//  Created by Jason on 26/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JATopMenuView,JAMenuView,MSBookModel;

@protocol JATopMenuViewDelegate <NSObject>

@optional

/// 改变主题
- (void)menuViewChangeMode:(JATopMenuView *)topMenu sender:(UIButton *)sender;

/// 显示书籍详情
- (void)menuViewShowMore:(JATopMenuView *)topMenu;

/// 返回按钮
- (void)menuViewBack:(JATopMenuView *)topMenu;

- (void)menuViewAdd2Bookshelf:(JATopMenuView *)topMenu;

@end

@interface JATopMenuView : UIView

@property (nonatomic,weak) id<JATopMenuViewDelegate> delegate;
@property (nonatomic,weak) JAMenuView *menuView;

@property (nonatomic,strong) UILabel *titleLabel;

/// 接收JAReaderPageViewController中的bookModel;
@property (nonatomic,weak) MSBookModel *bookModel;

@end
