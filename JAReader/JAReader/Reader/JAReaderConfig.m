//
//  JAReaderConfig.m
//  MStarReader
//
//  Created by Jason on 23/06/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "JAReaderConfig.h"
#import "JAConfigure.h"

@implementation JAReaderConfig

+ (instancetype)defaultConfig {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSUserDefaults *msDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *msReaderDic = [NSMutableDictionary dictionaryWithDictionary:[msDefaults objectForKey:@"msreader"]];
        if ([msReaderDic objectForKey:@"theme"] == nil) {
            self.theme = JAReaderThemeTypeNormal;
        }else {
            self.theme = [[msReaderDic objectForKey:@"theme"] integerValue];
        }
        [self addObserver:self forKeyPath:@"theme" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"fontSize" options:NSKeyValueObservingOptionNew context:NULL];
        // [self addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (NSDictionary *)attributes {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = self.fontColor;
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:self.fontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSpace;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return [dict copy];    
}

- (void)setTheme:(JAReaderThemeType)theme {
    _theme = theme;
    NSUserDefaults *msDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *msReaderDic = [NSMutableDictionary dictionaryWithDictionary:[msDefaults objectForKey:@"msreader"]];
    if ([msReaderDic objectForKey:@"fontSize"] == nil) {
        self.fontSize = 17;
    }else {
        self.fontSize = [[msReaderDic objectForKey:@"fontSize"] integerValue];
    }
    
    self.lineSpace = 12;
    
    if (theme == JAReaderThemeTypeNormal) {
        self.bgColor = [UIColor whiteColor];
        self.fontColor = [JAConfigure sharedCf].strongFontColor;
    }else if (theme == JAReaderThemeTypeNight) {
        self.bgColor = [UIColor colorWithHue:0 saturation:0 brightness:0.1 alpha:1];
        self.fontColor = [UIColor colorWithHue:0 saturation:0 brightness:0.5 alpha:1];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSUserDefaults *msDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *msReaderDic = [NSMutableDictionary dictionaryWithDictionary:[msDefaults objectForKey:@"msreader"]];
    if ([keyPath isEqualToString:@"theme"]) {
        [msReaderDic setObject:@(self.theme) forKey:@"theme"];
    }else if ([keyPath isEqualToString:@"fontSize"]) {
        [msReaderDic setObject:@(self.fontSize) forKey:@"fontSize"];
    }
    [msDefaults setObject:msReaderDic forKey:@"msreader"];
    [msDefaults synchronize];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"theme"];
    [self removeObserver:self forKeyPath:@"fontSize"];
    // [self removeObserver:self forKeyPath:@"brightness"];
}


@end
