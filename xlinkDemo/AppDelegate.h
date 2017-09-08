//
//  AppDelegate.h
//  xlinkDemo
//
//  Created by xtmac on 6/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SMS_SDK/SMSSDK.h>

#define VERSION                         @"2.3"

#define kOnStart                        @"kOnStart"
#define kOnGotDeviceByScan              @"kOnGotDeviceByScan"
#define kOnConnectDevice                @"kOnConnectDevice"
#define kOnSetLocalDeviceAuthorizeCode  @"kOnSetLocalDeviceAuthorizeCode"
#define kOnHandShake                    @"kOnHandShake"
#define kOnRecvLocalPipeData            @"kOnRecvLocalPipeData"
#define kOnLogin                        @"kOnLogin"
#define kOnSubscription                 @"kOnSubscription"
#define kOnDeviceProbe                  @"kOnDeviceProbe"
#define kOnSetDeviceAuthorizeCode       @"kOnSetDeviceAuthorizeCode"
#define kOnSendPipeData                 @"kOnSendPipeData"
#define kOnSendLocalPipeData            @"kOnSendLocalPipeData"
#define kOnRecvPipeData                 @"kOnRecvPipeData"
#define kOnRecvPipeSyncData             @"kOnRecvPipeSyncData"
#define kOnDataPointUpdata              @"kOnDataPointUpdata"
#define kOnDeviceStateChanged           @"kOnDeviceStateChanged"
#define kOnSetDeviceAccessKey           @"kOnSetDeviceAccessKey"

//本公司 PRODUCT_ID
#define PRODUCT_ID                      @"60c6837964a7445a88df2a2621d57f62"

//dashboard.mob.com短信验证
#define SMS_APP_KEY                     @"149a3966eb1a0"
#define SMS_APP_SECRET                  @"b73ea6b228b43f2a38b4863e8357f503"

//本公司 净化器命令

//send code
#define KA                              @"ka"

#define OPEN                            @"2641317c31"      //$A1|1
#define CLOSE                           @"2641317c30"      //$A1|0

#define LOCK                            @"2641327c31"      //$A2|1
#define UNLOCK                          @"2641327c30"      //$A2|0

#define SMART                           @"2641347c317c30"  //$A4|1|0
#define SLEEP                           @"2641347c327c30"  //$A4|2|0
#define MODE3                           @"2641347c337c30"  //$A4|3|0
#define MODE4                           @"2641347c347c30"  //$A4|4|0

#define CLOSE_FUN                       @"2641347c307c30"  //$A4|0|0
#define MUTE                            @"2641347c307c31"  //$A4|0|1
#define LOW                             @"2641347c307c32"  //$A4|0|2
#define CENTER                          @"2641347c307c33"  //$A4|0|3
#define HIGH                            @"2641347c307c34"  //$A4|0|4
#define STRONG                          @"2641347c307c35"  //$A4|0|5

#define RESET_FILTER                    @"2641367c31"      //$A6|1

#define TIME0                            @"2641387c30"     //$A8|0
#define TIME1                            @"2641387c31"     //$A8|1
#define TIME2                            @"2641387c32"     //$A8|2
#define TIME4                            @"2641387c33"     //$A8|3
#define TIME8                            @"2641387c34"     //$A8|4

#define CHECK                            @"2641377c30"     //$A7|0

#define LIGHT1                           @"2641397c31"     //$A9|1
#define LIGHT0                           @"2641397c30"     //$A9|0

#define HEART                            @"6b61"

//S9 new code
#define S9_CHECK                         @"2642377c30"
#define LIGHTNESS0                       @"2642317c303030"             //$B1|000
#define LIGHTNESS100                     @"2642317c313030"             //$B1|100
#define COLOR                            @"2642327c30303030303030"     //$B2|0000000

#define C1                               @"2642327c30666666666666"  //ffffff white
#define C2                               @"2642327c30666265343039"  //fbe409 yellow
#define C3                               @"2642327c30666630303030"  //ff0000
#define C4                               @"2642327c30303066663030"  //00ff00
#define C5                               @"2642327c30303066666666"  //00ffff

#define ADD_C1                               @"2642327c31303030303030"  
#define ADD_C2                               @"2642327c32303030303030"
#define ADD_C3                               @"2642327c33303030303030"
#define ADD_C4                               @"2642327c34303030303030"
#define ADD_C5                               @"2642327c35303030303030"
#define ADD_C6                               @"2642327c36303030303030"
#define ADD_C7                               @"2642327c37303030303030"
#define ADD_C8                               @"2642327c38303030303030"
#define ADD_C9                               @"2642327c39303030303030"
#define ADD_C10                              @"2642327c61303030303030"
#define ADD_C11                              @"2642327c62303030303030"
#define ADD_C12                              @"2642327c63303030303030"
//receive code(only 7 send code)

//

#define SERVERADDR               @"rtsp://192.168.1.1"     //音频音量
#define SERVERPORT              @"554"     //播放器缓存

#define VIDEO_RESOLUTION           @"video_resolution"     //视频分辨率
#define AUDIO_SWITCH               @"audio_switch"     //音频开关
#define AUDIO_VOLUME               @"audio_volume"     //音频音量
#define KXMOVE_BUFFER              @"kxmove_buffer"     //播放器缓存

//异亮设备名字
#define DEVICE_O2                        @"air_valley_o2"
#define DEVICE_PRO                       @"air_valley_pro"
#define DEVICE_C7                        @"air_valley_c7"
#define DEVICE_P6                        @"air_valley_p6"
#define DEVICE_S9                        @"air_valley_s9"

//weather net
#define WEATHER                          @"http://wthrcdn.etouch.cn/WeatherApi?city="

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

