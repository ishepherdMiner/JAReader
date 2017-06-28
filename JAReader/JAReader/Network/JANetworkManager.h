//
//  JANetworkManager.h
//  RssMoney
//
//  Created by Jason on 11/04/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JANetworkTask.h"
#import "JANetworkHud.h"

typedef NS_ENUM(NSInteger,JANetworkManagerStyle) {
    JANetworkMgStyleDefault  // 默认是 AFN + MBProgress
};

@interface JANetworkManager : NSObject <JANetworkDelegate,JANetworkHudDelegate>

@property (nonatomic,strong,readonly) id<JANetworkDelegate> task;
@property (nonatomic,strong,readonly) id<JANetworkHudDelegate> hub;

+ (instancetype)manager;
+ (instancetype)managerWithStyle:(JANetworkManagerStyle)style;

@end
