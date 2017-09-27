//
//  MSHTTPSessionManager.m
//  MStarReader
//
//  Created by Jason on 10/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "MSHTTPSessionManager.h"
#import "MBProgressHUD.h"
#import "JACategory.h"
#import "JAConfigure.h"

typedef NS_ENUM(NSUInteger,MSHttpMethod){
    MSHttpMethodGet,
    MSHttpMethodPost,
    MSHttpMethodPostMultiForm,
    MSHttpMethodPut,
    MSHttpMethodDelete,
};

@implementation MSHTTPSessionManager

+ (instancetype)manager {
    MSHTTPSessionManager *mg = [[MSHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.xyreader.vm/"]];
    mg.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    mg.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    return mg;
}

+ (instancetype)downLoadManager {
    static MSHTTPSessionManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self manager];
        instance.operationQueue.maxConcurrentOperationCount = 3;
    });
    
    return instance;
}

- (BOOL)excludedIndicatorWithURL:(NSString *)URLString {
    // @"http://api.xyreader.com/index",@"http://api.xyreader.com/search",@"http://api.xyreader.com/bl/new",@"http://api.xyreader.com/bl/series",@"http://api.xyreader.com/bl/love",,@"http://api.xyreader.com/shelf",
    
    NSArray *urls = @[@"config",@"rank",@"chapters",@"chapter/",@"comments"];
    for (int i = 0; i < urls.count; ++i) {
        if ([URLString rangeOfString:urls[i]].location != NSNotFound) {
            return true;
        }
    }
    return false;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress *))downloadProgress
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
                     isLoaded:(BOOL)isLoaded {
    
#if DEBUG
    NSLog(@"[JA]:%@%@",self.baseURL,URLString);
#endif
    NSURLCache *urlCache = [NSURLCache sharedURLCache];
    
    /* 设置缓存的大小为5M */
    [urlCache setMemoryCapacity:5 * 1024 * 1024];
    [urlCache setDiskCapacity:20 * 1024 * 1024];
    
    MBProgressHUD *hud = nil;
    if ([URLString rangeOfString:@"index"].location != NSNotFound && isLoaded) {
        hud = [MBProgressHUD showHUDAddedTo:[UIViewController currentViewController].view animated:true];
        hud.userInteractionEnabled = false;
    }else if ([self excludedIndicatorWithURL:URLString] == false && isLoaded) {
        hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
        hud.userInteractionEnabled = false;
    }
    
    NSURLSessionDataTask *task = [super GET:URLString parameters:parameters progress:downloadProgress success:^(NSURLSessionDataTask *task,id responseObject ) {
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
            success(task,[self successWithResponse:responseObject method:MSHttpMethodGet]);
            if (hud) {
                [hud hideAnimated:true afterDelay:1.0];
            }
        }else {
            if (hud) {
                hud.label.text = [responseObject objectForKey:@"msg"];
                [hud hideAnimated:true afterDelay:1.0];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task,NSError *error){
        NSCachedURLResponse *response = [urlCache cachedResponseForRequest:task.originalRequest];
        if (response != nil) {
            if ([task.originalRequest isKindOfClass:[NSMutableURLRequest class]]) {
                [(NSMutableURLRequest *)task.originalRequest setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response.data options:0 error:NULL];
                if (json) {
                    success(task,[self successWithResponse:json method:MSHttpMethodGet]);
                }
            }
            
             hud.label.text = @"无网络连接";
             hud.detailsLabel.text = @"加载缓存...";
             [hud hideAnimated:true afterDelay:1.0];
        }else {
            
            [self showWithError:error hub:hud];
            failure(task,error);
        }
    }];
    
    
    return task;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))downloadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
#if DEBUG
    NSLog(@"[JA]:%@",URLString);
