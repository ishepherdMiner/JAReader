//
//  MSCharterModel.h
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 章节
@interface MSCharterModel : JAModel

/// [主键]
@property (nonatomic, strong) NSNumber *charterid;

/// 标题
@property (nonatomic, copy) NSString *charterTitle;

/// 页数
@property (nonatomic, copy) NSString *pageCount;
/// 内容
@property (nonatomic, copy) NSString *content;

@property (nonatomic,strong) NSMutableArray *pages;

/**
 返回第index页的内容

 @param index 第几页
 @return 第index页的内容
 */
- (NSString *)stringOfPage:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
