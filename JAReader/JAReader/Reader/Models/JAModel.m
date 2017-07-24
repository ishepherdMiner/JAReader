//
//  JAModel.m
//  Summary
//
//  Created by Jason on 09/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAModel.h"

@implementation JAModel

+ (NSArray *)blackList {
    return @[@"superclass",@"debugDescription",@"hash",@"description"];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
#if DEBUG
    NSLog(@"[JA]:%@ %@ 赋值 %@ 报错! 原因:未找到key",[self class],key,value);
#endif
}

@end
