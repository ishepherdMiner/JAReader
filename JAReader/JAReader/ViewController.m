//
//  ViewController.m
//  JAReader
//
//  Created by Jason on 15/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "ViewController.h"
#import "JAReaderViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)readAction:(UIButton *)sender {
    JAReaderViewController *readerVC = [[JAReaderViewController alloc] init];
    [self presentViewController:readerVC animated:true completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
