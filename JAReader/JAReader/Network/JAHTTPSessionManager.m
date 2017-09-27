//
//  JAHTTPSessionManager.m
//  MStarReader
//
//  Created by Jason on 10/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAHTTPSessionManager.h"

@implementation JAHTTPSessionManager

- (instancetype)init {
    if (self = [super init]) {
        self = [JAHTTPSessionManager manager];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
        self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return self;
}

@end
