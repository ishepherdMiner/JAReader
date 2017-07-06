//
//  JAReaderConfig.m
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderConfig.h"


@implementation JAReaderConfig

+ (instancetype)sharedReaderConfig {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.fontSize = 16;
        self.lineSpace = 5;
        self.theme = JAReaderThemeTypeNormal;
        self.themeColor = [UIColor whiteColor];
        self.fontColor = [UIColor blackColor];
    }
    return self;
}
@end
