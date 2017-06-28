//
//  MSNetworkManager.h
//  MStarReader
//
//  Created by Jason on 22/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JANetworkManager.h"

@interface MSNetworkManager : JANetworkManager

- (void)GET:(NSString *)urlString
 parameters:(id)parameters
    success:(void (^)(NSURLSessionDataTask *task, id response))success;

@end
