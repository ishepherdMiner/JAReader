//
//  JAPageView.h
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@protocol JAReadViewControllerDelegate;

/// 单页
@interface JAReaderView : UIView

@property (nonatomic,assign) CTFrameRef frameRef;

/// 页面内容
@property (nonatomic,copy) NSString *content;

@property (nonatomic,strong) id<JAReadViewControllerDelegate>delegate;

- (void)cancelSelected;

@end
