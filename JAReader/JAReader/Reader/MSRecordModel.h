//
//  MSRecordModel.h
//  JAReader
//
//  Created by Jason on 29/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAModel.h"

/// 阅读记录
@interface MSRecordModel : JAModel

@property (nonatomic,strong) NSNumber *recordId;

/// 找到具体是哪本书 获取书的一些信息,比如总页数等
@property (nonatomic,strong) NSNumber *bookId;

/// 当前阅读的章节
@property (nonatomic,strong) NSNumber *charterid;

/// 当前阅读的在第几页 推出当前用户对这本书阅读状态
@property (nonatomic,copy) NSString *page;

/// 已读的内容长度
@property (nonatomic, copy) NSString *length;

+ (instancetype)recordWithBookId:(NSNumber *)bookId;

@end
