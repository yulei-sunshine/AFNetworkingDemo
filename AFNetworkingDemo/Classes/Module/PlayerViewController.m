//
//  PlayerViewController.m
//  AFNetworkingDemo
//
//  Created by yulei on 15/8/4.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import "PlayerViewController.h"

@import MediaPlayer;
@import AVFoundation;

@interface PlayerViewController ()

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateContentView];
    [self loadContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateContentView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeContentView];
}

- (void)loadContentView {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    //http://mvvideo1.meitudata.com/55af84048ba8c4524.mp4
    //http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4
    NSURL *movieURL = [NSURL URLWithString:@"http://mvvideo1.meitudata.com/55af84048ba8c4524.mp4"];
    NSLog(@"movie url is %@",[movieURL absoluteString]);
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    [self.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    //[self.moviePlayer setMovieSourceType:MPMovieSourceTypeStreaming];
    [self.moviePlayer setRepeatMode:MPMovieRepeatModeNone];
    [self.moviePlayer setScalingMode:MPMovieScalingModeFill];
    [self.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [self.moviePlayer.view setFrame:self.view.bounds];
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer prepareToPlay];
    
    NSLog(@"movie player is %@,view bounds is %@",self.moviePlayer,NSStringFromCGRect(self.moviePlayer.view.bounds));
}

- (void)updateContentView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieReadyForDisplayCallback:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)removeContentView {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

#pragma mark - Response Event

- (void)exit {
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification

- (void)movieReadyForDisplayCallback:(NSNotification *)notification {
    NSLog(@"movieReadyForDisplayCallback");
}

- (void)movieFinishedCallback:(NSNotification *)notification {
    NSLog(@"movieFinishedCallback");
    
    //[self exit];
}

@end
