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

typedef NS_ENUM(NSUInteger,JADBOperator){
    // 比较运算符
    JADBOperatorComparisonEqual,
    // 算术运算符
    // JADBOpeartorArithmeticPlus,
    // 逻辑运算符
    JADBOperatorLogicalBetween,
    JADBOperatorLogicalIn,
    // 位运算符
    // JADBOperatorBitwise,
    // 不操作,即select * from table;
    JADBOperatorNone,
};

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

@property (nonatomic, strong) NSArray *secondaryTableNames;


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

- (id)selectWithValue:(id)value;
- (id)selectWithValue:(id)value operator:(JADBOperator)operation;
- (id)selectWithValue:(id)value operator:(JADBOperator)operation field:(NSString *)field ;

- (NSArray<JAModel *> *)selectAll;


- (void)executeUpateWithSql:(NSString *)sql
                      okLog:(NSString *)okLog
                    failLog:(NSString *)failLog
                    success:(nullable void (^)())successBlock;


/**
 *  同步关联表
 *  为了能在查询时,将原来保存在关联表中的信息取出,然后为属性赋值
 *  创建表时,集合对象无法知道元素的类型
 *  因此统一在添加时,用对象属性保存关联属性,并进行数据库添加操作
 *  但数据库是持久化的东西,当添加过一次后,下次再次操作,不一定会执行添加操作
 *
 *  场景:
 *    一开始没有用户时,如果登陆会进行添加操作,但下次再次进入时,因为已经有记录了,按理不会进行添加操作
 *    这会造成再次进入时,内存中的关联表是失效了,比如从数据库中获取记录,因为FMDB有事务,或者说数据库要考虑
 *    多线程,因此在查询中再执行查询,就会崩溃。
 *  
 *  目前只想到这个方法:在查找前执行该方法,用于同步关联表数据库
 *  幸好持久化的地方还是比较集中的,只要把用户管理好即可。
 */
#warning 0.1.3
- (void)syncRelationTable;

@end

NS_ASSUME_NONNULL_END
