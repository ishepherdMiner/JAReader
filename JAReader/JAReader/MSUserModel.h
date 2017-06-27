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

/// 个人信息
@interface MSProfileModel : JAModel 

@property (nonatomic, strong) NSNumber *profileid;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *wechat;

@end

typedef NS_ENUM(NSUInteger,MSLoginState) {
    MSLoginStateNone,                      // 未登录
    MSLoginStateLogin,                     // 登陆
    MSLoginStateLogout = MSLoginStateNone, // 登出
};

@interface MSUserModel : JAModel

@property (nonatomic,strong) NSNumber *userid;

@property (nonatomic,assign) MSLoginState state;

/// 我的信息
@property (nonatomic,strong) MSProfileModel *profile;

@property (nonatomic, copy) NSString *test;

/// 我的书架
@property (nonatomic,strong) NSArray <MSBookModel *> *bookshelf;

+ (instancetype)sharedUser;

@end

NS_ASSUME_NONNULL_END
