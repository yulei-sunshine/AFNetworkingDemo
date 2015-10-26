//
//  NetworkDownloadTask.m
//  AFNetworkingDemo
//
//  Created by yulei on 15/7/23.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import "NetworkDownloadTask.h"
#import "AFNetworking.h"
#import "NSString+Expand.h"
#import "LocalFileManager.h"

@interface NetworkDownloadTask ()

//session
@property (strong, nonatomic) AFURLSessionManager *sessionManager;
//请求
@property (strong, nonatomic) NSURLRequest *taskRequest;
//是否缓存
@property (assign) BOOL resumeStatus;
//文件地址
@property (strong, nonatomic) NSURL *taskFilePath;
//下载信息缓存地址
@property (copy, nonatomic) NSString *taskDownloadCachePath;
//文件缓存地址
@property (copy, nonatomic) NSString *taskResumeCachePath;
//下载任务
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
//可恢复下载任务的数据
@property (strong, nonatomic) NSData *partialData;

@end

@implementation NetworkDownloadTask

#pragma mark - Private Interface

//判断下载信息缓存是否存在
- (BOOL)resumeDataExists {
    return [[LocalFileManager manager] isExistFile:self.taskDownloadCachePath];
}

//判断文件缓存是否存在
- (BOOL)resumeFileExists {
    return [[LocalFileManager manager] isExistFile:self.taskResumeCachePath];
}

//修改缓存数据
- (BOOL)modifyResumeDataLocalPath {
    if (!self.resumeStatus) {
        if (self.partialData != nil) {
            return YES;
        } else {
            return NO;
        }
    }

    if (![self resumeDataExists]) {
        return NO;
    }
    
    if (![self resumeFileExists]) {
        return NO;
    }
    
    NSError *error;
    NSData *resumeData = [NSData dataWithContentsOfFile:self.taskDownloadCachePath
                                                options:NSDataReadingMappedIfSafe
                                                  error:&error];
    if (error != nil) {
        return NO;
    }
    
    NSError *error_dict = nil;
    NSMutableDictionary *tmpDict = [NSPropertyListSerialization propertyListWithData:resumeData
                                                                             options:0
                                                                              format:nil
                                                                               error:&error_dict];
    NSLog(@"tmp dict is %@",tmpDict);
    NSLog(@"dict error is %@",[error_dict localizedDescription]);
//    if (error_dict == nil) {
//        //3.0版本后使用
//        NSString *resumeTmpFileName = [tmpDict objectForKey:@"NSURLSessionResumeInfoTempFileName"];
//        if (resumeTmpFileName != nil) {
//            NSString *resumeTmpPath = [[[LocalFileManager manager] tmpPath] stringByAppendingPathComponent:resumeTmpFileName];
//            [];
//        }
//        
//        
//        
//        
//        //NSString *resumeLocalPath = [tmpDict objectForKey:@"NSURLSessionResumeInfoLocalPath"];
//        NSString *resumeTmpFileName = [tmpDict objectForKey:@"NSURLSessionResumeInfoTempFileName"];
//        
//        
//        
//        
//        NSString *resumeLocalPath = [tmpDict objectForKey:@"NSURLSessionResumeInfoLocalPath"];
//        if (resumeLocalPath != nil) {
//            [tmpDict setObject:[self resumeFilePath] forKey:@"NSURLSessionResumeInfoLocalPath"];
//            
//            NSError *error_data = nil;
//            NSData *tmp_data = [NSPropertyListSerialization dataWithPropertyList:tmpDict
//                                                                          format:NSPropertyListBinaryFormat_v1_0
//                                                                         options:0
//                                                                           error:&error_data];
//            if (error_data == nil) {
//                self.partialData = tmp_data;
//                return YES;
//            }
//        }
//    }
    return NO;
}

//移动缓存文件
- (BOOL)moveResumeFile:(NSData *)resumeData {
    if (resumeData == nil) {
        return NO;
    }
    
    NSError *error_dict = nil;
    NSMutableDictionary *tmpDict = [NSPropertyListSerialization propertyListWithData:resumeData
                                                                             options:0
                                                                              format:nil
                                                                               error:&error_dict];
    NSLog(@"tmp dict is %@",tmpDict);
    NSLog(@"dict error is %@",[error_dict localizedDescription]);
//    if (error_dict == nil) {
//        //NSString *resumeLocalPath = [tmpDict objectForKey:@"NSURLSessionResumeInfoLocalPath"];
//        NSString *resumeTmpFileName = [tmpDict objectForKey:@"NSURLSessionResumeInfoTempFileName"];
//        NSString *resumeTmpPath = [[[LocalFileManager manager] tmpPath] stringByAppendingPathComponent:resumeTmpFileName];
//        NSLog(@"resumeTmpPath is %@",resumeTmpPath);
//        if ([[LocalFileManager manager] isExistFile:resumeTmpPath]) {
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            return [fileManager moveItemAtPath:resumeTmpPath toPath:self.taskResumeCachePath error:nil];
//        } else {
//            return NO;
//        }
//    }
    return NO;
}

