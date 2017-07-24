//
//  JADBTable.m
//  MStarReader
//
//  Created by Jason on 18/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JADBTable.h"
#import <objc/message.h>
#import <FMDB.h>
#import "JACategory.h"
#import "JADBManager.h"
#import "JARelateModel.h"

typedef NS_ENUM(NSUInteger,JADBTableType) {
    JADBTableTypeString,
    JADBTableTypeNumber,
    JADBTableTypeInteger,
    JADBTableTypeModel,
    JADBTableTypeArray,
    JADBTableTypeDictionary,
};

@interface JADBTable ()

@property (nonatomic,copy) NSString *tableName;
@property (nonatomic,strong) FMDatabaseQueue *dbQueue;

/// 包含的从属表的映射关系: 属性名 => 表名
@property (nonatomic,strong) NSMutableDictionary *relationship;


@property (nonatomic,assign,getter=isResultSet) BOOL resultSet;

@end

@implementation JADBTable

- (instancetype)initWithTableName:(NSString *)tableName
                       tableClass:(id)tableClass {
    
    NSParameterAssert(tableName);
    NSParameterAssert(tableClass);
    if (self = [super init]) {
        self.dbQueue = [JADBManager sharedDBManager].dbQueue;
        self.tableName = tableName;
        self.tableClass = tableClass;        
        [self createTableWithClass:tableClass name:tableName];
    }
    return self;
}

- (void)createTableWithClass:(Class)tableClass {
    [self createTableWithClass:tableClass name:NSStringFromClass(tableClass)];
}

