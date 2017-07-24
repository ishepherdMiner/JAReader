//
//  MSCommentModel.h
//  MStarReader
//
//  Created by Jason on 05/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JACellModel.h"

@interface MSCommentModel : JACellModel

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *star_level;
@property (nonatomic, copy) NSString *crt_time;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *username;

@end
