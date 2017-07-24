//
//  MSUserModel.h
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MSBookModel;

/// 个人信息 添加一个主键,赋值为 MSUserModel的id
@interface MSProfileModel : JAModel

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *openid;

@end

typedef NS_ENUM(NSUInteger,MSLoginState) {
    MSLoginStateNone,                      // 未登录
    MSLoginStateLogin,                     // 登陆
    MSLoginStateLogout = MSLoginStateNone, // 登出
};

@interface MSUserModel : JAModel

@property (nonatomic, copy) NSString *id;

@property (nonatomic,assign) MSLoginState state;

/// 用户是否被激活
/// 场景:
/**
 * 一部设备有三种用户类型: 匿名用户 手机用户 微信用户
 * 数据库中的记录可能有多条,用于标识哪个才是当前登陆的用户
 */
@property (nonatomic,assign) BOOL is_active;

/// 登陆会话标识
@property (nonatomic,copy) NSString *api_token;

/// 我的信息
@property (nonatomic,strong) MSProfileModel *profile;

/// 我的书架
@property (nonatomic,strong) NSArray <MSBookModel *> *bookshelf;

+ (instancetype)sharedUser;

- (BOOL)persistence;

- (void)logout;

@end

NS_ASSUME_NONNULL_END
