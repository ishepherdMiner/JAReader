//
//  JANetworkManager.m
//  RssMoney
//
//  Created by Jason on 11/04/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JANetworkManager.h"
#import "JANetworkAFTask.h"
#import "JANetworkMBHud.h"
#import <MBProgressHUD.h>

@interface JANetworkManager ()

@property (nonatomic,strong) id<JANetworkProtocol> task;
@property (nonatomic,strong) id<JANetworkHudDelegate> hub;

@end

@implementation JANetworkManager

+ (instancetype)manager {
    return [self managerWithStyle:JANetworkMgStyleDefault];
}

+ (instancetype)managerWithStyle:(JANetworkManagerStyle)style {
    
    JANetworkManager *mg = [[self alloc] init];
    
    switch (style) {
        case JANetworkMgStyleDefault:
            
            mg.task = [[JANetworkAFTask alloc] init];
            mg.hub = [[JANetworkMBHud alloc] init];
            
            break;
            
        default:
            break;
    }
    return mg;
}

- (void)GET:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
    
    [self.task GET:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication].delegate window] animated:true];
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)GET:(NSString *)URLString
 parameters:(id)parameters
   progress:(void (^)(NSProgress *progress))downloadProgress
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    
    // [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
    
    [self.task GET:URLString parameters:parameters progress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (void)POST:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [self.task POST:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    } isUpload:false];
}

- (void)PUT:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [self.task PUT:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];

}

- (void)DELETE:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [self.task DELETE:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)showInView:(UIView *)view {
    [self.hub showInView:view];
}

- (void)hide {
    [self.hub hide];
}

@end
