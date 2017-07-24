//
//  JADBManager.m
//  AntRecord
//
//  Created by Jason on 09/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JADBManager.h"
#import "JAModel.h"
#import "JACategory.h"
#import <objc/message.h>
#import <FMDB.h>
#import "JADBTable.h"

@interface JADBManager ()

@property (nonatomic,copy) NSString *curTableName;
@property (nonatomic,copy) NSString *curDbPath;

@property (nonatomic,strong) FMDatabaseQueue *dbQueue;
@property (nonatomic,strong) NSMutableDictionary <NSString *,JADBTable *> *tables;
@end

@implementation JADBManager

+ (instancetype)sharedDBManager {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - 数据库操作
- (instancetype)open {
    return [self openWithDbPath:nil];
}
- (instancetype)openWithDbName:(NSString *)dbName {
    return [self openWithDbPath:dbName];
}

- (instancetype)openWithDbPath:(nullable NSString *)dbPath {
    NSString *path = nil;
    if (_dbQueue == nil) {        
        if (dbPath == nil) {
            NSString *executable = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
            NSString *dbDirectory = [[NSFileManager defaultManager] createDirectoryAtDocumentWithName:executable];
            path = [NSString stringWithFormat:@"%@/%@.sqlite",dbDirectory,executable];
        }else if ([dbPath rangeOfString:@"/"].location != NSNotFound){
            path = dbPath;
        }else {
            NSString *executable = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
            NSString *dbDirectory = [[NSFileManager defaultManager] createDirectoryAtDocumentWithName:executable];
            path = [NSString stringWithFormat:@"%@/%@.sqlite",dbDirectory,dbPath];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
        _curDbPath = path;
        _enableLog = true;
    }
    
    return self;
}

- (void)close {
    if (_dbQueue == nil) {
        NSLog(@"[JA]:请先调用open:打开数据库");
    }else {
        [_dbQueue close];
    }
}

#pragma mark - 表

- (JADBTable *)createTableWithName:(NSString *)tableName
                        modelClass:(id)modelClass{
    
    JADBTable *table = [[JADBTable alloc] initWithTableName:tableName tableClass:modelClass];
    if ([self.tables objectForKey:table.tableName] == nil) {
        [self.tables setObject:table forKey:table.tableName];
    }
    
    self.curTableName = table.tableName;
    return table;
}

- (JADBTable *)selectTableWithName:(NSString *)tableName {
    JADBTable *table = [self.tables objectForKey:tableName];
    if (table) {
        self.curTableName = table.tableName;
        return table;
    }else {
        NSLog(@"[JA]:没有 %@ 表",tableName);;
        return nil;
    }
}

- (void)deleteTable {
    NSString *sql = [NSString stringWithFormat:@" DROP TABLE %@",self.curTableName];
    [[self.tables objectForKey:self.curTableName] executeUpateWithSql:sql okLog:[NSString stringWithFormat:@"%@表被成功删除",self.curTableName] failLog:[NSString stringWithFormat:@"%@ 表删除失败",self.curTableName] success:NULL];
}

- (void)deleteTableWithName:(NSString *)name {
    NSString *sql = [NSString stringWithFormat:@" DROP TABLE %@",name];
    if([self.tables objectForKey:name]) {
        [[self.tables objectForKey:name] executeUpateWithSql:sql okLog:[NSString stringWithFormat:@"%@表被成功删除",name] failLog:[NSString stringWithFormat:@"%@ 表删除失败",name] success:NULL];
    }else {
        // 因为没有保存Table的表,所以目前其实意义不大,所以先这么着吧
        NSLog(@"[JA]:抱歉暂时没这个表,因为持久化的功能还没做");
    }
}

- (NSArray *)allTables {
    return self.tables.allKeys;
}

- (NSMutableDictionary<NSString *,JADBTable *> *)tables {
    if (!_tables) {
        _tables = [NSMutableDictionary dictionary];
    }
    return _tables;
}
@end
