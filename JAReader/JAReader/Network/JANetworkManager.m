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

@interface JANetworkManager ()

@property (nonatomic,strong) id<JANetworkDelegate> task;
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
    
    [self.task GET:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)POST:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [self.task POST:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
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

- (void)dismiss {
    [self.hub dismiss];
}

@end
