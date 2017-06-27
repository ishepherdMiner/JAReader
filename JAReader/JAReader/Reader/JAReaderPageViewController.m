//
//  JAReaderPageViewController.m
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderPageViewController.h"
#import "JAReaderViewController.h"

@interface JAReaderPageViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic, assign) BOOL statusBarHide;
@property (nonatomic,strong) JAReaderViewController *readerViewController;
@end

@implementation JAReaderPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statusBarHide = true;
    
    [self addChildViewController:self.pageViewController];
    _readerViewController = [[JAReaderViewController alloc] init];
    [self.pageViewController setViewControllers:@[_readerViewController] direction:UIPageViewControllerNavigationDirectionForward animated:true completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    JAReaderViewController *vc = [[JAReaderViewController alloc] init];
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    JAReaderViewController *vc = [[JAReaderViewController alloc] init];
    return vc;
}

- (BOOL)prefersStatusBarHidden {
    BOOL l = false;
    if (self.statusBarHide) {
        l = true;
    }else {
        l = false;
    }
    self.statusBarHide = !self.statusBarHide;
    return l;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)back{
    [self.navigationController dismissViewControllerAnimated:true completion:NULL];
}

#pragma mark -
#pragma mark 懒加载
- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self.view addSubview:_pageViewController.view];
    }
    return _pageViewController;
}

@end
