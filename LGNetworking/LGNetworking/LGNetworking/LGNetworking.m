//
//  LGNetworking.m
//  LGNetworking
//
//  Created by 李堪阶 on 16/7/29.
//  Copyright © 2016年 DM. All rights reserved.
//

#import "LGNetworking.h"
@protocol NetworkToolsProxy <NSObject>

@optional
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end

@interface LGNetworking ()<NetworkToolsProxy>

@end

@implementation LGNetworking

+ (instancetype)sharedTools{
    
    static  LGNetworking *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LGNetworking alloc]initWithBaseURL:nil];
        
        instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
        instance.requestSerializer.timeoutInterval = 20;
        
    });
    
    return instance;
}

/**
 *  POST GET请求
 *
 *  @param method     请求方法
 *  @param urlString  url
 *  @param parameters 参数
 *  @param progress   进度
 *  @param finished   完成回调
 */
- (void)request:(RequestMethod)method
      urlString:(NSString *)urlString
     parameters:(id)parameters
       progress:(Progress)progress
       finished:(Finished)finished{
    
    NSString *methodString = (method == GET) ? @"GET":@"POST";
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    
    [[self dataTaskWithHTTPMethod:methodString URLString:urlString parameters:parameters uploadProgress:^(NSProgress *uploadProgress) {
        
        progress(uploadProgress);
        
    } downloadProgress:^(NSProgress *downloadProgress) {
        progress(downloadProgress);
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        finished(responseObject,nil);
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        finished(nil,error);
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    }]resume];
}

/**
 *  下载
 *
 *  @param urlString url
 *  @param progress 进度回调
 *  @param finished  完成回调
 */
- (void)downloadTaskURLString:(NSString *)URLString
                     progress:(Progress)progress
                     finished:(Finished)finished{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    [[self downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        progress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //创建目录
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager]URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        NSURL *URL = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
        return URL;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        finished(filePath,error);
    }]resume];
}

/**
 *  上传单张图片
 *
 *  @param urlString  url
 *  @param image      图片
 *  @param imageName  图片名称
 *  @param parameters 参数
 *  @param progress   进度回调
 *  @param finished   完成回调
 */
- (void)uploadTaskURLString:(NSString *)URLString
                  withImage:(UIImage *)image
              withImageName:(NSString *)imageName
             withParameters:(id)parameters
                   progress:(Progress)progress
                   finished:(Finished)finished{
    
    [[self POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //压缩图片
        NSData *data = UIImageJPEGRepresentation(image, 0.5);
        
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",imageName];
        
        //@"userfile"、@"application/octet-stream" 可根据后台更改
        [formData appendPartWithFileData:data name:@"userfile" fileName:fileName mimeType:@"application/octet-stream"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        finished(responseObject,nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finished(nil,error);
    }] resume];
}

/**
 *  上传文件
 *
 *  @param urlString  url
 *  @param parameters 参数
 *  @param filePath   文件路径
 *  @param fileName   文件名
 *  @param progress   进度
 *  @param finished   完成回调
 */
- (void)uploadTaskURLString:(NSString *)URLString
               withFilePath:(NSString *)filePath
               withFileName:(NSString *)fileName
             withParameters:(id)parameters
                   progress:(Progress)progress
                   finished:(Finished)finished{

    [[self POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *data = [[NSFileManager defaultManager]contentsAtPath:filePath];
        
        //@"userfile"、@"application/octet-stream" 可根据后台更改
        [formData appendPartWithFileData:data name:@"userfile" fileName:fileName mimeType:@"application/octet-stream"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        finished(responseObject,nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finished(nil,error);
    }] resume];
}

@end