#endif
    NSURLCache *urlCache = [NSURLCache sharedURLCache];
    
    /* 设置缓存的大小为5M */
    [urlCache setMemoryCapacity:5 * 1024 * 1024];
    [urlCache setDiskCapacity:20 * 1024 * 1024];
    
    MBProgressHUD *hud = nil;
    if ([URLString rangeOfString:@"index"].location != NSNotFound && true) {
        hud = [MBProgressHUD showHUDAddedTo:[UIViewController currentViewController].view animated:true];
        hud.userInteractionEnabled = false;
    }else if ([self excludedIndicatorWithURL:URLString] == false && true) {
        hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
        hud.userInteractionEnabled = false;
    }
    
    NSURLSessionDataTask *task = [super GET:URLString parameters:parameters progress:downloadProgress success:^(NSURLSessionDataTask *task,id responseObject ) {
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
            
            success(task,[self successWithResponse:responseObject method:MSHttpMethodGet]);
            if (hud) {
                [hud hideAnimated:true afterDelay:1.0];
            }
        }else {
            
             // MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
            if (hud) {
                hud.label.text = [responseObject objectForKey:@"msg"];
                [hud hideAnimated:true afterDelay:1.0];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task,NSError *error){
        NSCachedURLResponse *response = [urlCache cachedResponseForRequest:task.originalRequest];
        if (response != nil) {
            if ([task.originalRequest isKindOfClass:[NSMutableURLRequest class]]) {
                [(NSMutableURLRequest *)task.originalRequest setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response.data options:0 error:NULL];                
                if (json) {
                    success(task,[self successWithResponse:json method:MSHttpMethodGet]);
                }
            }
            
            // hud.label.text = @"无网络连接";
            // hud.detailsLabel.text = @"加载缓存...";
            // [hud hideAnimated:true afterDelay:1.0];
        }else {

            // [self showWithError:error hub:hud];
            failure(task,error);
        }
    }];
    
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
#if DEBUG
    NSLog(@"%@",URLString);
#endif
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
    
    return [super POST:URLString parameters:parameters progress:uploadProgress success:^(NSURLSessionDataTask *task,id responseObject ) {
        if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
            success(task,[self successWithResponse:responseObject method:MSHttpMethodPost]);
            [hud hideAnimated:true];
        }else {
            hud.label.text = [responseObject objectForKey:@"msg"];
            [hud hideAnimated:true afterDelay:1.0];
        }
        
    } failure:^(NSURLSessionDataTask *task,NSError *error){
        
        [self showWithError:error hub:hud];
        failure(task,error);
    }];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
#if DEBUG
    NSLog(@"%@",URLString);
#endif
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
    
    return [super POST:URLString parameters:parameters constructingBodyWithBlock:block progress:uploadProgress success:^(NSURLSessionDataTask *task,id responseObject ) {
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
            success(task,[self successWithResponse:responseObject method:MSHttpMethodPost]);
            [hud hideAnimated:true];
        }else {
            hud.label.text = [responseObject objectForKey:@"msg"];
            [hud hideAnimated:true afterDelay:1.0];
        }
        
    } failure:^(NSURLSessionDataTask *task,NSError *error){
        
        [self showWithError:error hub:hud];
        failure(task,error);
    }];
    
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
#if DEBUG
    NSLog(@"%@",URLString);
#endif
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
    
    return [super PUT:URLString parameters:parameters success:^(NSURLSessionDataTask *task,id responseObject ) {

        if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
            success(task,[self successWithResponse:responseObject method:MSHttpMethodPut]);
            [hud hideAnimated:true];
        }else {
            hud.label.text = [responseObject objectForKey:@"msg"];
            [hud hideAnimated:true afterDelay:1.0];
        }
        
    } failure:^(NSURLSessionDataTask *task,NSError *error){
        
        [self showWithError:error hub:hud];
        failure(task,error);
    }];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
#if DEBUG
    NSLog(@"%@",URLString);
#endif
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:true];
    
    return [super DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask *task,id responseObject ) {
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
            success(task,[self successWithResponse:responseObject method:MSHttpMethodDelete]);
            [hud hideAnimated:true];
        }else {
            hud.label.text = [responseObject objectForKey:@"msg"];
            [hud hideAnimated:true afterDelay:1.0];
        }
        
    } failure:^(NSURLSessionDataTask *task,NSError *error){
        
        NSLog(@"%@",error);
        [self showWithError:error hub:hud];
        failure(task,error);
    }];
}

- (NSDictionary *)successWithResponse:(id)responseObject method:(MSHttpMethod)method{
    id r = nil;
    if (method == MSHttpMethodGet) {
        if ([[responseObject objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            r = [responseObject objectForKey:@"data"];
        }else if ([[responseObject objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
            r = [responseObject objectForKey:@"data"];
        }
    }else {
        if ([[responseObject objectForKey:@"data"] isKindOfClass:[NSDictionary class]] ||
            [[responseObject objectForKey:@"data"] isKindOfClass:[NSString class]]) {
            r = [responseObject objectForKey:@"data"];
        }
    }
    return r;
}

- (void)showWithError:(NSError *)error hub:(MBProgressHUD *)hud {
    NSLog(@"%@",error);
    // code = -1009 没有网时
    if (error.code >= 500 || error.code == -1009) {
        NSLog(@"%@",error);
        hud.label.text = @"网络状态不佳";
        // [hud showAnimated:true];
    }
    else if (error.code == -1011) {
        
        NSString *errString = [[[NSString alloc] initWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding] componentsSeparatedByString:@":"].lastObject;
        errString = [errString substringToIndex:errString.length - 1];
        hud.label.text = errString;
        [hud showAnimated:true];
    }
    
    [hud hideAnimated:true afterDelay:1.0];
}

- (void)showWithHud:(MBProgressHUD *)hud {
    for (int i = 0; i < 10; ++i) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            hud.progress += 0.1;
        });
    }
}
@end

