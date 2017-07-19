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
        [self createTableWithModel:tableClass name:tableName];
    }
    return self;
}

- (void)createTableWithModel:(JAModel *)model name:(NSString *)tableName{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",tableName];
    NSDictionary *fieldsTypePair = [[[[model class] alloc] init] ja_propertyAndEncodeTypeList:false];
    fieldsTypePair = [self filterWithDictionay:fieldsTypePair modelClass:[model class]];
    NSArray *allKeys = fieldsTypePair.allKeys;
    for (int i = 0; i < allKeys.count; ++i) {
        NSString *key = allKeys[i];
        
        [sql appendString:key];
        
        if ([[model class] respondsToSelector:@selector(pK)] && [[[model class] pK] isEqualToString:key]) {
            // 主键
            [sql appendString:@" INTEGER PRIMARY KEY NOT NULL,"];
        }else if([[model class] respondsToSelector:@selector(fKs)] && [[[model class] fKs] objectForKey:key]) {
            // 外键
            NSArray *fkTable = [[[model class] fKs] objectForKey:key];
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
    NSMutableString *sql = [NSMutableString stringWithString:[NSString stringWithFormat:@"INSERT INTO %@ (",tableName]];
    NSDictionary *fieldsTypePair = [[[model.class alloc] init] ja_propertyAndEncodeTypeList:false];
    fieldsTypePair = [self filterWithDictionay:fieldsTypePair modelClass:[model class]];
    NSArray *allKeys = fieldsTypePair.allKeys;
    
    for (int i = 0; i < allKeys.count; ++i) {
        NSString *key = allKeys[i];
        [sql appendString:key];
        if (i != (allKeys.count - 1)) {
            [sql appendString:@","];
        }
    }
    
    [sql appendString:@") VALUES("];
    
    for (int i = 0; i < allKeys.count; ++i) {
        NSString *key = allKeys[i];
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
                                [self createTableWithModel:(JAModel *)[value[i] class] name:NSStringFromClass([value[i] class])];
                                [self.relationship setObject:NSStringFromClass([value[i] class]) forKey:key];
                            }
                        }
                        
                        // 从表添加记录
                        [self insertWithModel:value[i] name:NSStringFromClass([value[i] class])];
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
                if ([NSClassFromString([fieldsTypePair objectForKey:key]) isSubclassOfClass:[JAModel class]]) {
                    [self createTableWithModel:(JAModel *)NSClassFromString([fieldsTypePair objectForKey:key]) name:[fieldsTypePair objectForKey:key]];
                    [self.relationship setObject:[fieldsTypePair objectForKey:key] forKey:key];
                }
                
                // 从表添加model记录
                [self insertWithModel:value name:[fieldsTypePair objectForKey:key]];
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
    [self insertWithModel:model name:self.tableName];
}

#pragma mark -
#pragma mark delete

/// 级联删除
#warning v0.1.2
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
                
            }
                break;
            case JADBTableTypeArray: {
                for (int i = 0; i < [value count]; ++i) {
                    if ([[value[i] class] isSubclassOfClass:[NSString class]]) {
                        // 字符串数组
                        
                    }else if ([[value[i] class] isSubclassOfClass:[JAModel class]]) {
                        // 模型数组
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
                        
                        // 从表添加记录
                        [self updateWithModel:value[i] fields:nil name:NSStringFromClass([value[i] class])];
                    }else if ([[value[i] class] isSubclassOfClass:[NSArray class]]) {
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
- (NSArray<JAModel *> *)selectAllWithTableClass:(id)tableClass name:(NSString *)name{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ",name];
    NSDictionary *fieldsTypePair = [[[tableClass alloc] init] ja_propertyAndEncodeTypeList:false];
    fieldsTypePair = [self filterWithDictionay:fieldsTypePair modelClass:tableClass];
    NSArray *allKeys = fieldsTypePair.allKeys;
    
    NSMutableArray *secondTableDicsM = [NSMutableArray array];
    
    NSMutableArray *models = [NSMutableArray array];
    
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
                    case JADBTableTypeNumber: {
                        [m setValue:@([[rs stringForColumn:key] doubleValue]) forKey:key];
                    }
                        break;
                    case JADBTableTypeModel: {
                        // 1.找出从表
                        NSString *secondaryTableName = [self.relationship objectForKey:key];
                        
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
    
    for (int i = 0; i < [secondTableDicsM count]; ++i) {
        NSMutableDictionary *secondTableDics = secondTableDicsM[i];
        [secondTableDics enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray * _Nonnull obj, BOOL * _Nonnull stop) {
            for (int j = 0; j < [obj.lastObject count]; ++j) {
                if ([obj.lastObject count] == 1) {
                    [models[i] setValue:[self selectWithValue:obj.lastObject[0] tableClass:NSClassFromString(obj.firstObject) name:obj.firstObject] forKey:key];
                }else if ([obj.lastObject count] > 1) {
                    NSMutableArray *ms = [NSMutableArray arrayWithCapacity:[obj.lastObject count]];
                    JAModel *model = [self selectWithValue:obj.lastObject[j] tableClass:NSClassFromString(obj.firstObject) name:obj.firstObject];
                    [ms addObject:model];
                    if (j == [obj.lastObject count] - 1) {
                        [models[i] setValue:[ms copy] forKey:key];
                    }
                }
            }
        }];
    }

    return [models copy];
}

- (id)selectWithValue:(id)value tableClass:(id)tableClass {
   return [self selectWithValue:value tableClass:tableClass name:self.tableName];
}

- (JAModel *)selectWithValue:(id)value tableClass:(id)tableClass name:(NSString *)name{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",name,[tableClass pK],value];
    
    NSDictionary *fieldsTypePair = [[[tableClass alloc] init] ja_propertyAndEncodeTypeList:false];
    fieldsTypePair = [self filterWithDictionay:fieldsTypePair modelClass:tableClass];
    NSArray *allKeys = fieldsTypePair.allKeys;
    
    JAModel *m = [[tableClass alloc] init];
    
    NSMutableDictionary *secondTableDic = [NSMutableDictionary dictionary];
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            for (NSString *key in allKeys) {
                
                JADBTableType type = [self typeWithKey:key fieldsTypePair:fieldsTypePair];
                switch (type) {
                    case JADBTableTypeString: {
                        [m setValue:[rs stringForColumn:key] forKey:key];
                    }
                        break;
                    case JADBTableTypeNumber: {
                        [m setValue:@([[rs stringForColumn:key] doubleValue]) forKey:key];
                    }
                        break;
                    case JADBTableTypeModel: {
                        // 1.找出从表
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
        }
    }];
    
    [secondTableDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray * _Nonnull obj, BOOL * _Nonnull stop) {
        
        for (int i = 0; i < [obj.lastObject count]; ++i) {
            if ([obj.lastObject count] == 1) {
                [m setValue:[self selectWithValue:obj.lastObject[0] tableClass:NSClassFromString(obj.firstObject) name:obj.firstObject] forKey:key];
            }else if ([obj.lastObject count] > 1) {
                NSMutableArray *models = [NSMutableArray arrayWithCapacity:[obj.lastObject count]];
                JAModel *model = [self selectWithValue:obj.lastObject[i] tableClass:NSClassFromString(obj.firstObject) name:obj.firstObject];
                [models addObject:model];
                if (i == [obj.lastObject count] - 1) {
                    [m setValue:[models copy] forKey:key];
                }
            }
        }
    }];
    
    return m;
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
    }
    return type;
}

#pragma mark -
#pragma mark LazyLoad
- (NSMutableDictionary *)relationship {
    if (!_relationship) {
        // 必须先尝试从数据库取数据
        // @{属性:@[表名;@[1,2,..]}
        // id 属性 tablename values
        _relationship = [NSMutableDictionary dictionary];
    }
    return _relationship;
}

- (NSArray *)subTableNames {
    return [self.relationship allValues];
}
@end

