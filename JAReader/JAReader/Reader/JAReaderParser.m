//
//  JAReaderParser.m
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderParser.h"
#import "JAReaderConfig.h"

@interface JAReaderParser ()

@property (nonatomic,strong) NSArray *chunks;
@property (nonatomic,copy) NSMutableString *attrString;

@end

@implementation JAReaderParser

+ (CTFrameRef)parserContent:(NSString *)content
                     config:(JAReaderConfig *)parser
                      bouds:(CGRect)bounds {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSDictionary *attribute = [self parserAttribute:parser];
    [attributedString setAttributes:attribute range:NSMakeRange(0, content.length)];
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CGPathRef pathRef = CGPathCreateWithRect(bounds, NULL);
    CTFrameRef frameRef = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, 0), pathRef, NULL);
    CFRelease(setterRef);
    CFRelease(pathRef);
    return frameRef;
    
}

- (NSString *)parseMarkup:(NSString *)markup {
    // <([a-z][a-z0-9]*)\b[^>]*>(.*?)</\1>
    // (.*?)(<[^>]+>|\\Z)
    // [NSString stringWithFormat:@"[^<\\/?\\w*>]+(%@\\s)", @"p"]
    NSError *err = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"(.*?)(<[^>]+>|\\Z)" options:NSRegularExpressionCaseInsensitive error:&err];
    NSLog(@"%@",err);
    _chunks = [re matchesInString:markup options:NSMatchingReportProgress range:NSMakeRange(0, markup.length)];
    
    NSMutableString *ss = [NSMutableString string];
    
    for (int i = 0; i < _chunks.count; ++i) {
        NSString *s = [markup substringWithRange:[_chunks[i] range]];
        
        [ss appendString:[s componentsSeparatedByString:@"<"][0]];
        [ss appendFormat:@"\n"];
    }
    
    return [ss copy];
}

+ (NSString *)parseMarkup:(NSString *)markup {
    // <([a-z][a-z0-9]*)\b[^>]*>(.*?)</\1>
    // (.*?)(<[^>]+>|\\Z)
    // [NSString stringWithFormat:@"[^<\\/?\\w*>]+(%@\\s)", @"p"]
    NSError *err = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"(.*?)(<[^>]+>|\\Z)" options:NSRegularExpressionCaseInsensitive error:&err];
    NSLog(@"%@",err);
    NSArray *chunks = [re matchesInString:markup options:NSMatchingReportProgress range:NSMakeRange(0, markup.length)];
    
    NSMutableString *ss = [NSMutableString string];
    
    for (int i = 0; i < chunks.count; ++i) {
        NSString *s = [markup substringWithRange:[chunks[i] range]];
        
        [ss appendString:[s componentsSeparatedByString:@"<"][0]];
        [ss appendFormat:@"\n"];
    }
    
    return [ss copy];
}

/**
 从阅读器配置对象中读取出样式属性

 @param config 阅读器配置对象
 @return 样式属性
 */
+ (NSDictionary *)parserAttribute:(JAReaderConfig *)config {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = config.fontColor;
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:config.fontSize];
    dict[NSBackgroundColorAttributeName] = [UIColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = config.lineSpace;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    
    return [dict copy];
}
@end
