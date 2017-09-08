//
//  AppDelegate.m
//  xlinkDemo
//
//  Created by xtmac on 6/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "AppDelegate.h"
#import "XLinkExportObject.h"
#import "DeviceEntity.h"
#import "NSNotificationCenter+MainThread.h"
#import "List.h"

@interface AppDelegate ()<XlinkExportObjectDelegate>
{
    UIBackgroundTaskIdentifier backgroundTask; //用来保存后台运行任务的标示符
    NSTimer *mytimer;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"[didFinishLaunchingWithOptions]");
   
    [SMSSDK registerApp:SMS_APP_KEY withSecret:SMS_APP_SECRET];
    
    [XLinkExportObject sharedObject].delegate = self;
    // 设置运行属性
    [[XLinkExportObject sharedObject] setSDKProperty:@"cm2.xlink.cn" withKey:PROPERTY_CM_SERVER_ADDR];
    [[XLinkExportObject sharedObject] setSDKProperty:[NSNumber numberWithBool:NO] withKey:PROPERTY_SEND_OVERTIME_CHECK];
    [[XLinkExportObject sharedObject] setSDKProperty:[NSNumber numberWithBool:YES] withKey:PROPERTY_SEND_DATA_BUFFER];
    [[XLinkExportObject sharedObject] setSDKProperty:[NSNumber numberWithFloat:0.3] withKey:PROPERTY_SEND_DATA_INTERVAL];
    
    //设置播放属性
    NSString *audio_switch = [[NSUserDefaults standardUserDefaults] objectForKey:AUDIO_SWITCH];
    if(!audio_switch){
        [[NSUserDefaults standardUserDefaults] setObject:@"480" forKey:VIDEO_RESOLUTION];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:AUDIO_SWITCH];
        [[NSUserDefaults standardUserDefaults] setObject:@"50" forKey:AUDIO_VOLUME];
        [[NSUserDefaults standardUserDefaults] setObject:@"500" forKey:KXMOVE_BUFFER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [NSThread sleepForTimeInterval:2.0f];
    //[self showMessage:VERSION];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"[applicationWillResignActive]");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"[applicationDidEnterBackground]");
    //[self startBackgroundTask];
}
- (void)startBackgroundTask

{
    
    UIApplication *application = [UIApplication sharedApplication];
    
    //通知系统, 我们需要后台继续执行一些逻辑
    
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        
        //超过系统规定的后台运行时间, 则暂停后台逻辑
        
        [application endBackgroundTask:backgroundTask];
        
        backgroundTask = UIBackgroundTaskInvalid;
        
    }];
    
    
    
    //判断如果申请失败了, 返回
    
    if (backgroundTask == UIBackgroundTaskInvalid) {
        
        NSLog(@"【申请后台运行失败！】");
        
        return;
        
    }else{
        NSLog(@"【申请后台运行成功！】");
        
        mytimer=[NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(OverTime) userInfo:nil repeats:NO];
    }
    
}
-(void)OverTime{
    NSLog(@"[后台运行一分钟后]");
    exit(0);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"[applicationWillEnterForeground]");
    [mytimer setFireDate:[NSDate distantFuture]];//关闭定时器
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"[applicationDidBecomeActive]");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"[applicationWillTerminate]");
}

#pragma mark XLinkExportObject Delegate

//onStart回调
-(void)onStart{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnStart object:nil];
}

//扫描返回
-(void)onGotDeviceByScan:(DeviceEntity *)device{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnGotDeviceByScan object:device];
}

//握手状态回调
-(void)onHandShakeWithDevice:(DeviceEntity *)device withResult:(int)result{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnHandShake object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result]}];
}

/**
 *  连接设备回调
 *
 *  @param device 设备实体
 *  @param result 连接结果
 *  @param taskID 任务ID
 */
-(void)onConnectDevice:(DeviceEntity *)device andResult:(int)result andTaskID:(int)taskID {
    
    if( result == 0 ) {
        NSLog(@"Devcice %@ connected", [device getLocalAddress]);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnConnectDevice object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"taskID" : [NSNumber numberWithInt:taskID]}];
}

