//
//  JACatalogViewController.m
//  MStarReader
//
//  Created by Jason on 28/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JACatalogViewController.h"
#import "MSDownloaderCell.h"
#import "MSHTTPSessionManager.h"
#import "MSChapterModel.h"
#import "MSBookModel.h"
#import "MSLinks.h"
#import "MSMetas.h"
#import "MSUtils.h"
#import "MSFloatLayerView.h"
#import "MSChapterListView.h"
#import "MSSelectAllView.h"
#import "MSUserModel.h"
#import "MSDownloaderCell.h"
#import "JACategory.h"
#import "JADBManager.h"
#import "MJRefresh.h"
#import "JAReaderPageViewController.h"
#import "JAReaderConfig.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface JACatalogViewController ()

@property (nonatomic, strong) MSLinks *links;
@property (nonatomic, strong) MSMetas *metas;
@property (nonatomic,assign) int pages;
@property (nonatomic,strong) MSChapterListView *chapterListView;

@end

@implementation JACatalogViewController

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadedAction:)
                                                     name:MSReaderDownloadedNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HexRGB(0xf0f1f5);
    _chapterListView = [[NSBundle mainBundle] loadNibNamed:@"MSChapterListView" owner:nil options:nil].lastObject;
    _chapterListView.type = MSChapterListTypeDownloaded;
    _chapterListView.w = UIScreen.w * 0.85;
    if ([self.context objectForKey:@"book"]) {
        _chapterListView.m = [self.context objectForKey:@"book"];
    }
    
    
    _chapterListView.h = 50;
    typeof(self) weakself = self;
    
    _chapterListView.sortHandler = ^(BOOL isAscending) {
        
        weakself.component.cmodels = [[weakself.component.cmodels reverseObjectEnumerator] allObjects];
        [weakself.component.layout.tableView reloadData];
    };
    
    _chapterListView.downloadHandler = ^(BOOL isHidden) {
        weakself.component.hideFloatLayer = !weakself.component.hideFloatLayer;
        if (isHidden) {
            [weakself.view addSubview:weakself.component.floatLayerView];
            weakself.component.floatLayerView.backgroundColor = HexRGB(0xffffff);
            weakself.component.floatLayerView.rightView.backgroundColor = HexRGB(0xffffff);
            weakself.component.floatLayerView.clipsToBounds = false;
            [weakself.component onStart];
            /*
            if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
                weakself.component.floatLayerView.backgroundColor = HexRGB(0xffffff);
                weakself.component.floatLayerView.rightView.backgroundColor = HexRGB(0xffffff);
                weakself.component.floatLayerView.clipsToBounds = false;
            }else {
                weakself.component.floatLayerView.backgroundColor = HexRGB(0x979797);
                weakself.component.floatLayerView.rightView.backgroundColor = HexRGB(0x979797);
                weakself.component.floatLayerView.clipsToBounds = true;
            }
             */
        }else {
            [weakself.component.floatLayerView removeFromSuperview];
            [weakself.component onStart];
        }
    };
    
    // [self changeThemeAction:nil];
    
    [self.view addSubview:_chapterListView];
    
    _component = [[JACatalogComponent alloc] initWithFrame:CGRectMake(0, _chapterListView.h, UIScreen.w * 0.85, UIScreen.h - _chapterListView.h) view:self.view controller:self];
    
    [_component onCreate];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(changeThemeAction:)
