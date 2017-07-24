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

/// 主键
+ (NSString *)pK;

@optional

/// 外键 @{ @"属性":@[@"关联表名",@"关联属性名"]}
+ (NSDictionary *)fKs;

/// 唯一键
+ (NSArray *)uKs;

/// 黑白名单
+ (NSArray *)whiteList;
+ (NSArray *)blackList;

/// 主键支持自增长
+ (BOOL)supportAutoIncrement;

@end

@interface JAModel : NSObject <JAModelDBDelegate>

@end

NS_ASSUME_NONNULL_END
