//
//  JANetworkMBHub.m
//  RssMoney
//
//  Created by Jason on 11/04/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JANetworkMBHud.h"
#import <MBProgressHUD.h>

@interface JANetworkMBHud ()

@property (nonatomic,strong) MBProgressHUD *hud;

@end

@implementation JANetworkMBHud

- (void)showInView:(UIView *)view {
    self.hud = [MBProgressHUD showHUDAddedTo:view animated:true];
}

- (void)hide {
    [self.hud hideAnimated:true afterDelay:1.2];
}
@end
