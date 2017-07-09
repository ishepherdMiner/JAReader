//
//  JANetworkManager.h
//  RssMoney
//
//  Created by Jason on 11/04/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JANetworkProtocol <NSObject>

@required

// 查
- (void)GET:(NSString *)urlString
 parameters:(id)parameters
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success;

- (void)GET:(NSString *)urlString
 parameters:(id)parameters
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)GET:(NSString *)URLString
 parameters:(id)parameters
   progress:(void (^)(NSProgress *progress))downloadProgress
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

// 增
- (void)POST:(NSString *)urlString
  parameters:(id)parameters
     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
    isUpload:(BOOL)isUpload;

@optional

// 改
- (void)PUT:(NSString *)urlString
 parameters:(id)parameters
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

// 删
- (void)DELETE:(NSString *)urlString
    parameters:(id)parameters
       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end

@protocol JANetworkHudDelegate <NSObject>

@required

/// 展示
- (void)showInView:(UIView *)view;

/// 消失
- (void)hide;

@end

NS_ASSUME_NONNULL_END
