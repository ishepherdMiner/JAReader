//
//  MSBookModel.m
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "MSBookModel.h"

@implementation MSBookModel

+ (NSString *)pK {
    return @"bookid";
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"bookid":@"id"};
}

- (NSString *)viewControllerTitle {
    return self.bookname;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
