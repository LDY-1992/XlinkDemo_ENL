//
//  RtspViewController.m
//  xlinkDemo
//
//  Created by kingcom on 2017/3/31.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RtspViewController.h"


@interface RtspViewController ()

@end

@implementation RtspViewController

-(void)Return{
    [self.player stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad

{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = NO;
    UIBarButtonItem *nullItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回",comment: "") style:UIBarButtonItemStylePlain target:self action:@selector(Return)];
    self.navigationItem.leftBarButtonItem = nullItem;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title=NSLocalizedString(@"ZCamerasPlay",comment: "");
    
    [self.Indicator setHidden:NO];
    [self.Indicator setHidesWhenStopped:YES];
    [self.Indicator startAnimating]; // 开始旋转
    
    NSString *path = @"";
    
    NSString *audio_switch = [[NSUserDefaults standardUserDefaults] objectForKey:AUDIO_SWITCH];
    NSString *audio_volume=[[NSUserDefaults standardUserDefaults] objectForKey:AUDIO_VOLUME];
    NSString *video_resolution=[[NSUserDefaults standardUserDefaults] objectForKey:VIDEO_RESOLUTION];
    NSString *kxmove_buffer=[[NSUserDefaults standardUserDefaults] objectForKey:KXMOVE_BUFFER];
    
    NSLog(@"audio_switch=%@  audio_volume=%@  video_resolution=%@  kxmove_buffer=%@",audio_switch,audio_volume,video_resolution,kxmove_buffer);
    
    if([audio_switch isEqualToString:@"YES"]){
        path=[NSString stringWithFormat:@"%@/v%@&a%@",SERVERADDR,video_resolution,audio_volume];
    }else if([audio_switch isEqualToString:@"NO"]){
        path=[NSString stringWithFormat:@"%@/v%@&a0",SERVERADDR,video_resolution];
    }
    NSLog(@"path=%@",path);
    NSMutableDictionary *mediaDictonary = [NSMutableDictionary new];
    [mediaDictonary setObject:kxmove_buffer forKey:@"network-caching"];
    VLCMediaPlayer *player = [[VLCMediaPlayer alloc] init];
    self.player = player;
    // 播放时候的载体
    self.player.drawable = _ShowView;
    NSURL *url = [NSURL URLWithString:path];
    // 对象给他
    self.player.media = [VLCMedia mediaWithURL:url];
    [self.player.media addOptions:mediaDictonary];
    self.player.delegate=self;
    //开始播放
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VLCMediaPlayerDelegate
// 播放状态改变的回调
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
    /**
     *  VLCMediaPlayerStateStopped,        //< Player has stopped
     VLCMediaPlayerStateOpening,        //< Stream is opening
     VLCMediaPlayerStateBuffering,      //< Stream is buffering
     VLCMediaPlayerStateEnded,          //< Stream has ended
     VLCMediaPlayerStateError,          //< Player has generated an error
     VLCMediaPlayerStatePlaying,        //< Stream is playing
     VLCMediaPlayerStatePaused          //< Stream is paused
     */
    NSLog(@"mediaPlayerStateChanged");
    NSLog(@"状态：%ld",(long)_player.state);
    switch ((int)_player.state) {
        case VLCMediaPlayerStateBuffering: // 播放中缓冲状态
        {
            // 显示菊花
            if (!self.Indicator.isAnimating) {
                [self.Indicator startAnimating];
            }
        }
            break;
        case VLCMediaPlayerStatePlaying: // 被暂停后开始播放
        {
            // 显示菊花
            if (self.Indicator.isAnimating) {
                [self.Indicator stopAnimating];
            }
        }
            break;
            
    }
}

// 播放时间改变的回调
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
    //    NSLog(@"mediaPlayerTimeChanged");
}

@end
