//
//  MSRecordModel.m
//  JAReader
//
//  Created by Jason on 29/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "MSRecordModel.h"

@implementation MSRecordModel

+ (instancetype)recordWithBookId:(NSNumber *)bookId {
    MSRecordModel *model = [[MSRecordModel alloc] init];
    
    // 从数据库中以bookId查找记录表
    model.bookId = @1;
    model.charterid = @1;
    model.page = @"0";
    
    // 想到一个问题
    // 比如下面这个场景:
    // 一开始用的是11号字体,记录看到第15页
    // 后面修改了,用15号字体,记录要怎么更新呢??
    
    // 修改字体时,重新分页,通过已读内容长度那个字段,得到当前应该在该章的第几页,刷新模型
    // 每次翻页都要处理好已读内容长度
    
    return model;
}
@end
