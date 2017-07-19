//
//  JADBTable.h
//  MStarReader
//
//  Created by Jason on 18/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAModel.h"

NS_ASSUME_NONNULL_BEGIN
@class FMDatabaseQueue;

/// 基本数据类型 NSNumber 包装
/// 字符串 NSString
/// 数组:
///     元素是基础类型遍历数组用','拼接成字符串
///     元素是对象遍历数组用','将元素的id拼接成字符串
/// 字典:
///     参考数组进行同样操作 `k1:v1,k2:v2`
/// 模型:
///     是否已存在该模型的表,如果不存在,则创建,并保存模型的主键id
@interface JADBTable : JAModel

@property (nonatomic,copy,readonly) NSString *tableName;
@property (nonatomic,strong) Class tableClass;

@property (nonatomic, strong) NSArray *subTableNames;


- (instancetype)initWithTableName:(NSString *)tableName
                       tableClass:(id)tableClass;

- (void)insertWithModel:(JAModel *)model;
- (void)insertWithModel:(JAModel *)model name:(NSString *)tableName;

- (void)deleteWithValue:(id)value;
- (void)deleteWithValue:(id)value
                  field:(NSString *)field
           relationship:(NSString *)rs;
- (void)deleteAll;

- (void)updateWithModel:(JAModel *)model;
- (void)updateWithModel:(JAModel *)model fields:(NSArray *)fields;

- (id)selectWithValue:(id)value tableClass:(id)tableClass;
- (NSArray<JAModel *> *)selectAllWithTableClass:(id)tableClass name:(NSString *)name;

// 没实现
#warning v0.1.2
// - (NSArray <JAModel *> *)selectAll;

- (void)executeUpateWithSql:(NSString *)sql
                      okLog:(NSString *)okLog
                    failLog:(NSString *)failLog
                    success:(nullable void (^)())successBlock;


@end

NS_ASSUME_NONNULL_END
