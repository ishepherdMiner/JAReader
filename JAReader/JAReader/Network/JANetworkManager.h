//
//  JANetworkManager.h
//  RssMoney
//
//  Created by Jason on 11/04/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JANetworkProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,JANetworkManagerStyle) {
    JANetworkMgStyleDefault  // 默认是 AFN + MBProgress
};

@interface JANetworkManager : NSObject <JANetworkProtocol,JANetworkHudDelegate>

@property (nonatomic,strong,readonly) id<JANetworkProtocol> task;
@property (nonatomic,strong,readonly) id<JANetworkHudDelegate> hub;

@property (nonatomic, copy) void (^commonSuccess)(NSURLSessionDataTask *task, id responseObject);
@property (nonatomic, copy) void (^commonFailure)(NSURLSessionDataTask *task, NSError *error);

+ (instancetype)manager;
+ (instancetype)managerWithStyle:(JANetworkManagerStyle)style;

@end

NS_ASSUME_NONNULL_END
