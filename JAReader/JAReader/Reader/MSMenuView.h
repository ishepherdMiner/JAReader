//
//  MSMenuView.h
//  JAReader
//
//  Created by Jason on 11/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSRecordModel.h"

@class MSMenuView;
@protocol MSMenuViewDelegate <NSObject>

@optional
- (void)menuViewDidHidden:(MSMenuView *)menu;
- (void)menuViewDidAppear:(MSMenuView *)menu;
// - (void)menuViewInvokeCatalog:
- (void)menuViewJumpChapter:(NSUInteger)chapter page:(NSUInteger)page;
// - (void)menuViewFontSize:()


@end

@interface MSMenuView : UIView

@property (nonatomic,weak) id<MSMenuViewDelegate> delegate;
@property (nonatomic,strong) MSRecordModel *recordModel;


@end
