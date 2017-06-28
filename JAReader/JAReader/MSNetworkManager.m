//
//  MSNetworkManager.m
//  MStarReader
//
//  Created by Jason on 22/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "MSNetworkManager.h"

@implementation MSNetworkManager

- (void)GET:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [self.task GET:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (responseObject) {
            if ([[responseObject objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                success(task,[responseObject objectForKey:@"data"]);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success {
    [self GET:urlString parameters:parameters success:success failure:NULL];
}
@end
