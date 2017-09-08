//
//  XLinkExportObject.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/2.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>


#define ExtLoginState @"extLoginState"

@class DeviceEntity;
@class XLinkExportObject;

@protocol XlinkExportObjectDelegate <NSObject>

@optional

//onStart回调
-(void)onStart;

//扫描返回
-(void)onGotDeviceByScan:(DeviceEntity *)device;

//设置本地设备的访问授权码结果回调
-(void)onSetLocalDeviceAuthorizeCode:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID;

//握手状态回调
-(void)onHandShakeWithDevice:(DeviceEntity *)device withResult:(int)result;

//发送本地pipe消息结果回调
-(void)onSendLocalPipeData:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID;

//接收本地设备发送的pipe包
-(void)onRecvLocalPipeData:(DeviceEntity *)device withPayload:(NSData *)data;

//通知状态返回
-(void)onLogin:(int)result;

//订阅状态返回
-(void)onSubscription:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID;

//云端设置授权结果回调
-(void)onSetDeviceAuthorizeCode:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID;

//发送云端pipe数据结果
-(void)onSendPipeData:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID;

//接收到云端设备发送回来的pipe结构
-(void)onRecvPipeData:(DeviceEntity *)device withPayload:(NSData *)payload;

//接收到云端设备发送的PIPE_SYNC(PIPE_2)
-(void)onRecvPipeSyncData:(DeviceEntity *)device withPayload:(NSData *)payload;


//透传状态回调
-(void)xlink:(XLinkExportObject *)xlin onPipeResponse:(DeviceEntity *)device andCode:(int)code;

//透传状态回调2
-(void)xlink:(XLinkExportObject *)xlin onPipeResponse:(DeviceEntity *)device andPayload:(NSData *)data;

@end

@interface XLinkExportObject : NSObject

+(XLinkExportObject *)sharedObject;

@property (nonatomic,retain)id<XlinkExportObjectDelegate> delegate;

//开始初始化操作 监听的app本地UDP端口 用于SDK监听WiFi设备数据回包
//note: 理论上该端口是随机得到当前可用的端口
//# 1
-(int)start;

//# 2
//通过产品ID扫描设备 设置扫描的回调代理
-(int)scanByDeviceProductID:(NSString *)productID;




//#4
//设置设备密码
-(int)setLocalDeviceAuthorizeCode:(DeviceEntity *)device andOldAuthCode:(NSString *)oldAuth andNewAuthCode:(NSString *)newAuth;


//#5
//与本地设备进行握手 没有握手的设备不能操作 需要提供authkey
-(int)handShakeWithDevice:(DeviceEntity *)device andAuthKey:(NSString *)authKey;


//#6
//本地向设备pipe
-(int)sendLocalPipeData:(DeviceEntity *)device andPayload:(NSData *)payload;



//#7
//登陆外网
-(int)loginWithAppID:(int)appId andAuthStr:(NSString *)authStr;



//#8
//订阅设备，在系统中产生信任关系，只有订阅成功的设备才能在运行的云端的控制
-(int)subscribeDevice:(DeviceEntity *)device andAuthKey:(NSString *)authKey andFlag:(BOOL)flag;


//#9
//通过云端设置设备的访问授权码
-(int)setDeviceAuthorizeCode:(DeviceEntity *)device andOldAuthKey:(NSString *)oldAuth andNewAuthKey:(NSString *)newAuth;


//#10
//通过云端向设备发送pipe数据
-(int)sendPipeData:(DeviceEntity *)device andPayload:(NSData *)payload;



//#11
//向SDK中初始化设备节点
-(int)initDevice:(DeviceEntity *)device;


//清理操作
-(void)stop;

/*
 *初始化设备列表
 */
-(void)initDeviceList:(NSArray *)devices;

/*
 *@discussion
 * 得到所有的设备列表，返回的NSArray中包含的是DeviceEntity对象
 */
-(NSArray *)getAllDevice;




#pragma mark
#pragma mark  利达信保留接口
//订阅设备
-(void)subscriptionWithDevice:(DeviceEntity *)device andSubscription:(BOOL)sub;


//透传数据
-(void)pipeWithDevice:(DeviceEntity *)device andPayload:(NSData *)payload;

@end
