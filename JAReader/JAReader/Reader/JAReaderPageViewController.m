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
    
    /*
     NSString *bookid = @"1";
     NSString *charterid = @"2";
     NSString *url = [NSString stringWithFormat:@"http://api.xyreader.com/chapter/%@/%@",bookid,charterid];
     [[MSNetworkManager manager] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
     
     if ([responseObject valueForKey:charterid]) {
     MSCharterModel *m = [MSCharterModel yy_modelWithDictionary:[responseObject valueForKey:charterid]];
     NSLog(@"%@",m.charterid);
     NSLog(@"%@",m.charterTitle);
     NSLog(@"%@",m.content);
     NSLog(@"%@",m.bookid);
     self.label = [[YYLabel alloc] initWithFrame:CGRectMake(10, 0, UIScreen.w - 20, UIScreen.h - 200)];
     self.label.text = m.content;
     self.label.numberOfLines = 0;
     self.label.backgroundColor = [UIColor redColor];
     [self.view addSubview:self.label];
     
     // <p>    本来是没打算上架的，但不过大家都劝着上架，老齐对于上架之后能干什么也很好奇，抱着这种好奇的心，元旦，未婚妻终于迎来了上架。</p><p>对于那些一直支持老齐的书的兄弟姐妹，老齐在这里给你们鞠躬至谢了，有你们的陪伴，孤独的我，才找到了安慰的地方。</p><p>我看了，不管是哪里的，盗版的也好，还是正版的，都有骂老齐更新慢，今天老齐把话搁这里了，下星期一开始，未婚妻将迎来大爆更，一天一万字？一天俩万字？大家到时候等着就是了。</p><p>今晚是跨年，老齐在这里祝大家</p><p>2016</p><p>六六大顺</p><p>越来越6</p><p>当然，没结婚的女孩子也可以找寻一下另外一个拌，实在找不了，老齐不介意你把老齐娶回家。</p><p>那些还在外面飘的兄弟，新年了，赶快回家吧，爸爸妈妈都等着你的回去呢。</p><p>总之，新的一年，我希望大家都有所改变，但不过，那颗赤子之心却是不能改变的。</p><p>公告：网文联赛本赛季海选阶段最后三周！未参加的小伙伴抓紧了！重磅奖金、成神机会等你来拿！点此参与</p>
     //
     }
     }];
     */
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
