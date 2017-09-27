//
//  MSHTTPSessionManager.h
//  MStarReader
//
//  Created by Jason on 10/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAHTTPSessionManager.h"

@interface MSHTTPSessionManager : JAHTTPSessionManager

+ (instancetype)downLoadManager;

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress *))downloadProgress
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
                     isLoaded:(BOOL)isLoaded;
@end
