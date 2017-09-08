//
//  Z_controller.m
//  xlinkDemo
//
//  Created by kingcom on 2017/3/13.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Z_controller.h"
#import "CameraReplayController.h"
#import "CameraSettingController.h"
#import "RtspViewController.h"

@interface Z_controller ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate>

@end

@implementation Z_controller

-(void)PushCameraReplayController{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CameraReplayController *view = [storyBoard instantiateViewControllerWithIdentifier:@"CameraReplayController"];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)PushCameraSettingController{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CameraSettingController *view = [storyBoard instantiateViewControllerWithIdentifier:@"CameraSettingController"];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)PushRtspViewController{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RtspViewController *view = [storyBoard instantiateViewControllerWithIdentifier:@"RtspViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)Return{
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
    self.navigationItem.title=NSLocalizedString(@"ZCameras",comment: "");
    
}

#pragma mark btn

- (IBAction)btn_play:(id)sender {
    [self PushRtspViewController];
}

- (IBAction)btn_replay:(id)sender {
    [self PushCameraReplayController];
}

- (IBAction)btn_setting:(id)sender {
    [self PushCameraSettingController];
}
@end

