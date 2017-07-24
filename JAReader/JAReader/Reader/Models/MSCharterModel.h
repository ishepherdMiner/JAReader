//
//  MSCharterModel.h
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAModel.h"
#import <YYModel.h>

typedef NS_ENUM(NSUInteger,MSCharterState){
    MSCharterStateNotDownloaded,  // 未下载
    MSCharterStateDownloading,    // 正在下载
    MSCharterStateDownloaded,     // 已下载
    MSCharterStateReading,        // 正在阅读
    MSCharterStateRead,           // 已读
};

/// 章节
@interface MSCharterModel : JAModel <YYModel>

@property (nonatomic, copy) NSString *charterid;

/// 标题
@property (nonatomic, copy) NSString *charterTitle;
/// 页数
@property (nonatomic, copy) NSString *pageCount;
/// 内容
@property (nonatomic, copy) NSString *content;

/// 所属的书
@property (nonatomic, copy) NSString *bookid;

/// 章节状态
@property (nonatomic, assign) MSCharterState cState;

/// 章节序号
@property (nonatomic, strong) NSNumber *num;

@property (nonatomic,strong) NSMutableArray *pages;

/**
 返回第index页的内容
 
 @param index 第几页
 @return 第index页的内容
 */
- (NSString *)stringOfPage:(NSUInteger)index;

@end
