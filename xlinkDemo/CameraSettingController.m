//
//  CameraSettingController.m
//  xlinkDemo
//
//  Created by kingcom on 2017/3/16.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraSettingController.h"
#import "UIView+Toast.h"

@interface CameraSettingController ()

@end

@implementation CameraSettingController

-(void)Return{
    int n=_Slider_Audio.value;
    NSString *sh=[NSString stringWithFormat:@"%d",n];
    [[NSUserDefaults standardUserDefaults] setObject:sh forKey:AUDIO_VOLUME];
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
    self.navigationItem.title=NSLocalizedString(@"ZCamerasSetting",comment: "");
    
    NSString *audio_switch = [[NSUserDefaults standardUserDefaults] objectForKey:AUDIO_SWITCH];
    NSString *audio_volume=[[NSUserDefaults standardUserDefaults] objectForKey:AUDIO_VOLUME];
    NSString *video_resolution=[[NSUserDefaults standardUserDefaults] objectForKey:VIDEO_RESOLUTION];
    
    
    if([video_resolution isEqualToString:@"720"]){
        [_Switch_resolution setOn:YES];
    }else{
        [_Switch_resolution setOn:NO];
    }
    
    if([audio_switch isEqualToString:@"YES"]){
        [_Switch_Audio setOn:YES];
        [_Slider_Audio setEnabled:YES];
        int n=[audio_volume intValue];
        _Slider_Audio.value=n;
    }else{
        [_Switch_Audio setOn:NO];
        [_Slider_Audio setEnabled:NO];
        int n=[audio_volume intValue];
        _Slider_Audio.value=n;
    }
    
    
        
}

//网络缓存设置弹出框
- (void)alertController
{
    NSString *kxmove_buffer=[[NSUserDefaults standardUserDefaults] objectForKey:KXMOVE_BUFFER];
    NSString *mes=[NSString stringWithFormat:@"当前网络延时为：%@ms，请输入网络延时：",kxmove_buffer];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:mes preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加按钮
    __weak typeof(alert) weakAlert = alert;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        //NSLog(@"点击了确定按钮--%@-%@", [weakAlert.textFields.firstObject text], [weakAlert.textFields.lastObject text]);
        NSString *buff=[weakAlert.textFields.firstObject text];
        if([self deptNumInputShouldNumber:buff]){
            [self.view makeToast:@"请输入0-1000数字."];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:buff forKey:KXMOVE_BUFFER];
        }
       
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //NSLog(@"点击了取消按钮");
    }]];
    
    // 添加文本框
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"输入0-1000ms网络缓存";  // 提示文本
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL) deptNumInputShouldNumber:(NSString *)str
{
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if (![pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

#pragma mark btn


- (IBAction)Action_Switch_Resolution:(id)sender {
    if([_Switch_resolution isOn]){
        [[NSUserDefaults standardUserDefaults] setObject:@"720" forKey:VIDEO_RESOLUTION];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"480" forKey:VIDEO_RESOLUTION];
    }
    
}

- (IBAction)Action_Switch_Audio:(id)sender {
    if([_Switch_Audio isOn]){
        [_Slider_Audio setEnabled:YES];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:AUDIO_SWITCH];
    }else{
        [_Slider_Audio setEnabled:NO];
        _Slider_Audio.value=0;
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:AUDIO_SWITCH];
    }
}

- (IBAction)Action_Btn_Buffer:(id)sender {
    [self alertController];
}

- (IBAction)Action_Btn_Clean_Buffer:(id)sender {
}
@end
