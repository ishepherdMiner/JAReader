//
//  JARelateModel.h
//  MStarReader
//
//  Created by Jason on 20/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAModel.h"

@interface JARelateModel : JAModel

@property (nonatomic, copy) NSString *rid; // 主键
@property (nonatomic, copy) NSString *key; /// 属性名
@property (nonatomic, copy) NSString *relateTableName; /// 对应的表名
// @property (nonatomic, copy) NSString *relateValues;  /// 属性值数组(对模型而言是只有一个元素的数组

@end