//                                                 name:MSReaderChangeThemeNotification
//                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.datas.count > 0) {
        [self.chapterListView updateChapterListViewWithCount:[self.datas count]];
        self.component.cmodels = self.datas;
        // 效率很差
        if (self.receiverDatas.count > 0) {
            for (int i = 0; i < self.receiverDatas.count; ++i) {
                NSMutableArray *chaptersM = [NSMutableArray array];
                [self.component.cmodels enumerateObjectsUsingBlock:^(MSChapterModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([[obj charterid] isEqualToString:[self.receiverDatas[i] charterid]]) {
                        [chaptersM addObject:self.receiverDatas[i]];
                    }else {
                        [chaptersM addObject:obj];
                    }
                }];
                self.component.cmodels = [chaptersM copy];
            }
            
        }
        
        self.component.bookid = [[self.context objectForKey:@"book"] bookid];
        self.component.num2ids = self.num2ids;
        [self.component onStart];
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(downloadedAction:)
//                                                         name:MSReaderDownloadedNotification
//                                                       object:nil];
//        });
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
}

//- (void)changeThemeAction:(NSNotification *)noti {
//    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
//        self.component.floatLayerView.backgroundColor = HexRGB(0xffffff);
//        self.component.floatLayerView.clipsToBounds = false;
//        self.view.backgroundColor = HexRGB(0xffffff);
//        _chapterListView.backgroundColor = HexRGB(0xffffff);
//        _chapterListView.allChaptersLabel.textColor = [JAConfigure sharedCf].titleFontColor;
//    }else {
//        self.component.floatLayerView.backgroundColor = HexRGB(0x979797);
//        self.component.floatLayerView.rightView.backgroundColor = HexRGB(0x979797);
//        self.component.floatLayerView.clipsToBounds = true;
//        self.view.backgroundColor = HexRGB(0x979797);
//        _chapterListView.backgroundColor = HexRGB(0x979797);
//        _chapterListView.allChaptersLabel.textColor = HexRGB(0x59656a);
//    }
//}

- (void)downloadedAction:(NSNotification *)noti {
    if ([noti.object isKindOfClass:[MSChapterModel class]]) {
        if (self.component == nil) {
            [self.receiverDatas addObject:noti.object];
            return ;
        }
        NSMutableArray *chaptersM = [NSMutableArray array];
        [self.component.cmodels enumerateObjectsUsingBlock:^(MSChapterModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj charterid] isEqualToString:[(MSChapterModel *)noti.object charterid]]) {
                [chaptersM addObject:noti.object];
            }else {
                [chaptersM addObject:obj];
            }
        }];
        
        self.component.cmodels = [chaptersM copy];
    }
}

