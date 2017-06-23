//
//  JAReaderParser.h
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@class JAReaderConfig;

/// 内容解析
@interface JAReaderParser : NSObject

+ (CTFrameRef)parserContent:(NSString *)content
                     config:(JAReaderConfig *)parser
                      bouds:(CGRect)bounds;

@end
