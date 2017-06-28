//
//  JANetworkHud.h
//  RssMoney
//
//  Created by Jason on 11/04/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JANetworkHudDelegate <NSObject>

@required

/// 展示
- (void)showInView:(UIView *)view;

/// 消失
- (void)dismiss;

@optional

@end

/// 网络请求指示器接口
@interface JANetworkHud : NSObject


@end

NS_ASSUME_NONNULL_END