- (void)createTableWithClass:(Class)tableClass name:(NSString *)tableName{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",tableName];
    NSDictionary *fieldsTypePair = [[[tableClass alloc] init] ja_propertyAndEncodeTypeList:false];
    fieldsTypePair = [self filterWithDictionay:fieldsTypePair modelClass:tableClass];
    NSArray *allKeys = fieldsTypePair.allKeys;
    for (int i = 0; i < allKeys.count; ++i) {
        NSString *key = allKeys[i];
        
        [sql appendString:key];
        
        if ([tableClass respondsToSelector:@selector(pK)] && [[tableClass pK] isEqualToString:key]) {
            // 主键
            if ([tableClass respondsToSelector:@selector(supportAutoIncrement)] && [tableClass supportAutoIncrement]) {
                // 自增长
                [sql appendString:@" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
            }else {
                [sql appendString:@" INTEGER PRIMARY KEY NOT NULL,"];
            }
        }else if([tableClass respondsToSelector:@selector(fKs)] && [[tableClass fKs] objectForKey:key]) {
            // 外键
            NSArray *fkTable = [[tableClass fKs] objectForKey:key];
            NSString *fksql = [NSString stringWithFormat:@" FOREIGN KEY (%@) REFERENCES %@ (%@),",key,fkTable.firstObject,fkTable.lastObject];
            [sql appendString:fksql];
        }else {
            JADBTableType type = [self typeWithKey:key fieldsTypePair:fieldsTypePair];
            switch (type) {
                case JADBTableTypeString: {
                    [sql appendString:@" TEXT"];
                }
                    break;
                case JADBTableTypeNumber:
                case JADBTableTypeInteger: {
                    [sql appendString:@" INTEGER"];
                }
                    break;
                    /*
                     * 数组元素 ∈ 基本类型 v0.1.1
                     *  元素1;元素2.... 以`;`分割存储
                     *
                     * 数组元素 ∈ 集合类型 v0.1.1
                     *  集合1.元素1;集合1.元素2...;集合2.元素1,集合2.元素2...
                     *
                     * 数组元素 ∈ 模型对象 [目前只做了这种]
                     *  模型对象1主键;模型对象2主键...
                     */
                case JADBTableTypeArray:
                    /**
                     * 关注v即可
                     * v ∈ 基本类型
                     *  k1:v1;k2:v2...
                     * v ∈ 集合
                     *  k1:v.a,v.b...;k2:v.a,v.b;...
                     * v ∈ 模型对象
                     *  v.id;v2.id;...
                     */
                case JADBTableTypeDictionary:
                    /*
                     * 存储模型的主键
                     * 在select时,根据主键查表,创建模型,进行赋值
                     */
                case JADBTableTypeModel: {
                    [sql appendString:@" TEXT"];
                }
                    break;
                default:
                    break;
            }
            
            if (i != (allKeys.count - 1)) {
                [sql appendString:@","];
            }
        }
    }
    [sql appendString:@")"];
    [self executeUpateWithSql:sql okLog:@"表创建成功" failLog:@"表创建失败" success:NULL];
}

#pragma mark - 
#pragma mark insert
- (void)insertWithModel:(JAModel *)model name:(NSString *)tableName {
    NSString *errLog = [NSString stringWithFormat:@"model对象 %@ 必须实现+pK方法",model];
    NSAssert([[model class] respondsToSelector:@selector(pK)], errLog);
    
    // 如果该已存在则不添加
    if ([[model class] pK]) {
        JAModel * m = [self selectWithValue:[model valueForKey:[[model class] pK]] operator:JADBOperatorComparisonEqual field:[[model class] pK] tableClass:[model class] tableName:tableName];
        if (m) {return;}
    }
    
    NSMutableString *sql = [NSMutableString stringWithString:[NSString stringWithFormat:@"INSERT INTO %@ (",tableName]];
    NSDictionary *fieldsTypePair = [[[model.class alloc] init] ja_propertyAndEncodeTypeList:false];
    fieldsTypePair = [self filterWithDictionay:fieldsTypePair modelClass:[model class]];
    NSArray *allKeys = fieldsTypePair.allKeys;
    
    for (int i = 0; i < allKeys.count; ++i) {
        NSString *key = allKeys[i];
        
        if ([[model class] respondsToSelector:@selector(supportAutoIncrement)] && [[model class] supportAutoIncrement] && [key isEqualToString:[[model class] pK]]) {
            continue;
        }
        
        [sql appendString:key];
        if (i != (allKeys.count - 1)) {
            [sql appendString:@","];
        }
    }
    
    [sql appendString:@") VALUES("];
    
    for (int i = 0; i < allKeys.count; ++i) {
        NSString *key = allKeys[i];
        
        if ([[model class] respondsToSelector:@selector(supportAutoIncrement)] && [[model class] supportAutoIncrement] && [key isEqualToString:[[model class] pK]]) {
            
            continue;
        }
        
        [sql appendString:@"'"];
        
        id value = [model valueForKeyPath:key];
        JADBTableType type = [self typeWithKey:key model:model];
        switch (type) {
            case JADBTableTypeString: {
                [sql appendString:value ? : @""];
            }
                break;
            case JADBTableTypeInteger: {
                [sql appendString:@([value integerValue]).stringValue];
            }
                break;
            case JADBTableTypeNumber: {
                [sql appendString:value ? [value stringValue] : @""];
            }
                break;
            case JADBTableTypeArray: {                
                // NSString *relatedValues = @"";
                // 主表添加id
                for (int i = 0; i < [value count]; ++i) {
                    
                    if ([[value[i] class] isSubclassOfClass:[NSString class]]) {
                        // 字符串数组的处理
                        
                    }else if ([[value[i] class] isSubclassOfClass:[JAModel class]]) {
                        
                        if ([[value[i] class] respondsToSelector:@selector(pK)]) {
                            if ([[value[i] valueForKey:[[value[i] class] pK]] isKindOfClass:[NSNumber class]]) {
                                [sql appendString:[[value[i] valueForKey:[[value[i] class] pK]] stringValue]];
                            }else if ([[value[i] valueForKey:[[value[i] class] pK]] isKindOfClass:[NSString class]]) {
                                [sql appendString:[value[i] valueForKey:[[value[i] class] pK]]];
                            }
                        }
                        if (i != [value count] - 1) {
                            [sql appendString:@";"];
                        }
                        
                        // 创建从表
                        if (i == 0) {
                            if ([[value[i] class] isSubclassOfClass:[JAModel class]]) {
                                [self createTableWithClass:[value[i] class] name:NSStringFromClass([value[i] class])];
                                if (![self.relationship objectForKey:key]) {
                                    [self.relationship setObject:NSStringFromClass([value[i] class]) forKey:key];
                                    
                                }
                            }
                        }
                        
                        // 从表添加记录
                        [self insertWithModel:value[i] name:NSStringFromClass([value[i] class])];

                    }
                }
                
                if ([value count] > 0) {
                    if (![self selectWithValue:key operator:JADBOperatorComparisonEqual field:[[JARelateModel class] pK] tableClass:[JARelateModel class] tableName:@"JARelateModel"]) {
                        JARelateModel *relateModel = [[JARelateModel alloc] init];
                        relateModel.key = key;
                        relateModel.relateTableName = NSStringFromClass([value[0] class]);
                        [self insertWithModel:relateModel];
                    }
                }

            }
                break;
            case JADBTableTypeDictionary:{
                // 暂不处理
                // lastChapter
            }
                break;
            case JADBTableTypeModel: {
                // 主表添加model的主键id
                if ([[value class] respondsToSelector:@selector(pK)]) {
                    if ([[value valueForKey:[[value class] pK]] isKindOfClass:[NSNumber class]]) {
                        [sql appendString:[[value valueForKey:[[value class] pK]] stringValue]];
                    }else if ([[value valueForKey:[[value class] pK]] isKindOfClass:[NSString class]]) {
                        [sql appendString:[value valueForKey:[[value class] pK]]];
                    }
                }
                
                // 检查 & 创建从表
                // 默认表名为属性名
                if ([[[fieldsTypePair objectForKey:key] class] isSubclassOfClass:[JAModel class]]) {
                    [self createTableWithClass:NSClassFromString([fieldsTypePair objectForKey:key]) name:[fieldsTypePair objectForKey:key]];
                    if (![self.relationship objectForKey:key]) {
                        [self.relationship setObject:[fieldsTypePair objectForKey:key] forKey:key];
                    }
                    
                }
                
                // 从表添加model记录
                [self insertWithModel:value name:[fieldsTypePair objectForKey:key]];
                
                // 在关联表中还不存在该记录
                
                // if (![self selectWithValue:key tableClass:[JARelateModel class]]) {
                if (![self selectWithValue:key operator:JADBOperatorComparisonEqual field:[[JARelateModel class] pK] tableClass:[JARelateModel class] tableName:@"JARelateModel"]) {
                    JARelateModel *relateModel = [[JARelateModel alloc] init];
                    relateModel.key = key;
                    relateModel.relateTableName = NSStringFromClass([value class]);
                    [self insertWithModel:relateModel ];
                }
            }
                break;
            default:
                break;
        }
        
        [sql appendString:@"'"];
        if (i != (allKeys.count - 1)) {
            [sql appendString:@","];
        }
    }
    
    [sql appendString:@")"];
    
    [self executeUpateWithSql:sql okLog:@"数据插入成功" failLog:@"数据插入失败" success:NULL];
}

- (void)insertWithModel:(JAModel *)model {
    [self insertWithModel:model name:NSStringFromClass([model class])];
}

#pragma mark -
#pragma mark delete

/// 级联删除
#warning 0.1.2
- (void)deleteWithValue:(id)value {
    [self deleteWithValue:value
                    field:[self.tableClass pK]
             relationship:@"="];
}

- (void)deleteWithValue:(id)value
                  field:(NSString *)field
           relationship:(NSString *)rs {
    
    NSString *sql = [NSString stringWithFormat:@"DELETE  FROM %@ WHERE %@ %@ '%@'",self.tableName,field,rs,value];
    [self executeUpateWithSql:sql okLog:@"数据删除成功" failLog:@"数据删除失败" success:NULL];
}

- (void)deleteAll {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",self.tableName];
    [self executeUpateWithSql:sql okLog:@"数据删除成功" failLog:@"数据删除失败" success:NULL];
}

#pragma mark -
#pragma mark update

- (void)updateWithModel:(JAModel *)model fields:(NSArray *)fields {
    [self updateWithModel:model fields:fields name:self.tableName];
}

- (void)updateWithModel:(JAModel *)model {
    [self updateWithModel:model fields:nil name:self.tableName];
}

- (void)updateWithModel:(JAModel *)model fields:(NSArray *)fields name:(NSString *)tableName{
    NSString *errLog = [NSString stringWithFormat:@"model对象 %@ 必须实现+pK方法",model];
    NSAssert([[model class] respondsToSelector:@selector(pK)], errLog);
    
    NSMutableString *sql = [NSMutableString stringWithString:@"UPDATE "];
    [sql appendString:tableName];
    [sql appendString:@" SET "];
    NSDictionary *fieldsTypePair = [[[model.class alloc] init] ja_propertyAndEncodeTypeList:false];
    // 过滤无关字段
    fieldsTypePair = [self filterWithDictionay:fieldsTypePair modelClass:[model class]];
    NSArray *allKeys = fieldsTypePair.allKeys;
    
    if (fields) {
        // 过滤,只更新指定字段
    }
    for (int i = 0; i < allKeys.count; ++i) {
        NSString *key = allKeys[i];
        
        if ([key isEqualToString:[[model class] pK]]) { continue; }
        
        [sql appendString:key];
        [sql appendString:@" = '"];
        
        id value = [model valueForKeyPath:key];
        JADBTableType type = [self typeWithKey:key model:model];
        switch (type) {
            case JADBTableTypeString: {
                [sql appendString:value ? : @""];
            }
                break;
            case JADBTableTypeNumber: {
                [sql appendString:[value stringValue]];
            }
                break;
            case JADBTableTypeInteger: {
                [sql appendString:@([value integerValue]).stringValue];
            }
                break;
            case JADBTableTypeArray: {
                NSString *relateValues = @"";
                for (int j = 0; j < [value count]; ++j) {
                    if ([[value[j] class] isSubclassOfClass:[NSString class]]) {
                        // 字符串数组
                        
                    }else if ([[value[j] class] isSubclassOfClass:[JAModel class]]) {
                        // 模型数组
                        if ([[value[j] class] respondsToSelector:@selector(pK)]) {
                            if ([[value[j] valueForKey:[[value[j] class] pK]] isKindOfClass:[NSNumber class]]) {
                                [sql appendString:[[value[j] valueForKey:[[value[j] class] pK]] stringValue]];
                                [relateValues stringByAppendingString:[value[j] valueForKey:[[value[j] class] pK]]];
                            }else if ([[value[j] valueForKey:[[value[j] class] pK]] isKindOfClass:[NSString class]]) {
                                [sql appendString:[value[j] valueForKey:[[value[j] class] pK]]];
                                
                                [relateValues stringByAppendingString:[value[j] valueForKey:[[value[j] class] pK]]];
                            }
                        }
                        if (j != [value count] - 1) {
                            [sql appendString:@";"];
                        }
                        
                        // 从表添加记录
                        [self updateWithModel:value[j] fields:nil name:NSStringFromClass([value[j] class])];
                        
                        //
                        if(![self.relationship objectForKey:key]) {
                            [self.relationship setObject:NSStringFromClass([value[j] class]) forKey:key];
                            if (![self selectWithValue:key operator:JADBOperatorComparisonEqual field:[[JARelateModel class] pK] tableClass:[JARelateModel class] tableName:@"JARelateModel"]) {
                                JARelateModel *relateModel = [[JARelateModel alloc] init];
                                relateModel.key = key;
                                relateModel.relateTableName = NSStringFromClass([value[j] class]);
                                [self insertWithModel:relateModel];
                            }
                        }
                        
                    }else if ([[value[j] class] isSubclassOfClass:[NSArray class]]) {
                        // 集合数组
                        
                    }
                }
            }
                break;
            case JADBTableTypeModel: {
                // 模型类型
                if ([[value class] respondsToSelector:@selector(pK)]) {
                    if ([[value valueForKey:[[value class] pK]] isKindOfClass:[NSNumber class]]) {
                        [sql appendString:[[value valueForKey:[[value class] pK]] stringValue]];
                    }else if ([[value valueForKey:[[value class] pK]] isKindOfClass:[NSString class]]) {
                        [sql appendString:[value valueForKey:[[value class] pK]]];
                    }
                }
                
                [self updateWithModel:value fields:nil name:[fieldsTypePair objectForKey:key]];
                
                if (![self.relationship objectForKey:key]) {
                    [self.relationship setObject:[fieldsTypePair objectForKey:key] forKey:key];
                    
                    // 持久化JAReletateModel
                    if (![self selectWithValue:key operator:JADBOperatorComparisonEqual field:[[JARelateModel class] pK] tableClass:[JARelateModel class] tableName:@"JARelateModel"]) {
                        JARelateModel *relateModel = [[JARelateModel alloc] init];
                        relateModel.key = key;
                        relateModel.relateTableName = NSStringFromClass([value class]);
                        [self insertWithModel:relateModel ];
                    }
                }
            }
                break;
            case JADBTableTypeDictionary: {
                
            }
                break;
            default:
                break;
        }
        [sql appendString:@"'"];
        if (i < allKeys.count - 1) {
            [sql appendString:@","];
        }
    }
    
    [sql appendString:@" WHERE "];
    if ([[model class] respondsToSelector:@selector(pK)]) {
        [sql appendString:[model.class pK]];
    }
    [sql appendString:@" = "];
    
    // 主键
    if ([[model valueForKeyPath:[[model class] pK]] isKindOfClass:[NSNumber class]]) {
        NSNumber *n = [model valueForKeyPath:[model.class pK]];
        [sql appendString:n.stringValue];
    }else if ([[model valueForKeyPath:[[model class] pK]] isKindOfClass:[NSString class]]) {
        [sql appendString:[model valueForKeyPath:[[model class] pK]]];
    }
    
    [self executeUpateWithSql:sql okLog:@"数据更新成功" failLog:@"数据更新失败" success:NULL];
}

#pragma mark -
#pragma mark select
- (NSArray <JAModel *> *)selectAll {
    return [self selectWithValue:nil operator:JADBOperatorNone field:nil tableClass:self.tableClass tableName:nil];
}

- (id)selectWithValue:(id)value {
    return [self selectWithValue:value operator:JADBOperatorComparisonEqual];
}

- (id)selectWithValue:(id)value operator:(JADBOperator)operation {
    return [self selectWithValue:value operator:operation field:[self.tableClass pK]];
}

- (id)selectWithValue:(id)value operator:(JADBOperator)operation field:(NSString *)field {
    return [self selectWithValue:value operator:operation field:field tableClass:self.tableClass tableName:self.tableName];
}

- (id)selectWithValue:(id)value operator:(JADBOperator)operation field:(NSString *)field tableClass:(Class)tableClass tableName:(NSString *)tableName {
    
    NSParameterAssert(tableClass);
    
    id m = nil;
    switch (operation) {
        case JADBOperatorComparisonEqual: {
            // 主键
            if ([field isEqualToString:[tableClass pK]]) {
                self.resultSet = false;
            }
            
            m = [self selectWithComparison:operation value:value field:field tableClass:tableClass tableName:tableName ? : NSStringFromClass(tableClass)];
        }
            break;
        case JADBOperatorLogicalIn:
        case JADBOperatorLogicalBetween: {
            self.resultSet = true;
            m = [self selectWithLogic:operation value:value field:field tableClass:tableClass tableName:tableName ? : NSStringFromClass(tableClass)];
        }
            break;
        case JADBOperatorNone : {
            self.resultSet = true;
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ",tableName ? : NSStringFromClass(tableClass)];
            m = [self internal_selectWithSql:sql tableClass:tableClass];
        }
            break;
        default:
            break;
    }
    return m;
}

- (id)selectWithComparison:(JADBOperator)operation value:(id)value field:(NSString *)field tableClass:(Class)tableClass tableName:(NSString *)tableName{
    id m = nil;
    switch (operation) {
        case JADBOperatorComparisonEqual: {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,field,value];
            m = [self internal_selectWithSql:sql tableClass:tableClass];
        }
            break;
            
        default:
            break;
    }
    return m;
}

