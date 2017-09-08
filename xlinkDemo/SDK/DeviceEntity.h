//
//  DeviceEntity.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/8.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceEntity : NSObject

@property (nonatomic,copy)NSString *fromIP;            //从那个IP得到的设备
@property (nonatomic,copy)NSString *deviceKey;         //设备Key str 长度为 16
@property (nonatomic,copy)NSString *dataPointModel;    //datapoint解析模版 json数据
@property (nonatomic,copy)NSMutableData *dataPoint;    //datapoint数据节点buf
@property (nonatomic,assign)NSInteger dataPointFlag;     //datapoint flag 标示后面的datapoint的解析方式 enum {0,1,2,3}
@property (nonatomic,copy)NSData *macAddress;          //设备Mac地址
@property (nonatomic,copy)NSString *productID;         //设备产品ID        扫描得到
@property (nonatomic,assign)int mcuHardVersion;          //mcu硬件版本号      <1byte
@property (nonatomic,assign)int mcuSoftVersion;          //mcu软件版本号      <2bytes
@property (nonatomic,assign)int devicePort;              //设备监听的端口号    <2bytes
@property (nonatomic,assign)int version;
@property (nonatomic,assign)int sessionID;
@property (nonatomic,assign)int flag;
@property (nonatomic,assign)int deviceID;

-(void)initPropertyWithData:(NSData *)data;

-(void)setSessionID:(int)sessionID;

-(int)getSessionID;

-(void)setTicketString:(NSString *)ticket;

-(NSString *)getTicketString;

-(void)setDeviceID:(int)deviceId;

-(int)getDeviceID;

-(void)initDeviceHeat;

- (void)startHeatBeat;

- (void)stopBeat;

-(void)setLastgetPingReturnTime:(double)time;

/*
 *@discussion
 *  该函数的主要作用是初始化一个设备
 *@deviceKey
 *  设备key
 *@model
 *  设备解析模版
 *@data
 *  设备数据节点值的byte缓存
 */

-(id)initWith:(NSString *)deviceKey andParseMode:(NSString *)model andDatapointData:(NSMutableData *)data andFlag:(int)flag;

/*
 *@discussion
 *  该函数的主要作用是获得指定索引的节点的值，index的索引从0开始
 *
 *@index
 *  指定的索引,如果索引的值大于理论值则 返回－1
 *
 */
-(int)getValueForIndex:(int)index;


//
-(void)sendByeBye;

/*
 *@discussion
 *  该函数的作用是返回端点值的有效位的索引数组  通过有效位标示字节得到有效值索引的数组，从而得到指定索引的值，根据索引值就可以顺序读取指定索引的值了。
 */
-(NSMutableArray *)getValidateFlag;


/*
 *@discussion
 *获得设备名字字符串bytes未转换，如果有就会得到datapoint的name的设置属性字符串，字符串的长度由datapoint的头两个字节标示。
 */
-(NSData *)getDeviceNameSetting;

/*
 *@discussion
 * 设置设备名字 字符串bytes，设备名字属性的设置，传入的属性为nsdata
 */
-(void)setDeviceName:(NSData *)data;


/*
 *@discussion
 *  设置设备名字属性的名字，传入的参数为字符串
 */

-(void)setDeviceNameWithStr:(NSString *)nameStr;

/*
 *@discussion
 *  获得设备key字符串
 */
-(NSString *)getDeviceKeyString;

/*
 *@discussion
 *  获得设备key字节
 */
-(NSData *)getDeviceKeyData;

/*
 *@discussion-setMethod
 * 设置指定索引的值，设置的值只是存储在一个设置缓存字典中，只有设置完成之后，就可以通过函数-(NSData *)getAfterSetDatapointData得到设置之后的bytes，可以通过resetDevice来清空设置的值和标示
 */
-(void)setIndex:(int)aIndex withValue:(int)aValue;


/*
 *@discussion-getMethod
 * 获得设置之后的data payload设置之后的，如果你只设置了deviceName属性，返回的data只包含deviceName的字符串的长度长度和字符串＝ 2bytes＋deviceName ，如果你只设置了datapoint的话，通过解析模版得到有效位标示再加上datapint 的值 ：(validate flag)bytes + (datapoints set value)bytes
 */
-(NSData *)getAfterSetDatapointData;


/*
 *@discussion-getMethod
 *  getSetFlag,主要是为了获得，设置之后的payload的值，如果为0标示没有设置deviceName和datapoint的值，如果为1标示只有deviceName字符串的设置，如果值为2只有datapoint的设置没有deviceName属性的设置，为3标示既有deviceName的设置也有datapoint的设置
 */
-(int)getSettedFlag;

/*
 *@discussion-setMethod
 *  重新设置设备的状态,主要是重置设置的标示值，和移除设置的值
 */
-(void)resetDevice;


-(NSString *)getMacAddressString;


-(NSDictionary *)getDictionaryFormat;


-(id)initWithDictionary:(NSDictionary *)dict;

-(BOOL)getInitStute;

-(BOOL)isDeviceInitted;

-(BOOL)isHaveDeviceName;

-(BOOL)isHaveDataPoint;

@end
