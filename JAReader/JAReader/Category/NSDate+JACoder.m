//
//  NSDate+JACoder.m
//  Daily_modules
//
//  Created by Jason on 13/01/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "NSDate+JACoder.h"

@implementation NSDate (JACoder)

static NSDateFormatter *dateFormatter;

+ (NSDateFormatter *)ja_defaultFormatter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        [dateFormatter setTimeZone:timeZone];
    });
    return dateFormatter;
}

+ (NSDate *)ja_dateFromString:(NSString *)timeStr
                       format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [NSDate ja_defaultFormatter];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:timeStr];
    return date;
}

+ (NSInteger)ja_cTimestampFromDate:(NSDate *)date{
    return (long)[date timeIntervalSince1970];
}

+ (NSInteger)ja_cTimestampFromString:(NSString *)timeStr
                           format:(NSString *)format
{
    NSDate *date = [NSDate ja_dateFromString:timeStr format:format];
    return [NSDate ja_cTimestampFromDate:date];
}

+ (NSString *)ja_dateStrFromCstampTime:(NSInteger)timeStamp
                        withDateFormat:(NSString *)format
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    return [NSDate ja_datestrFromDate:date withDateFormat:format];
}

+ (NSString *)ja_datestrFromDate:(NSDate *)date
               withDateFormat:(NSString *)format
{
    NSDateFormatter* dateFormat = [NSDate ja_defaultFormatter];
    [dateFormat setDateFormat:format];
    return [dateFormat stringFromDate:date];
}

+ (NSDateComponents *)ja_currentComponents {
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    return [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:now];
}

+ (NSData *)ja_dataWithHexString:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}

+ (BOOL)ja_isDiffDay {
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formater setTimeZone:timeZone];
    
    // 获取当前日期
    NSDate *curDate = [NSDate date];
    [formater setDateFormat:@"yyyy-MM-dd"];
    NSString * curTime = [formater stringFromDate:curDate];
    
    NSString *bid = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
    NSString *currentDate = [[[NSUserDefaults alloc] initWithSuiteName:bid] objectForKey:@"currentDate"];
    
    // 首次
    if (currentDate == nil) {
        [[[NSUserDefaults alloc] initWithSuiteName:bid] setObject:curTime forKey:@"currentDate"];
    }
    
    // 是否是同一天
    if ([curTime isEqualToString:currentDate]) {
        return false;
    }
    
    return true;
}

@end
