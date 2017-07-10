//
//  MSTopMenuView.h
//  JAReader
//
//  Created by Jason on 11/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MSMenuViewDelegate;

@interface MSTopMenuView : UIView

@property (nonatomic,assign) BOOL state; //(0--未保存过，1-－保存过)
@property (nonatomic,weak) id <MSMenuViewDelegate> delegate;

@end
