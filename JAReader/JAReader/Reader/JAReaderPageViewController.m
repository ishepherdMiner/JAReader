//
//  JAReaderPageViewController.m
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderPageViewController.h"
#import "JAReaderViewController.h"
#import "MSNetworkManager.h"
#import "MSUserModel.h"

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
    // 请求
    //  1.章节信息
    NSString *url = @"http://api.xyreader.com/chapters";
    NSDictionary *params = @{@"bid":@"1"};
    [[MSNetworkManager manager] GET:url parameters:params success:^(NSURLSessionDataTask *task, id response) {
        
    }];
    
    // 2.当前阅读的章节的内容
    //  2.1 取出持久化保存的阅读记录，从中获取阅读的章节和页数 (传入bookid,得到当前阅读的章节与具体的页数)
    //  2.2 发送章节内容的请求 [请求3章] UIPageViewController代理中,发现切换超过了当前的章节,发请求获取前一章或后一章
    //  2.3 在本地分页,为当前页面选择合适的内容。
    
    NSString *bookid = @"1";
    NSDictionary *record = [[MSUserModel sharedUser].records objectForKey:bookid];
    // 首次
    NSString *chartid = @"1";
    NSString *page = @"1";
    
}

- (JAReaderViewController *)readViewWithChapter:(NSUInteger)chapter page:(NSUInteger)page{
    return nil;
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
