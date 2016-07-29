//
//  LGNetworking.h
//  LGNetworking
//
//  Created by 李堪阶 on 16/7/29.
//  Copyright © 2016年 DM. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef enum : NSUInteger{
    
    GET,
    POST,
} RequestMethod;

/**
 *  进度block
 */
typedef void(^Progress)(NSProgress *progress);
/**
 *  完成(成功、失败)block
 */
typedef void(^Finished)(id responseObject,NSError *error);

@interface LGNetworking : AFHTTPSessionManager

+ (instancetype)sharedTools;

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
       finished:(Finished)finished;

/**
 *  下载
 *
 *  @param urlString url
 *  @param progress 进度回调
 *  @param finished  完成回调
 */
- (void)downloadTaskURLString:(NSString *)URLString
                     progress:(Progress)progress
                     finished:(Finished)finished;


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
                   finished:(Finished)finished;

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
                   finished:(Finished)finished;
@end