//下载信息缓存数据本地保存
- (BOOL)saveResumeData:(NSData *)resumeData {
    if (resumeData == nil) {
        self.partialData = nil;
        return NO;
    }
    
    if (!self.resumeStatus) {
        self.partialData = resumeData;
        return YES;
    }

    self.partialData = resumeData;
    
    NSLog(@"taskDownloadCachePath is %@",self.taskDownloadCachePath);
    return [self.partialData writeToFile:self.taskDownloadCachePath atomically:YES];
}

//清楚文件缓存
- (void)cleanResumeData {
    if ([self resumeDataExists]) {
        [[LocalFileManager manager] deleteFileWithTargetPath:self.taskDownloadCachePath];
    }

    if ([self resumeFileExists]) {
        [[LocalFileManager manager] deleteFileWithTargetPath:self.taskResumeCachePath];
    }

    self.partialData = nil;
}

//创建普通下载任务
- (void)createDownloadTask {
    self.downloadTask = [self.sessionManager downloadTaskWithRequest:self.taskRequest progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return self.taskFilePath;
    } completionHandler:^void(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error == nil) {
            //下载成功清除下载信息缓存及文件缓存
            [self cleanResumeData];
            
            if (self.completionBlock) {
                self.completionBlock(filePath);
            }
        } else {
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        }
    }];
    [self.downloadTask resume];
}

//创建缓存下载任务
- (void)createResumeDownloadTask {
    self.downloadTask = [self.sessionManager downloadTaskWithResumeData:self.partialData progress:nil destination:^NSURL*(NSURL *targetPath, NSURLResponse *response) {
        return self.taskFilePath;
    } completionHandler:^void(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error == nil) {
            //下载成功清除下载信息缓存及文件缓存
            [self cleanResumeData];
            
            if (self.completionBlock) {
                self.completionBlock(filePath);
            }
        } else {
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        }
    }];
    [self.downloadTask resume];
}

//开始
- (void)start {
    if (self.downloadTask.state == NSURLSessionTaskStateCompleted) {
        return ;
    }

    //判断是否存在缓存
    if ([self modifyResumeDataLocalPath]) {
        [self createResumeDownloadTask];
    } else {
        [self createDownloadTask];
    }
}

#pragma mark - Open Method

//初始化
//parmeters : 请求/保存地址/是否缓存
- (instancetype)initWithRequest:(NSURLRequest *)_request
                     targetPath:(NSString *)_filePath
                   shouldResume:(BOOL)_status {
    if (self = [super init]) {
        self.taskRequest = _request;
        self.taskFilePath = [NSURL fileURLWithPath:_filePath];
        self.resumeStatus = _status;
        self.partialData = nil;

        NSString *resumeCacheName = [_request.URL.absoluteString MD5Hash];
        NSString *resumeCachePath = [[[LocalFileManager manager] cacheFilePath] stringByAppendingPathComponent:resumeCacheName];
        self.taskDownloadCachePath = resumeCachePath;
        self.taskResumeCachePath = [resumeCachePath stringByAppendingPathExtension:@"tmp"];
        resumeCacheName = nil;
        resumeCachePath = nil;
    }
    return self;
}

//创建普通下载任务
- (void)defaultDownloadTask {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    [self start];
}

//创建后台下载任务
- (void)backgroundDownloadTask:(NSString *)identifier {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    [self start];
}

//下载进度
- (void)downloadTaskProgress:(void(^)(int64_t bytesWritten,
                                      int64_t totalBytesWritten,
                                      int64_t totalBytesExpectedToWrite))progressBlock {
    [self.sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        progressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }];
}

//下载进度
- (NSProgress *)downloadTaskProgress {
    return [self.sessionManager downloadProgressForTask:self.downloadTask];
}

//下载完成
- (void)downloadTaskCompletion:(void (^)(NSURL *filePath))completion
                       Failure:(void (^)(NSError *error))failure {
    self.completionBlock = completion;
    self.failureBlock = failure;
}

//暂停
- (void)suspend {
    if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
        [self.downloadTask suspend];
    }
}

//继续
- (void)resume {
    //完成状态
    if (self.downloadTask.state == NSURLSessionTaskStateSuspended) {
        [self.downloadTask resume];
    }
}

//取消
- (void)cancel {
    if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
        if (self.resumeStatus) {
            [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                //移动缓存文件
                if (self.resumeStatus && ![self resumeFileExists]) {
                    [self moveResumeFile:resumeData];
                }
                
                //保存缓存
                [self saveResumeData:resumeData];
            }];
        } else {
            [self.downloadTask cancel];
        }
    }
}

@end
 