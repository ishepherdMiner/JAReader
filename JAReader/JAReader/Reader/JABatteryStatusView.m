//
//  JABatteryStatusView.m
//  MStarReader
//
//  Created by Jason on 04/08/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JABatteryStatusView.h"
#import "JACategory.h"
#import "JAConfigure.h"
#import "JAReaderPageViewController.h"
#import "JAReaderConfig.h"

@implementation JABatteryStatusView

- (void)drawRect:(CGRect)rect {
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //设置线条粗细宽度
    CGContextSetLineWidth(context, 1.0);
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        //设置颜色
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    }else {
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    }
    
    //开始一个起始路径
    CGContextBeginPath(context);
    //起始点设置为(0,0):注意这是上下文对应区域中的相对坐标，
    CGContextMoveToPoint(context, 0.5, 2.5);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, 25.5, 2.5);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, 25.5, 5.5);
    CGContextAddLineToPoint(context, 28.5, 5.5);
    CGContextAddLineToPoint(context, 28.5, 12.5);
    CGContextAddLineToPoint(context, 25.5, 12.5);
    CGContextAddLineToPoint(context, 25.5, 15.5);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, 0.5, 15.5);
    CGContextAddLineToPoint(context, 0.5, 2.5);
    //连接上面定义的坐标点
    CGContextStrokePath(context);
    
    [UIDevice currentDevice].batteryMonitoringEnabled = true;
    float batterLevel = [UIDevice currentDevice].batteryLevel;
    CGFloat batterWidth = batterLevel / 1.0 * 19;
    
    CGContextAddRect(context, CGRectMake(2, 4.5, 2.5 + batterWidth, 9.5));
    
    if (batterLevel == 1.0) {
        CGContextAddRect(context,CGRectMake(21.5,7,5,4));
    }
    CGContextFillPath(context);
    
    // CGContextFillRect(context, self.bounds);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeThemeAction:) name:MSReaderChangeThemeNotification object:nil];
    }
    return self;
}

- (void)changeThemeAction:(NSNotification *)noti {
    [self setNeedsDisplay];
}

@end
