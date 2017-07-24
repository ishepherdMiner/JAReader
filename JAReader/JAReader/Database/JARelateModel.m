//
//  JARelateModel.m
//  MStarReader
//
//  Created by Jason on 20/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JARelateModel.h"

@implementation JARelateModel

+ (NSString *)pK {
    return @"rid";
}

+ (BOOL)supportAutoIncrement {
    return true;
}
@end
