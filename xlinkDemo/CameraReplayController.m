//
//  CameraReplayController.m
//  xlinkDemo
//
//  Created by kingcom on 2017/3/16.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraReplayController.h"


@interface CameraReplayController ()

@end

@implementation CameraReplayController
//方法
-(void)Return{
    [self.navigationController popViewControllerAnimated:YES];
}

//建立TCP连接
#define TIME_OUT 20

// 建立socket连接
-(void)socketConnectHost{
    self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError * error = nil;
    
    [self.clientSocket connectToHost:@"192.168.1.1" onPort:5555 error:&error];
}

- (void)viewDidLoad

{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = NO;
    UIBarButtonItem *nullItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回",comment: "") style:UIBarButtonItemStylePlain target:self action:@selector(Return)];
    self.navigationItem.leftBarButtonItem = nullItem;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title=NSLocalizedString(@"ZCamerasReplay",comment: "");
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
}

-(void)viewWillDisappear:(BOOL)animated{
    if(self.clientSocket.isConnected){
        [self.clientSocket disconnect];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    //第一次添加currentRead，确保数据到来能读取
    NSLog(@"连接成功【%@】",host);
    [self.clientSocket readDataWithTimeout:-1 tag:1];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    //上一个currentRead已被清空，需要添加一个新的，确保下次数据到来能读取。
    [self.clientSocket readDataWithTimeout:-1 tag:1];
    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    NSString *hex=[self hexStringFromString:result];
    NSLog(@"result=%@  hex=%@",result,hex);
    
}

#pragma mark btn

//普通字符串转16进制
- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

// 16进制转普通
- (NSString *)stringFromHexString:(NSString *)hexString {
    
    hexString=[hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    
    NSLog(@"长度=%lu",(unsigned long)hexString.length);
    
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr] ;
        [scanner scanHexInt:&anInt];
        
        NSLog(@"长度=%@ =%d",hexCharStr,i);
        
        myBuffer[i / 2] = (char)anInt;
        
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
}


- (NSData*)hexToData:(NSString *)hexString {
    
    int len = (int)[hexString length] / 2;
    char * bytes = (char *)malloc(len);
    CamerahexToBytes(bytes, [hexString UTF8String], (int)[hexString length]);
    
    NSData * data = [[NSData alloc] initWithBytes:bytes length:len];
    
    free(bytes);
    return data;
}

void CamerahexToBytes(char * bytes, const char * hexString, int hexLength)
{
    char * pos = (char *)hexString;
    int count = 0;
    for(count = 0; count < hexLength / 2; count++) {
        sscanf(pos, "%2hhx", &bytes[count]);
        pos += 2 * sizeof(char);
    }
}

- (IBAction)BtnRefresh:(id)sender {
    
    NSString *data=@"751104007a716370";
    NSData* xmlData = [self hexToData:data];
    [self.clientSocket writeData:xmlData withTimeout:-1 tag:1];
}

- (IBAction)BtnReplay:(id)sender {
    [self socketConnectHost];
}

- (IBAction)BtnTime:(id)sender {
}
@end
