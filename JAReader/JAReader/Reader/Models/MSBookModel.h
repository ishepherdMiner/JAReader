//
//  MSBookModel.h
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <YYModel.h>
#import "JAModel.h"

@class MSCharterModel;

@interface MSBookModel : JAModel <YYModel>

@property (nonatomic, copy) NSString *bookid;

/// 书名
@property (nonatomic, copy) NSString *bookname;
/// 简介
@property (nonatomic, copy) NSString *info;
/// 作者
@property (nonatomic, copy) NSString *auth;
/// 封面
@property (nonatomic, copy) NSString *icon;
/// 分类id
@property (nonatomic, copy) NSString *cat_id;
/// 分类名称
@property (nonatomic, copy) NSString *category;
/// 推荐量
@property (nonatomic, copy) NSString *pubNum;
/// 点击量
@property (nonatomic, copy) NSString *clickNum;
/// 阅读量
@property (nonatomic, copy) NSString *readNum;
/// 收藏量
@property (nonatomic, copy) NSString *collectNum;
/// 评论量
@property (nonatomic, copy) NSString *commentNum;
/// 平均星级
@property (nonatomic, copy) NSString *avg_star;
/// 是否连载：0-连载 1-完本
@property (nonatomic, copy) NSString *isover;
/// 创建时间
@property (nonatomic, copy) NSString *created_at;
/// 更新时间
@property (nonatomic, copy) NSString *last_update;
/// 章节信息
@property (nonatomic, strong) NSArray<MSCharterModel *> *charters;

/// 首页接口: 最新章节名
@property (nonatomic, copy) NSString *title;
/// 最新章节
@property (nonatomic, copy) NSString *num;

/// 小说详情页接口是这个
/// 最新章节 -
@property (nonatomic, strong) NSDictionary *lastChapter;

/// 阅读状态 (绑定用户)
@property (nonatomic, strong) NSNumber *rate;
@end
