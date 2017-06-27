//
//  JAModel.h
//  Summary
//
//  Created by Jason on 09/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JAModelDBDelegate <NSObject>

@optional

/// 主键
+ (NSString *)pK;

/// 外键
+ (NSArray *)fKs;

/// 唯一键
+ (NSArray *)uKs;

@end

@interface JAModel : NSObject <JAModelDBDelegate>


@end

NS_ASSUME_NONNULL_END
