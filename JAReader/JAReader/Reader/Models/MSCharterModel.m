//
//  MSCharterModel.m
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "MSCharterModel.h"
#import <UIKit/UIKit.h>
#import "JAReaderParser.h"
#import "JAReaderConfig.h"
#import <CoreText/CoreText.h>
#import "JACategory.h"

@interface MSCharterModel ()

@end

@implementation MSCharterModel

+ (NSString *)pK {
    return @"charterid";
}

+ (NSArray *)blackList {
    return @[@"pages",@"superclass",@"debugDescription",@"hash",@"description"];
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
             @"charterid":@"id",
             @"charterTitle":@"title",
             @"content":@"content",
             @"bookid":@"book_id",
           };
}

- (instancetype)init {
    if ([super init]) {
        _pages = [NSMutableArray array];
    }
    return self;
}

- (void)setContent:(NSString *)content {
    _content = content;
    [self paginateWithBounds:CGRectMake(10, 10, UIScreen.w - 20, UIScreen.h - 20)];
}

/// 根据页数获得该页内容
- (NSString *)stringOfPage:(NSUInteger)index {
    NSUInteger loc = [_pages[index] integerValue];
    NSUInteger length;
    if (index < [self.pageCount integerValue] -1) {
        length = [_pages[index + 1] integerValue] - [_pages[index] integerValue];
    }else {
        length = _content.length - [_pages[index] integerValue];
    }
    return [_content substringWithRange:NSMakeRange(loc, length)] ;
}

/**
 分页

 @param bounds 内容区域
 */
- (void)paginateWithBounds:(CGRect)bounds {
    [_pages removeAllObjects];
    CTFramesetterRef frameSetter;
    CGPathRef path;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSDictionary *attribute = [JAReaderParser parserAttribute:[JAReaderConfig sharedReaderConfig]];
    [attrStr setAttributes:attribute range:NSMakeRange(0, attrStr.length)];
    frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrStr);
    path = CGPathCreateWithRect(bounds, NULL);
    int currentOffset = 0;
    int currentInnerOffset = 0;
    BOOL hasMorePages = true;
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    int preventDeadLoopSign = currentOffset;
    int samePlaceRepeatCount = 0;
    
    while (hasMorePages) {
        if (preventDeadLoopSign == currentOffset) {
            ++samePlaceRepeatCount;
        } else {
            samePlaceRepeatCount = 0;
        }
        
        if (samePlaceRepeatCount > 1) {
            // 退出循环前检查一下最后一页是否已经加上
            if (_pages.count == 0) {
                [_pages addObject:@(currentOffset)];
            }
            else {
                NSUInteger lastOffset = [[_pages lastObject] integerValue];
                if (lastOffset != currentOffset) {
                    [_pages addObject:@(currentOffset)];
                }
            }
            break;
        }
        
        [_pages addObject:@(currentOffset)];
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(currentInnerOffset, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        
        // 不等于内容的长度,表明还有内容
        if ((range.location + range.length) != attrStr.length) {
            currentOffset += range.length;
            currentInnerOffset += range.length;
        } else {
            // 已经分完，提示跳出循环
            hasMorePages = NO;
        }
        if (frame) CFRelease(frame);
    }
    
    CGPathRelease(path);
    CFRelease(frameSetter);
    _pageCount = @(_pages.count).stringValue;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
