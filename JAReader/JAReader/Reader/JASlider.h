//
//  JASlider.h
//  MStarReader
//
//  Created by Jason on 03/08/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASlider : UISlider

@property (nonatomic,assign) CGPoint progressPoint;
@property (nonatomic,copy) void (^refreshBlock)(float value);
@property (nonatomic,copy) void (^moveBlock)(float value);
@end
