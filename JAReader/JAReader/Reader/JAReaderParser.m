//
//  JAReaderParser.m
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderParser.h"
#import "JAReaderConfig.h"

@implementation JAReaderParser

+ (CTFrameRef)parserContent:(NSString *)content
                     config:(JAReaderConfig *)parser
                      bouds:(CGRect)bounds {
    
    return nil;
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
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = config.lineSpace;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return [dict copy];
}
@end
