//
//  JAPageView.h
//  MStarReader
//
//  Created by Jason on 14/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYText.h>

/// 单页
@interface JAReaderView : UIView

@property (nonatomic,assign) CTFrameRef frameRef;
@property (nonatomic,strong) NSString *content;

- (void)cancelSelected;

@end