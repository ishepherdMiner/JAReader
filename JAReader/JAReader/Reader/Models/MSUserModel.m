//
//  MSUserModel.m
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "MSUserModel.h"
#import "JADBManager.h"

@implementation MSProfileModel

+ (NSString *)pK {
    return @"id";
}

- (instancetype)init {
    if (self = [super init]) {
        self.nickname = @"游客";
        self.avatar = @"avatar";
        self.mobile = @"";        
        self.email = @"未绑定";
        self.sex = @"1";
        self.openid = @"";
    }
    return self;
}

@end

@implementation MSUserModel

+ (NSString *)pK {
    return @"id";
}


+ (instancetype)sharedUser{
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JADBTable *userTable = [[JADBManager sharedDBManager].tables objectForKey:@"MSUserModel"];
        [userTable syncRelationTable];
        NSArray *users = [userTable selectAll];
        if (users.count == 0) {
            instance = [[self alloc] init];
        }else {
            for (int i = 0; i < users.count; ++i) {
                if ([users[i] is_active]) {
                    instance = users[i];
                }
            }
            
            if (instance == nil) {
                instance = [[self alloc] init];
            }
        }
    });
    
    return instance;
}

- (void)setId:(NSString *)id {
    _id = id;
    _profile.id = id;
}

- (instancetype)init {
    if (self = [super init]) {
        self.state = MSLoginStateNone;
        self.api_token = @"";
        self.bookshelf = @[];
        self.profile = [[MSProfileModel alloc] init];
        self.id = @"0";        
    }
    return self;
}

- (BOOL)persistence {
    JADBTable *userTable = [[JADBManager sharedDBManager].tables objectForKey:@"MSUserModel"];
    [userTable syncRelationTable];
    if ([userTable selectWithValue:[MSUserModel sharedUser].id]) {
        [userTable updateWithModel:[MSUserModel sharedUser]];
    }else {
        [userTable insertWithModel:[MSUserModel sharedUser] name:userTable.tableName];
    }
    return true;
}

- (void)logout {
    self.profile = [[MSProfileModel alloc] init];
    self.profile.id = self.id;
    self.state = MSLoginStateNone;
    self.is_active = false;
    self.bookshelf = @[];
    self.api_token = @"";
    // JADBTable *userTable = [[JADBManager sharedDBManager].tables objectForKey:@"MSUserModel"];
    // [userTable updateWithModel:[MSUserModel sharedUser]];
    [self persistence];
}

@end
