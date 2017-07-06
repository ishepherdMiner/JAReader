//
//  JAReaderViewController.m
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderPageViewController.h"
#import "JAReaderViewController.h"
#import "MSNetworkManager.h"
#import "MSUserModel.h"
#import "MSCharterModel.h"
#import "JAReaderParser.h"
#import "MSRecordModel.h"

@interface JAReaderPageViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic, assign) BOOL statusBarHide;
@property (nonatomic,strong) JAReaderViewController *readerViewController;

// 阅读记录
@property (nonatomic,strong) MSRecordModel *recordModel;

@property (nonatomic,strong) MSCharterModel *chapterModel;
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
    NSString *url = @"http://api.xyreader.com/chapters/";
    url = [url stringByAppendingString:@"1"];
    [[MSNetworkManager manager] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        
    }];
    
    // 2.当前阅读的章节的内容
    //  2.1 取出持久化保存的阅读记录，从中获取阅读的章节和页数 (传入bookid,得到当前阅读的章节与具体的页数)
    //  2.2 发送章节内容的请求 [请求3章] UIPageViewController代理中,发现切换超过了当前的章节,发请求获取前一章或后一章
    //  2.3 在本地分页,为当前页面选择合适的内容。
    
    NSString *bookid = @"1";
    NSDictionary *record = [[MSUserModel sharedUser].records objectForKey:bookid];
    // 首次
    NSString *chartid = @"1";
    NSString *page = @"0";
    
    // 记住页数,记住章节,然后在翻页的时候,通过stringOfPage,得到本章的指定页数的内容
    url = @"http://api.xyreader.com/chapter/";
    url = [[[url stringByAppendingString:bookid] stringByAppendingString:@"/"] stringByAppendingString:chartid];
    [[MSNetworkManager manager] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        /// 得到指定章节内容
        MSCharterModel *m = [[MSCharterModel alloc] init];
        m.content = [JAReaderParser parseMarkup:@"<p>    本来是没打算上架的，但不过大家都劝着上架，老齐对于上架之后能干什么也很好奇，抱着这种好奇的心，元旦，未婚妻终于迎来了上架。</p><p>对于那些一直支持老齐的书的兄弟姐妹，老齐在这里给你们鞠躬至谢了，有你们的陪伴，孤独的我，才找到了安慰的地方。</p><p>我看了，不管是哪里的，盗版的也好，还是正版的，都有骂老齐更新慢，今天老齐把话搁这里了，下星期一开始，未婚妻将迎来大爆更，一天一万字？一天俩万字？大家到时候等着就是了。</p><p>今晚是跨年，老齐在这里祝大家</p><p>2016</p><p>六六大顺</p><p>越来越6</p><p>当然，没结婚的女孩子也可以找寻一下另外一个拌，实在找不了，老齐不介意你把老齐娶回家。</p><p>那些还在外面飘的兄弟，新年了，赶快回家吧，爸爸妈妈都等着你的回去呢。</p><p>总之，新的一年，我希望大家都有所改变，但不过，那颗赤子之心却是不能改变的。</p><p>公告：网文联赛本赛季海选阶段最后三周！未参加的小伙伴抓紧了！重磅奖金、成神机会等你来拿！点此参与</p>"];
        
        _readerViewController.content = [m stringOfPage:[page integerValue]];
        _chapterModel = m;
    }];
    
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
    vc.content = [_chapterModel stringOfPage:1];
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