- (id)selectWithLogic:(JADBOperator)operation value:(id)value field:(NSString *)field tableClass:(Class) tableClass tableName:(NSString *)tableName {
    id m = nil;
    switch (operation) {
        case JADBOperatorLogicalBetween: {
            NSAssert(([value isKindOfClass:[NSArray class]] && [value count] == 2), @"[JA]:between条件下value参数需要传数组");
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ BETWEEN %@ AND %@",tableName,field,[value firstObject],[value lastObject]];
            m = [self internal_selectWithSql:sql tableClass:tableClass];
        }
            break;
        case JADBOperatorLogicalIn: {
            NSAssert(([value isKindOfClass:[NSArray class]]), @"[JA]:between条件下value参数需要传数组");
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ IN (",tableName,field];
            for (int i = 0; i < [value count]; ++i) {
                sql = [sql stringByAppendingString:value[i]];
                if (i != [value count] - 1) {
                    sql = [sql stringByAppendingString:@","];
                }
            }
            sql = [sql stringByAppendingString:@")"];
            m = [self internal_selectWithSql:sql tableClass:tableClass];
        }
            break;
        default:
            break;
    }
    return m;
}

#pragma mark - 实现查询的方法
- (id)internal_selectWithSql:(NSString *)sql tableClass:(Class)tableClass {
    NSString *errLog = [NSString stringWithFormat:@"model对象 %@ 必须实现+pK方法",tableClass];
    NSAssert([tableClass respondsToSelector:@selector(pK)], errLog);
    
    NSDictionary *fieldsTypePair = [[[tableClass alloc] init] ja_propertyAndEncodeTypeList:false];
    fieldsTypePair = [self filterWithDictionay:fieldsTypePair modelClass:tableClass];
    NSArray *allKeys = fieldsTypePair.allKeys;
    
    NSMutableArray *secondTableDicsM = [NSMutableArray array];
    NSMutableArray *models = [NSMutableArray array];
    
    BOOL resultSet = self.resultSet;
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            
            JAModel *m = [[tableClass alloc] init];
            NSMutableDictionary *secondTableDic = [NSMutableDictionary dictionary];
            
            for (NSString *key in allKeys) {
                
                JADBTableType type = [self typeWithKey:key fieldsTypePair:fieldsTypePair];
                switch (type) {
                    case JADBTableTypeString: {
                        [m setValue:[rs stringForColumn:key] forKey:key];
                    }
                        break;
                    case JADBTableTypeInteger: {
                        [m setValue:@([rs intForColumn:key]) forKey:key];
                    }
                        break;
                    case JADBTableTypeNumber: {
                        [m setValue:@([[rs stringForColumn:key] doubleValue]) forKey:key];
                    }
                        break;
                    case JADBTableTypeModel: {
                        // 1.找出从表
                        // 崩溃的原因是 self.relationship 并不是数据库中准确的
                        NSString *secondaryTableName = [self.relationship objectForKey:key];
                        
                        // 因为self.relationship保存关联关系的没有持久化就不对了
                        // 2.根据id找出从表的记录,返回模型,对模型属性赋值
                        [secondTableDic setObject:@[secondaryTableName,@[[rs stringForColumn:key]]] forKey:key];
                    }
                        break;
                    case JADBTableTypeArray: {
                        // 数组元素是模型
                        
                        if ([rs stringForColumn:key].length > 0) {
                            NSArray *fields = [[rs stringForColumn:key] componentsSeparatedByString:@";"];
                            NSString *secondaryTableName = [self.relationship objectForKey:key];
                            [secondTableDic setObject:@[secondaryTableName,fields] forKey:key];
                        }
                    }
                        break;
                    case JADBTableTypeDictionary: {
                        
                    }
                        break;
                    default:
                        break;
                }
            }
            
            [secondTableDicsM addObject:secondTableDic];
            [models addObject:m];
        }
    }];
    
    if ([models count] > 0) {
        NSMutableArray *ms = [NSMutableArray array];
        for (int i = 0; i < [secondTableDicsM count]; ++i) {
            // 对象关联的属性
            NSMutableDictionary *secondTableDics = secondTableDicsM[i];
            [secondTableDics enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray * _Nonnull obj, BOOL * _Nonnull stop) {
                for (int j = 0; j < [obj.lastObject count]; ++j) {
                    // 根据obj的lastObject的元素个数来判断是模型还是数组是不行的,因为可能是只有一个元素的数组
                    if ([[fieldsTypePair objectForKey:key] rangeOfString:@"Model"].location != NSNotFound) {
                        [models[i] setValue:[self selectWithValue:obj.lastObject[0] operator:JADBOperatorComparisonEqual field:[NSClassFromString(obj.firstObject) pK] tableClass:NSClassFromString(obj.firstObject) tableName:obj.firstObject] forKey:key];
                    }else {
                        
                        JAModel *model = [self selectWithValue:obj.lastObject[j] operator:JADBOperatorComparisonEqual field:[NSClassFromString(obj.firstObject) pK] tableClass:NSClassFromString(obj.firstObject) tableName:obj.firstObject];
                        
                        [ms addObject:model];
                        if (j == [obj.lastObject count] - 1) {
                            [models[i] setValue:[ms copy] forKey:key];
                        }
                    }
                    
                    /*
                    if ([obj.lastObject count] == 1) {
                        
                        [models[i] setValue:[self selectWithValue:obj.lastObject[0] operator:JADBOperatorComparisonEqual field:[NSClassFromString(obj.firstObject) pK] tableClass:NSClassFromString(obj.firstObject) tableName:obj.firstObject] forKey:key];
                        
                    }else if ([obj.lastObject count] > 1) {
                        NSMutableArray *ms = [NSMutableArray arrayWithCapacity:[obj.lastObject count]];
                        
                        JAModel *model = [self selectWithValue:obj.lastObject[j] operator:JADBOperatorComparisonEqual field:[NSClassFromString(obj.firstObject) pK] tableClass:NSClassFromString(obj.firstObject) tableName:obj.firstObject];
                        
                        [ms addObject:model];
                        if (j == [obj.lastObject count] - 1) {
                            [models[i] setValue:[ms copy] forKey:key];
                        }
                    }
                     */
                }
            }];
        }
    }else {
        models = nil;
    }
    
    // 没有找到符合条件的记录
    if (models.count == 0) { return models; }
    
    /// 找到的是一条还是多条?
    /// 一般情况下用selectWithValue: 是用主键去查找的,一般只有一条
    /// 而selectAll一般认为返回的是一个数组或nil
    /// 其他情况也认为是多条
    /// 现在的问题是让外界处理时,认为是数组还是模型比较好? 如果我用主键找,返回一个数组 这就是bug
    if (resultSet == false) {
        if (models.count == 1) {
            return models.firstObject;
        }
    }
    
    return [models copy];
}