/// 章节列表
- (void)networkOfChapterListWithCompletion:(void (^)())completion{
    
    NSString *bid = [[self.context objectForKey:@"book"] bookid];
    NSString *bookListURL = [@"chapters/" stringByAppendingString:bid];
    // _component.bookid = bid;
    
    NSDictionary *params = @{@"page":@(self.pages).stringValue};
    [[MSHTTPSessionManager manager] GET:bookListURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([[responseObject objectForKey:@"items"] isKindOfClass:[NSArray class]]) {
            
            NSArray *items = (NSArray *)[responseObject objectForKey:@"items"];
            
            NSMutableArray *itemsM = [NSMutableArray arrayWithCapacity:items.count];
            for (NSDictionary *item in items) {
                MSChapterModel *m = [MSChapterModel yy_modelWithDictionary:item];                
                [self.num2ids setObject:m.charterid forKey:m.num];
                [itemsM addObject:m];
            }
            
            // 查询数据库,获取章节状态
            if (itemsM.count >= 2)  {
                
                JASql *sql = [[[JASql select:@" * " from:[MSChapterModel class]] where:[MSChapterModel pK]] Between:@[[[itemsM firstObject] charterid],[[itemsM lastObject] charterid]]];
                
                NSArray *chapters = [self.dbMg selectObjects:[MSChapterModel class] sql:sql];
                
                if ([chapters isKindOfClass:[MSChapterModel class]]) {
                    chapters = @[chapters];
                }
                
                if ([chapters isKindOfClass:[NSArray class]]) {
                    // 查找出已下载的章节
                    for (int i = 0; i < chapters.count; ++i) {
                        for (int j = 0; j < itemsM.count; ++j) {
                            if ([itemsM[j] charterid] == [chapters[i] charterid]) {
                                // 已下载
                                [itemsM[j] setCState:[chapters[i] cState]];
                            }
                        }
                    }
                }
            }
            
            self.datas = [itemsM copy];
            
            if(completion) {
                completion();
            }            
        }
        
        if ([[responseObject objectForKey:@"_links"] isKindOfClass:[NSDictionary class]]) {
            _links = [MSLinks yy_modelWithDictionary:[responseObject objectForKey:@"_links"]];
        }
        
        if ([[responseObject objectForKey:@"_meta"] isKindOfClass:[NSDictionary class]]) {
            _metas = [MSMetas yy_modelWithDictionary:[responseObject objectForKey:@"_meta"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(self.component);
        }
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.frame = CGRectMake(0, 0, UIScreen.w * 0.85, UIScreen.h);
//    if (self.isShouldReload) {
//        [self.component onStart];
//        self.shouldReload = false;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableDictionary *)num2ids {
    if (!_num2ids) {
        _num2ids = [NSMutableDictionary dictionary];
    }
    return _num2ids;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)receiverDatas {
    if (!_receiverDatas) {
        _receiverDatas = [NSMutableArray array];
    }
    return _receiverDatas;
}
@end

@interface JACatalogComponent ()

@property (nonatomic,strong) NSMutableArray *selectedIds;

@end

@implementation JACatalogComponent

- (void)onCreate {
    [super onCreate];
    [self regWithNibName:@"MSDownloaderCell" height:50 index:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(changeThemeAction:)
//                                                 name:MSReaderChangeThemeNotification
//                                               object:nil];
    
    self.hideFloatLayer = true;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [JAGridComponent reuseIdentifierWithIndexPath:indexPath pairs:self.layout.pairs isTable:true type:JARegTypeCell];
    
    if (reuseIdentifier == nil) {
        NSAssert(false, @"请在 onCreate 方法预先注册可复用的cell");
    }
    
    reuseIdentifier = [reuseIdentifier componentsSeparatedByString:@";"].firstObject;
    
    MSDownloaderCell *c = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    c.type = MSDownloaderCellTypeDownload;
    c.component = self;
    c.indexPath = indexPath;
    
    if ([c respondsToSelector:@selector(injectContent)]) {
        [c injectContent];
    }
    
    /*
    if ([JAReaderConfig defaultConfig].theme == JAReaderThemeTypeNormal) {
        self.layout.tableView.backgroundColor = HexRGB(0xffffff);
        self.layout.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
        
        c.backgroundColor = HexRGB(0xffffff);
        c.cTitleLabel.font = [UIFont systemFontOfSize:15];
        c.cTitleLabel.textColor = [JAConfigure sharedCf].strongFontColor;
        c.detailLabel.font = [UIFont systemFontOfSize:15];
        c.detailLabel.textColor = [JAConfigure sharedCf].contentFontColor;
    }else {
        self.layout.tableView.backgroundColor = HexRGB(0x979797);
        self.layout.tableView.separatorColor = HexRGB(0x59656a);
        c.backgroundColor = HexRGB(0x979797);
        c.cTitleLabel.font = [UIFont systemFontOfSize:15];
        c.cTitleLabel.textColor = HexRGB(0x657076);
        c.detailLabel.font = [UIFont systemFontOfSize:15];
        c.detailLabel.textColor = HexRGB(0x657076);
    }
    */
    
    if (self.isHideFloatLayer) {
        if ([[c cModel] cState] == MSCharterStateNotDownloaded) {
            c.detailLabel.text = @"未下载";
            c.detailLabel.textColor = [JAConfigure sharedCf].titleFontColor;
            c.imgImgView.hidden = true;
            c.detailLabel.hidden = false;
        }
        
    }else {
        if ([[c cModel] cState] == MSCharterStateNotDownloaded) {
            if ([self.selectedIds indexOfObject:[[c cModel] num].stringValue] != NSNotFound) {
                c.imgImgView.image = [UIImage imageNamed:@"icon_multiple-choice_select"];
                c.cSelected = true;
            }
        }
    }
    
    self.layout.tableView.backgroundColor = HexRGB(0xffffff);
    self.layout.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
    
    c.backgroundColor = HexRGB(0xffffff);
    c.cTitleLabel.font = [UIFont systemFontOfSize:15];
    c.cTitleLabel.textColor = [JAConfigure sharedCf].strongFontColor;
    c.detailLabel.font = [UIFont systemFontOfSize:15];
    c.detailLabel.textColor = [JAConfigure sharedCf].contentFontColor;
    
    if ([[[c cModel] num].stringValue isEqualToString:self.readChapterNum]) {
        c.detailLabel.text = @"正在阅读";
        c.detailLabel.textColor = [JAConfigure sharedCf].themeColor;
        c.imgImgView.hidden = true;
        c.detailLabel.hidden = false;
    }
    
    if (c.checkBlock == nil) {
        c.checkBlock = ^(MSDownloaderCell *cell) {
             MSChapterModel *m = self.cmodels[indexPath.row];
            cell.cSelected = !cell.cSelected;
            if (cell.cEdited) {
                cell.imgImgView.image = [UIImage imageNamed:@"icon_multiple-choice_select"];
                [self.selectedIds addObject:m.num.stringValue];
                
            }else {
                cell.imgImgView.image = [UIImage imageNamed:@"icon_multiple-choice_normal"];
                [self.selectedIds removeObject:m.num.stringValue];
                
                [(MSSelectAllView *)_floatLayerView.rightView setSelectedAll:false];
            }
            [self.floatLayerView updateTitleWithGroupId:m.num.stringValue];
        };
    }
    
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MSChapterModel *m = self.cmodels[indexPath.row];
    
//    [m setCState:MSCharterStateReading];
//    
//    MSDownloaderCell *c = [tableView cellForRowAtIndexPath:indexPath];
//    if ([c respondsToSelector:@selector(injectContent)]) {
//        [c injectContent];
//    }
    if (self.hideFloatLayer == false) {
        if (m.cState == MSCharterStateNotDownloaded) {
            MSDownloaderCell *v = [tableView cellForRowAtIndexPath:indexPath];
            v.cEdited = !v.cEdited;
            if (v.cEdited) {
                v.imgImgView.image = [UIImage imageNamed:@"icon_multiple-choice_select"];
                // [self.selectedIds addObject:m.charterid];
                [self.selectedIds addObject:m.num.stringValue];
                
            }else {
                v.imgImgView.image = [UIImage imageNamed:@"icon_multiple-choice_normal"];
                // [self.selectedIds removeObject:m.charterid];
                [self.selectedIds removeObject:m.num.stringValue];
                
                [(MSSelectAllView *)_floatLayerView.rightView setSelectedAll:false];
            }
            // [self.floatLayerView updateTitleWithGroupId:m.charterid];
            [self.floatLayerView updateTitleWithGroupId:m.num.stringValue];
        }
        return ;
    }else {
        self.readChapterNum = m.num.stringValue;
        if([[(JACatalogViewController *)self.cctrl delegate] respondsToSelector:@selector(catalogViewController:num:)]) {
            [[(JACatalogViewController *)self.cctrl delegate] catalogViewController:(JACatalogViewController *)self.cctrl num:m.num.stringValue];
        }
    }
    
}

- (NSMutableArray *)selectedIds {
    if (!_selectedIds) {
        _selectedIds = [NSMutableArray array];
    }
    return _selectedIds;
}

- (NSMutableDictionary *)num2ids {
    if (!_num2ids) {
        _num2ids = [NSMutableDictionary dictionary];
    }
    return _num2ids;
}

- (MSFloatLayerView *)floatLayerView {
    if (!_floatLayerView) {
        typeof(self) weakself = self;
        _floatLayerView = [[MSFloatLayerView alloc] initWithFrame:CGRectMake(0, UIScreen.h, UIScreen.w * 0.85, 120)];
        _floatLayerView.confirmTitle = @"免费下载";
        _floatLayerView.prevTitle = @"已选择:";
        _floatLayerView.nextTitle = @"章节";
        
        MSSelectAllView *allView = [[NSBundle mainBundle] loadNibNamed:@"MSSelectAllView" owner:nil options:nil].firstObject;
        
        allView.selectedHandler = ^(BOOL selectedAll) {
            // 全选
            if (selectedAll) {
                [weakself.selectedIds removeAllObjects];
                for (int i = 0; i < weakself.cmodels.count; ++i) {
                    MSChapterModel *m = weakself.cmodels[i];
                    // [weakself.selectedIds addObject:[m charterid]];
                    if (m.cState == MSCharterStateNotDownloaded) {
                        [weakself.selectedIds addObject:m.num.stringValue];
                    }
                }
                [weakself.floatLayerView updateTitleWithGroupIds:weakself.selectedIds];
            }else {
                for (int i = 0; i < weakself.cmodels.count; ++i) {
                    MSChapterModel *m = weakself.cmodels[i];
                    // [weakself.selectedIds removeObject:[m charterid]];
                    if (m.cState == MSCharterStateNotDownloaded) {
                        [weakself.selectedIds removeObject:m.num.stringValue];
                    }
                }
                [weakself.floatLayerView updateTitleWithGroupIds:weakself.selectedIds];
            }
            
            [weakself.layout.tableView reloadData];
            
        };
        
        _floatLayerView.rightView = allView;
        
        _floatLayerView.completionHandler = ^(NSArray *deleteBookids) {
            if ([AFNetworkReachabilityManager sharedManager].isReachableViaWWAN == true) {
                NSUserDefaults *msDefaults = [NSUserDefaults standardUserDefaults];
                if ([[msDefaults objectForKey:@"allowWifi"] integerValue] ==  1) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
                    hud.label.text = @"3G/4G网络";
                    hud.detailsLabel.text = @"请到个人中心 > 关闭只允许wifi下载";
                    [hud hideAnimated:true afterDelay:2];
                    [weakself.floatLayerView updateTitleWithGroupIds:@[]];
                    return ;
                }
            }
            /// 临时处理,数据库中已存在的章节记录,如果只有一条记录时,变成数组处理
            JASql *sql = [[[[[[JASql select:@" * " from:[MSChapterModel class]] where:[MSChapterModel pK]] In:[weakself.num2ids allValues]] And] field:@"bookid"] Equal:weakself.bookid];
            
            // 所有章节中已在数据库的(即已下载章节)
            NSArray *cs = [weakself.dbMg selectObjects:[MSChapterModel class] sql:sql];
            if ([cs isKindOfClass:[MSChapterModel class]]) { cs = @[cs]; }
            
            /// 服务器最多支持下载50章
            NSArray *downloadSection = [NSArray ja_splitArray:deleteBookids withSubSize:10];
            
            // 进入书籍详情页会将书籍添加到数据库 预检查
            MSBookModel *b = [weakself.dbMg selectObject:[MSBookModel class]
                                               withValue:weakself.bookid];
            
            /// 下载时检查书籍是否在该用户的书架上
            /// 若没有则添加到书架
            MSUserModel *u = [MSUserModel sharedUser];
            u.is_active = true;
            
            NSMutableArray *bookshelfM = [NSMutableArray arrayWithArray:u.bookshelf];
            BOOL isAtShelf = false;
            for (int i = 0; i < u.bookshelf.count; ++i) {
                if ([[u.bookshelf[i] bookid] isEqualToString:b.bookid]) {
                    isAtShelf = true;
                    break;
                }
            }
            
            if (isAtShelf == false) {
                [bookshelfM addObject:b];
            }
            
            u.bookshelf = [bookshelfM copy];
            [u persistence];
            
            
            [cs enumerateObjectsUsingBlock:^(id  _Nonnull dbObj, NSUInteger idx, BOOL * _Nonnull stop) {
                // 更新模型中的cState用于刷新时展示状态
                for (int i = 0; i < weakself.cmodels.count; ++i) {
                    if ([dbObj num] == [weakself.cmodels[i] num]) {
                        [weakself.cmodels[i] setCState:MSCharterStateDownloading];
                    }
                }
            }];
            
            for (int i = 0; i < weakself.cmodels.count; ++i) {
                for (int j = 0; j < deleteBookids.count; ++j) {
                    if ([deleteBookids[j] integerValue] == [[weakself.cmodels[i] num] integerValue]) {
                        [weakself.cmodels[i] setCState:MSCharterStateDownloading];
                    }
                }
            }
            
            [weakself.layout.tableView reloadData];
            
            for (int i = 0; i < downloadSection.count; ++i) {
                NSString *chapters = [downloadSection[i] componentsJoinedByString:@","];
                
                NSString *downloadChapterURL = [[[@"chapter/" stringByAppendingString:weakself.bookid] stringByAppendingString:@"/"] stringByAppendingString:chapters];
                
                [[MSHTTPSessionManager manager] GET:downloadChapterURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        if (b) {
                            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                __block BOOL isAtDb = false;
                                [cs enumerateObjectsUsingBlock:^(id  _Nonnull dbObj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([dbObj bookid] == [obj objectForKey:@"book_id"]) {
                                        // 更新模型中的cState用于刷新时展示状态
                                        for (int i = 0; i < weakself.cmodels.count; ++i) {
                                            if ([dbObj num] == [weakself.cmodels[i] num]) {
                                                [weakself.cmodels[i] setCState:MSCharterStateDownloaded];
                                                isAtDb = true;
                                            }
                                        }
                                    }
                                }];
                                
                                /// 不在数据库,执行添加操作
                                if (isAtDb == false) {
                                    MSChapterModel *m = [MSChapterModel yy_modelWithDictionary:obj];
                                    [m setValue:[weakself.num2ids objectForKey:m.num] forKey:@"charterid"];
                                    [weakself.dbMg insertObject:m];
                                    m.cState = MSCharterStateDownloaded;
                                    [weakself.dbMg updateTableWithObject:m];
                                    
                                    // 更新模型中的cState用于刷新时展示状态
                                    for (int i = 0; i < weakself.cmodels.count; ++i) {
                                        if (m.num == [weakself.cmodels[i] num]) {
                                            [weakself.cmodels[i] setCState:MSCharterStateDownloaded];
                                        }
                                    }
                                    
                                    // 添加章节更新book表
                                    NSMutableArray *bM = [NSMutableArray arrayWithArray:b.charters];
                                    BOOL isAtBook = false;
                                    for (int i = 0; i < b.charters.count; ++i) {
                                        /*
                                        if ([[b.charters[i] charterid] isEqualToString:m.charterid]) {
                                            isAtBook = true;
                                            break;
                                        }*/
                                        
                                        if ([b.charters[i] isEqualToString:m.charterid]) {
                                            isAtBook = true;
                                            break;
                                        }
                                    }
                                    
                                    if (isAtBook == false) {
                                        [bM addObject:m];
                                    }
                                    
                                    b.charters = [bM copy];
                                    [weakself.dbMg updateTableWithObject:b];
                                }else {
                                    
                                }
                            }];
                            [weakself.layout.tableView reloadData];
                        }
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                }];
            }            
        };
    }
    return _floatLayerView;
}


- (void)changeThemeAction:(NSNotification *)noti {
    [self onStart];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
