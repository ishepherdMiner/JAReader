//
//  JAReaderViewController.m
//  MStarReader
//
//  Created by Jason on 22/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderViewController.h"
#import <YYText.h>
#import "JAReaderPageView.h"
#import "JACategory.h"
#import "JAReaderConfig.h"
#import "JAReaderParser.h"

@interface JAReaderViewController ()

@property (nonatomic,strong) YYLabel *textLabel;
@property (nonatomic, strong) JAReaderPageView *pageView;

@end

@implementation JAReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.pageView];
    [self.view addSubview:self.textLabel];
}

- (void)setContent:(NSString *)content {
    _content = content;
    _textLabel.attributedText = [[NSAttributedString alloc] initWithString:_content];
}

- (JAReaderPageView *)pageView {
    if (!_pageView) {
        _pageView = [[JAReaderPageView alloc] initWithFrame:CGRectMake(20, 40, UIScreen.w - 40, 40)];
        JAReaderConfig *config = [JAReaderConfig sharedReaderConfig];
        _pageView.frameRef = [JAReaderParser parserContent:_content config:config bouds:_pageView.bounds];
        
        _pageView.content = _content;
        // _readView.delegate = self;
    }
    return _pageView;
}

- (YYLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[YYLabel alloc] initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height - 84)];
        _textLabel.numberOfLines = 0;
        // _textLabel.attributedText = [[NSAttributedString alloc] initWithString:@"<p>    本来是没打算上架的，但不过大家都劝着上架，老齐对于上架之后能干什么也很好奇，抱着这种好奇的心，元旦，未婚妻终于迎来了上架。</p><p>对于那些一直支持老齐的书的兄弟姐妹，老齐在这里给你们鞠躬至谢了，有你们的陪伴，孤独的我，才找到了安慰的地方。</p><p>我看了，不管是哪里的，盗版的也好，还是正版的，都有骂老齐更新慢，今天老齐把话搁这里了，下星期一开始，未婚妻将迎来大爆更，一天一万字？一天俩万字？大家到时候等着就是了。</p><p>今晚是跨年，老齐在这里祝大家</p><p>2016</p><p>六六大顺</p><p>越来越6</p><p>当然，没结婚的女孩子也可以找寻一下另外一个拌，实在找不了，老齐不介意你把老齐娶回家。</p><p>那些还在外面飘的兄弟，新年了，赶快回家吧，爸爸妈妈都等着你的回去呢。</p><p>总之，新的一年，我希望大家都有所改变，但不过，那颗赤子之心却是不能改变的。</p><p>公告：网文联赛本赛季海选阶段最后三周！未参加的小伙伴抓紧了！重磅奖金、成神机会等你来拿！点此参与</p> "];
    }
    return _textLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
