//
//  JAReaderParser.h
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * 内容解析
 */
@interface JAReaderParser : NSObject

/**
 创建CTFrameRef对象

 生成 CTFramewRef => JAReaderView
 
 @param content 内容
 @param bounds 边框
 @return CTFrameRef 对象
 */
+ (CTFrameRef)parserContent:(NSString *)content
                     bounds:(CGRect)bounds;


+ (CGRect)parserRectWithPoint:(CGPoint)point
                        range:(NSRange *)selectRange
                     frameRef:(CTFrameRef)frameRef;


+ (NSArray *)parserRectsWithPoint:(CGPoint)point
                            range:(NSRange *)selectRange
                         frameRef:(CTFrameRef)frameRef
                            paths:(NSArray *)paths
                        direction:(BOOL) direction;

/**
 将网络请求获得的文章内容进行处理
 现在主要是用正则将解析<p>标签
 
 生成content => JAReaderView
 
 @param markup 原始数据
 @return 正常的文章内容
 */
+ (NSString *)parseMarkup:(NSString *)markup;

@end

NS_ASSUME_NONNULL_END
