//
//  JACatalogViewController.h
//  MStarReader
//
//  Created by Jason on 28/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAViewController.h"
#import "JAGridComponent.h"

@class MSFloatLayerView,JACatalogComponent,JACatalogViewController,MSRecordModel;

@protocol JACatalogViewControllerDelegate <NSObject>

- (void)catalogViewController:(JACatalogViewController *)catalogVC num:(NSString *)num;
- (void)catalogViewController:(JACatalogViewController *)catalogVC record:(MSRecordModel *)record;

@end

@interface JACatalogViewController : JAViewController

@property (nonatomic,strong) JACatalogComponent *component;
@property (nonatomic,weak) id<JACatalogViewControllerDelegate> delegate;
@property (nonatomic,strong) NSMutableDictionary *num2ids;

@property (nonatomic,assign,getter=isShouldReload) BOOL shouldReload;
/// 所有的章节序号
@property (nonatomic,strong) NSArray *datas;

/// 当self.component == nil时,接收存在的章节对象
@property (nonatomic,strong) NSMutableArray *receiverDatas;

- (void)networkOfChapterListWithCompletion:(void (^)())completion;


@end

@interface JACatalogComponent : JATableComponent

@property (nonatomic,copy) NSString *bookid;
@property (nonatomic,strong) MSFloatLayerView *floatLayerView;

@property (nonatomic,strong) NSString *readChapterNum;
/// 临时方案:保存章节中num和id的关系,为了下载时能将内容添加到数据库中
@property (nonatomic,strong) NSMutableDictionary *num2ids;

@property (nonatomic,assign,getter=isHideFloatLayer) BOOL hideFloatLayer;

@end
