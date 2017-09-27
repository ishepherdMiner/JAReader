//
//  JAMenuView.h
//  MStarReader
//
//  Created by Jason on 26/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JATopMenuView.h"
#import "JABottomMenuView.h"

@class JAMenuView;

@protocol JAMenuViewDelegate <NSObject>

@optional
- (void)menuViewDidHidden:(JAMenuView *)menuView;
- (void)menuViewDidAppear:(JAMenuView *)menuView;

@end

@interface JAMenuView : UIView

@property (nonatomic, weak) id<JAMenuViewDelegate> delegate;

@property (nonatomic,strong) JATopMenuView *topView;
@property (nonatomic,strong) JABottomMenuView *bottomView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,copy) NSString *titleLabelString;

- (void)showAnimation:(BOOL)animation;
- (void)hiddenAnimation:(BOOL)animation;

@end
