//
//  AppDelegate.m
//  JAReader
//
//  Created by Jason on 15/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "AppDelegate.h"
#import "JADBManager.h"
#import "MSUserModel.h"
#import "MSBookModel.h"
#import "MSCharterModel.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupDatabase];
    return YES;
}

- (void)setupDatabase {
    
    JADBManager *dbMg = [JADBManager sharedDBManager];
    [dbMg open];
    // dbMg.enableLog = false;
    [dbMg createTableWithName:@"MSUserModel" modelClass:[MSUserModel class]];
    [dbMg createTableWithName:@"MSBookModel" modelClass:[MSBookModel class]];
    [dbMg createTableWithName:@"MSCharterModel" modelClass:[MSCharterModel class]];
    [dbMg createTableWithName:@"MSProfileModel" modelClass:[MSProfileModel class]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
}


@end
