//
//  MSUserModel.m
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "MSUserModel.h"

@interface MSProfileModel ()

@property (nonatomic,strong) NSMutableDictionary *records;

@end
@implementation MSProfileModel

+ (NSString *)pK {
    return @"profileid";
}

@end

@implementation MSUserModel

+ (NSString *)pK {
    return @"userid";
}

+ (instancetype)sharedUser{
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
    });
    
    return instance;
}

@end
