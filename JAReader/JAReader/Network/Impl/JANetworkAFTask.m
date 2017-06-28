//
//  JANetworkAFManager.m
//  RssMoney
//
//  Created by Jason on 11/04/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JANetworkAFTask.h"
#import <AFNetworking.h>

@interface JANetworkAFTask ()  

@property (nonatomic,strong) AFHTTPSessionManager *ssManager;

@end

@implementation JANetworkAFTask

- (instancetype)init {
    if (self = [super init]) {
        self.ssManager = [AFHTTPSessionManager manager];
        self.ssManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    }
    return self;
}

- (void)GET:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    [self.ssManager GET:urlString parameters:parameters progress:^(NSProgress *progress){
        
    }   success:success failure:failure];
}

- (void)POST:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    [self.ssManager POST:urlString parameters:parameters progress:nil success:success failure:failure];
}

- (void)PUT:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    [self.ssManager PUT:urlString parameters:parameters success:success failure:failure];
}

- (void)DELETE:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    [self.ssManager DELETE:urlString parameters:parameters success:success failure:failure];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
