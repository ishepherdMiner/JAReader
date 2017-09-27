//
//  JAToastButton.m
//  MStarReader
//
//  Created by Jason on 06/08/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAToastButton.h"
#import "JACategory.h"
#import "JAConfigure.h"

@implementation JAToastButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // [_fontBtn setImagePosition:JAMImagePositionTop spacing:0];
        self.backgroundColor = HexRGB(0x000000);
        [self setTitleColor:HexRGB(0xffffff) forState:UIControlStateNormal];
        [self setImagePosition:JAMImagePositionLeft spacing:0];
    }
    return self;
}

@end