//通知状态返回
-(void)onLogin:(int)result{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnLogin object:@{@"result" : [NSNumber numberWithInt:result]}];
}

-(void)onSetDeviceAccessKey:(DeviceEntity *)device withResult:(unsigned char)result withMessageID:(unsigned short)messageID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSetDeviceAccessKey object:@{@"result" : @(result), @"device" : device}];
}

//订阅状态返回
-(void)onSubscription:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSubscription object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
    
    if (result == 0) {
        NSLog(@"订阅成功,MessageID = %d", messageID);
    }else{
        NSLog(@"订阅失败,MessageID = %d; Result = %d", messageID, result);
    }
}

-(void)onDeviceProbe:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnDeviceProbe object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

//设置本地设备的访问授权码结果回调
-(void)onSetLocalDeviceAuthorizeCode:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSetLocalDeviceAuthorizeCode object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

//云端设置授权结果回调
-(void)onSetDeviceAuthorizeCode:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSetDeviceAuthorizeCode object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

//发送云端pipe数据结果
-(void)onSendPipeData:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSendPipeData object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

//发送本地pipe消息结果回调
-(void)onSendLocalPipeData:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSendLocalPipeData object:@{@"device" : device, @"result" : [NSNumber numberWithInt:result], @"messageID" : [NSNumber numberWithInt:messageID]}];
}

//接收本地设备发送的pipe包
-(void)onRecvLocalPipeData:(DeviceEntity *)device withPayload:(NSData *)payload{
    NSLog(@"onRecvLocalPipeData,DataLength %lu", (unsigned long)payload.length);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvLocalPipeData object:@{@"device" : device, @"payload" : payload}];
}

//接收到云端设备发送回来的pipe结构
-(void)onRecvPipeData:(DeviceEntity *)device withPayload:(NSData *)payload{
    NSLog(@"onRecvPipeData,DataLength %lu", (unsigned long)payload.length);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvPipeData object:@{@"device" : device, @"payload" : payload}];
}

//接收到云端设备发送的PIPE_SYNC(PIPE_2)
-(void)onRecvPipeSyncData:(DeviceEntity *)device withPayload:(NSData *)payload{
    NSLog(@"onRecvPipeSyncData,DataLength %lu", (unsigned long)payload.length);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvPipeSyncData object:@{@"device" : device, @"payload" : payload}];
}

//接收到平台发送的Event Notify消息
-(void)onNotifyWithFlag:(unsigned char)flag withMessageData:(NSData *)data fromID:(int)fromID messageID:(int)messageID {
    NSLog(@"onNotifyWithFlag flag : %d , fromID : %d, messageID : %d;", flag, fromID, messageID);
    NSLog(@"MessageData with length %ld", data.length);
    if( flag == EVENT_DATAPOINT_NOTICE || flag == EVENT_DATAPOINT_ALERT ) {
        int len = 0;
        [data getBytes:&len range:NSMakeRange(0, 2)];
        len = ntohs(len);
        NSData * temp = [data subdataWithRange:NSMakeRange(2, len)];
        //NSString * text = [NSString stringWithUTF8String:[temp bytes]];
        //NSLog(@"Message text : %@", text);
    }
}

-(void)onDataPointUpdata:(DeviceEntity *)device withIndex:(int)index withDataBuff:(NSData *)dataBuff withChannel:(int)channel{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:kOnDataPointUpdata object:@{@"device" : device, @"index" : [NSNumber numberWithInt:index], @"databuff" : dataBuff, @"channel" : [NSNumber numberWithInt:channel]}];
}

-(void)onDeviceStatusChanged:(DeviceEntity *)device{
    NSLog(@"onDeviceStateChanged,DataLength mac:%@", [device getMacAddressString]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnDeviceStateChanged object:@{@"device" : device}];
}

@end
