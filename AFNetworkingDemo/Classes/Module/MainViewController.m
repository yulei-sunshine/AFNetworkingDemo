//
//  MainViewController.m
//  AFNetworkingDemo
//
//  Created by yulei on 15/8/4.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import "MainViewController.h"
#import "NetworkConfig.h"
#import "LocalFileManager.h"

#import "PlayerViewController.h"

@interface MainViewController ()

//测试下载
@property (strong, nonatomic) NetworkDownloadTask *downTask;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self layoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutSubviews {
    UIButton *button_start = [[UIButton alloc] initWithFrame:CGRectMake(0, 80.0f, CGRectGetWidth(self.view.bounds), 62.0f)];
    [button_start setBackgroundColor:[UIColor grayColor]];
    [button_start setTitle:@"开始" forState:UIControlStateNormal];
    [button_start setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button_start.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [button_start addTarget:self action:@selector(startButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_start];
    
    UIButton *button_pause = [[UIButton alloc] initWithFrame:CGRectMake(0, 162.0f, CGRectGetWidth(self.view.bounds), 62.0f)];
    [button_pause setBackgroundColor:[UIColor grayColor]];
    [button_pause setTitle:@"暂停" forState:UIControlStateNormal];
    [button_pause setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button_pause.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [button_pause addTarget:self action:@selector(pauseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_pause];
    
//    UIButton *button_resume = [[UIButton alloc] initWithFrame:CGRectMake(0, 244.0f, CGRectGetWidth(self.view.bounds), 62.0f)];
//    [button_resume setBackgroundColor:[UIColor grayColor]];
//    [button_resume setTitle:@"恢复" forState:UIControlStateNormal];
//    [button_resume setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [button_resume.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
//    [button_resume addTarget:self action:@selector(resumeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button_resume];
    
    UIButton *button_play = [[UIButton alloc] initWithFrame:CGRectMake(0, 326.0f, CGRectGetWidth(self.view.bounds), 62.0f)];
    [button_play setBackgroundColor:[UIColor grayColor]];
    [button_play setTitle:@"播放" forState:UIControlStateNormal];
    [button_play setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button_play.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [button_play addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_play];
}

#pragma mark - Event Response

//start
- (void)startButtonClick:(id)sender {
    //测试小视频 size order by asc
    //http://mvvideo1.meitudata.com/55bd3b3d764b14118.mp4
    //http://mvvideo1.meitudata.com/55ba8abe456d54702.mp4
    //http://mvvideo1.meitudata.com/55af84048ba8c4524.mp4
    
    
    //测试大视频
    //http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4
    
    NSString *filePath = [[[LocalFileManager manager] videoFilePath] stringByAppendingPathComponent:@"test.mp4"];
    NSString *urlStr = @"http://mvvideo1.meitudata.com/55ba8abe456d54702.mp4";
    
    if (![[LocalFileManager manager] isExistFile:filePath]) {
        NSLog(@"file path is %@",filePath);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        self.downTask = [[NetworkDownloadTask alloc] initWithRequest:request
                                                          targetPath:filePath
                                                        shouldResume:YES];
        [self.downTask defaultDownloadTask];
        [self.downTask downloadTaskProgress:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            NSLog(@"bytesWritten is %lld, totalBytesWritten is %lld, totalBytesExpectedToWrite is %lld",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        }];
        [self.downTask downloadTaskCompletion:^(NSURL *filePath) {
            NSLog(@"download completion faile path is %@",[filePath absoluteString]);
        } Failure:^(NSError *error) {
            NSLog(@"download error is %@",[error localizedDescription]);
        }];
    } else {
        NSLog(@"file is exists");
    }
}

//pause
- (void)pauseButtonClick:(id)sender {
    [self.downTask cancel];
    self.downTask = nil;
}

//resume
- (void)resumeButtonClick:(id)sender {
    //[self.downTask suspend];
}

//play
- (void)playButtonClick:(id)sender {
    PlayerViewController *viewController = [[PlayerViewController alloc] init];
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