#pragma mark -
#pragma mark Utils
- (void)executeUpateWithSql:(NSString *)sql
                      okLog:(NSString *)okLog
                    failLog:(NSString *)failLog
                    success:(nullable void (^)())successBlock{
    
#if DEBUG
    if ([JADBManager sharedDBManager].enableLog){
        NSLog(@"[JA]:%@",sql);
    }
#endif
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL r = [db executeUpdate:sql];
        if(r) {
            if ([JADBManager sharedDBManager].enableLog){
                NSLog(@"[JA]:%@",okLog);
            }
            if (successBlock) {
                successBlock();
            }
        }else {
            if ([JADBManager sharedDBManager].enableLog){
                NSLog(@"[JA]:%@",failLog);
            }
            *rollback = true;
            return ;
        }
    }];
}

- (NSDictionary *)filterWithDictionay:(NSDictionary *)dic modelClass:(Class)modelClass{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
    if ([modelClass respondsToSelector:@selector(whiteList)]) {
        NSArray *ws = [modelClass whiteList];
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([ws indexOfObject:key] == NSNotFound) {
                [dicM removeObjectForKey:key];
            }
        }];
    }else if ([modelClass respondsToSelector:@selector(blackList)]) {
        NSArray *bs = [modelClass blackList];
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([bs indexOfObject:key] != NSNotFound) {
                [dicM removeObjectForKey:key];
            }
        }];
    }
    
    return [dicM copy];
}

/// 两种找属性类型的方法
/// 1. fieldsTypePair 通过运行时找到预先建立的属性的对应关系,进行判断 创建 查询
- (JADBTableType)typeWithKey:(NSString *)key fieldsTypePair:(NSDictionary *)fieldsTypePair{
    
    JADBTableType type = JADBTableTypeString;
    NSString *propertyType = [fieldsTypePair objectForKey:key];
    
    if ([propertyType rangeOfString:@"String"].location != NSNotFound) {
        type = JADBTableTypeString;
    }else if ([propertyType rangeOfString:@"Number"].location != NSNotFound) {
        type = JADBTableTypeNumber;
    }else if ([propertyType rangeOfString:@"Integer"].location != NSNotFound) {
        type = JADBTableTypeInteger;
    }else if ([propertyType rangeOfString:@"Array"].location != NSNotFound) {
        type = JADBTableTypeArray;
    }else if ([propertyType rangeOfString:@"Dictionary"].location != NSNotFound) {
        type = JADBTableTypeDictionary;
    }else if ([propertyType rangeOfString:@"Model"].location != NSNotFound) {
        type = JADBTableTypeModel;
    }
    return type;
}

/// 2. 找到属性值进行类型判断
- (JADBTableType)typeWithKey:(NSString *)key model:(id)model {
    JADBTableType type = JADBTableTypeString;
    id v = [model valueForKeyPath:key];
    if ([NSStringFromClass([v class]) rangeOfString:@"String"].location != NSNotFound) {
        type = JADBTableTypeString;
    }else if ([NSStringFromClass([v class]) rangeOfString:@"Number"].location != NSNotFound) {
        type = JADBTableTypeNumber;
    }else if ([NSStringFromClass([v class]) rangeOfString:@"Integer"].location != NSNotFound) {
        type = JADBTableTypeInteger;
    }else if ([NSStringFromClass([v class]) rangeOfString:@"Array"].location != NSNotFound) {
        type = JADBTableTypeArray;
    }else if ([NSStringFromClass([v class]) rangeOfString:@"Dictionary"].location != NSNotFound) {
        type = JADBTableTypeDictionary;
    }else if ([NSStringFromClass([v class]) rangeOfString:@"Model"].location != NSNotFound) {
        type = JADBTableTypeModel;
    }else if ([NSStringFromClass([v class]) rangeOfString:@"Bool"].location != NSNotFound) {
        type = JADBTableTypeInteger;
    }
    return type;
}

/// 不能在selectXXX方法内使用
- (void)syncRelationTable {
    [self createTableWithClass:[JARelateModel class]];
    NSArray *results = [self selectWithValue:nil operator:JADBOperatorNone field:nil tableClass:[JARelateModel class] tableName:nil];
    if (results) {
        for (int i = 0; i < results.count; ++i) {
            [self.relationship setObject:[results[i] relateTableName]  forKey:[results[i] key]];
        }
    }
#if DEBUG
    NSLog(@"%@",self.relationship);
#endif
}

#pragma mark -
#pragma mark LazyLoad
- (NSMutableDictionary *)relationship {
    if (!_relationship) {
        _relationship = [NSMutableDictionary dictionary];
    }
    return _relationship;
}
- (NSArray *)secondaryTableNames {
    return [self.relationship allValues];
}
@end

