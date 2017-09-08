//
//  MatchViewController.m
//  xlinkDemo
//
//  Created by kingcom on 15/9/23.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<errno.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ViewController.h"
#import "MatchViewController.h"
#import "ScanDeviceViewController.h"
#import "HttpRequest.h"
#import "XLinkExportObject.h"


@interface MatchViewController () <UITextFieldDelegate>
{
    int status;
    NSTimer *myTimer;
    BOOL add;
}
@end

@implementation MatchViewController

//配对源程序部分
int ser_sockfd;
int fd;
int len;
socklen_t addrlen;
char seraddr[255]={0};
struct sockaddr_in ser_addr;
int isSendPacket = 1;
-(void)isADD{
    add=true;
}

-(void)showMessage:(NSString *)message
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    //CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSLineBreakByWordWrapping;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:17], NSParagraphStyleAttributeName: paragraph};
    
    CGSize LabelSize = [message boundingRectWithSize:CGSizeMake(290, 9000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    showview.frame = CGRectMake((width - LabelSize.width - 20)/2, height - 150, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:2.0 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}

int CRC_CCITT(int flag, char *text)
{
    int i;
    int cksum = 0;
    int sum = 0;
    
    
    if (flag==0) {
        short buf[30];
        for (int n=0; n<strlen(text); n++) {
            if (text[n]<0) {
                buf[n] = text[n] + 256;
            }
            else{
                buf[n] = text[n];
            }
            
        }
        unsigned long len =  strlen(text);
        
        for(i = 0; i < len; i++)
            sum += buf[i];
    }else{
        char buf[30];
        strncpy(buf, text, strlen(text));
        unsigned long len =  strlen(text);
        
        for(i = 0; i < len; i++)
            sum += buf[i];
    }
    
    cksum = sum & 0x7f;
    cksum |= (sum & (0x7f << 7)) << 1;
    return cksum;
}

void sendOnePacket(int s1, int s2, int s3, int s4, int ms) {
    
    unsigned int ip[4] = {s1, s2, s3, s4};
    ser_addr.sin_addr.s_addr = (ip[3]<<24) | (ip[2]<<16) | (ip[1]<<8) | (ip[0]);
    sendto(ser_sockfd,seraddr,len,0,(struct sockaddr*)&ser_addr,addrlen);
}

void startConfig(char *currentSsidTxt, char *currentPasswordTxt){
    
    int ms = 0;
    int i = 0;
    int s1 = 224;
    int s2 = 0;
    int s3 = 4;
    int s4 = 5;
    
    short ssidData[30]={0};
    
    //strncpy(ssidData, currentSsidTxt, strlen(currentSsidTxt));
    for (int n=0; n<strlen(currentSsidTxt); n++) {
        if (currentSsidTxt[n]<0) {
            ssidData[n] = currentSsidTxt[n] + 256;
        }
        else{
            ssidData[n] = currentSsidTxt[n];
        }
    }
    
    char passwordData[100]={0};
    
    if (strlen(currentPasswordTxt)<=100) {
         strncpy(passwordData, currentPasswordTxt, strlen(currentPasswordTxt));
    }else{
        
    }
   
    int crcSSID = CRC_CCITT(0, currentSsidTxt);
    int crcPassword = CRC_CCITT(1, currentPasswordTxt);
    
    unsigned long len_ssid=strlen(currentSsidTxt);
    unsigned long len_psw=strlen(currentPasswordTxt);
    
    
    do{
        //printf("正在进行smartConfig!");
        [NSThread sleepForTimeInterval:0.3f];
        s2 = 0x8;
        s3 = 'C';
        s4 = 'E';
        sendOnePacket(s1, s2, s3, s4, ms);
        s2 = 0x9;
        s3 = 'A';
        s4 = 'C';
        sendOnePacket(s1, s2, s3, s4, ms);
        s2 = 0x8;
        s3 = 'C';
        s4 = 'E';
        sendOnePacket(s1, s2, s3, s4, ms);
        s2 = 0x9;
        s3 = 'A';
        s4 = 'C';
        sendOnePacket(s1, s2, s3, s4, ms);
        
        // ssid len
        s2 = 0x10;
        s3 = strlen(currentSsidTxt);
        s4 = strlen(currentSsidTxt);
        sendOnePacket(s1, s2, len_ssid, len_ssid, ms);
        
        int p=ceil((double)len_ssid/2)-1;
        //printf("P=%d ##",p);
        for(i = 0; i <= p; i++){
            s2 = i + 0x40;
            s3 = ssidData[i*2+1];
            s4 = ssidData[i*2];
            //printf("[s3=0x%x][s4=0x%x]",s3,s4);
            sendOnePacket(s1, s2, s3, s4, ms);
            
        }
        
        
        //ssid crc
        s2 = 0x70;
        s3 = (crcSSID & 0xff00) >> 8;
        s4 = crcSSID & 0xff;
        sendOnePacket(s1, s2, s3, s4, ms);
        
        [NSThread sleepForTimeInterval:0.3f];
        
        s2 = 0x8;
        s3 = 'C';
        s4 = 'E';
        sendOnePacket(s1, s2, s3, s4, ms);
        s2 = 0x9;
        s3 = 'A';
        s4 = 'C';
        sendOnePacket(s1, s2, s3, s4, ms);
        //ceac
        s2 = 0x8;
        s3 = 'C';
        s4 = 'E';
        sendOnePacket(s1, s2, s3, s4, ms);
        s2 = 0x9;
        s3 = 'A';
        s4 = 'C';
        sendOnePacket(s1, s2, s3, s4, ms);
        
        /*
         * PWD
         */
        // pwd len
        s2 = 0x0;
        s3 = strlen(currentPasswordTxt);
        s4 = strlen(currentPasswordTxt);
        sendOnePacket(s1, s2, len_psw, len_psw, ms);
        
        
        int q=ceil((double)len_psw/2)-1;
        //printf("Q=%d ##",q);
        for(i = 0; i <= q; i++){
            s2 = i + 0x20;
            s3 = passwordData[i*2+1];
            s4 = passwordData[i*2];
            sendOnePacket(s1, s2, s3, s4, ms);
            
        }
        
        //pwd crc
        s2 = 0x60;
        s3 = (crcPassword & 0xff00) >> 8;
        s4 = crcPassword & 0xff;
        sendOnePacket(s1, s2, s3, s4, ms);
        
        
        p=0;q=0;
        
    }while (isSendPacket == 1);
    
    isSendPacket = 0;
    
}

-(NSString *)getName{
    NSString *wifiName = @"Not Found";
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    
    if (myArray != nil) {
        
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        
        if (myDict != nil) {
            
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            
            
            wifiName = [dict valueForKey:@"SSID"];
            
        }
        
    }
    
    NSLog(@"wifiName:%@", wifiName);
    return wifiName;
}

- (void)Out_app:(NSNotification *)notification

{
    NSLog(@"匹配界面：进入后台挂起！");
    
}

- (void)In_app:(NSNotification *)notification
{
    NSLog(@"匹配界面：从后台回复。");
    self.SSID.text=[self getName];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"停止",comment: "") style:UIBarButtonItemStylePlain target:self action:@selector(Stop_match)];
    self.navigationItem.rightBarButtonItem = stop;
    
    self.navigationItem.title=NSLocalizedString(@"添加设备",comment: "");
    
    if (add) {
        [self.View_add setHidden:YES];
        UIBarButtonItem *nullItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回",comment: "") style:UIBarButtonItemStylePlain target:self action:@selector(Return)];
        self.navigationItem.leftBarButtonItem = nullItem;

    }else{
        UIBarButtonItem *nullItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
        self.navigationItem.leftBarButtonItem = nullItem;
    }
    
    [self.Wait setHidden:YES];
    [self.Wait_view setHidden:YES];
    [self.Wait startAnimating];
    self.SSID.text=[self getName];
    //self.SSID.text=@"SX111";
    //[self Adapter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Out_app:)
                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(In_app:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
    status=1;//默认初始为smartConfig模式，0为AP模式
    // Do any additional setup after loading the view.
    
    self.SSID.delegate=self;
    self.PSW.delegate=self;
}

-(void)Adapter{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    NSLog(@"x=%f y=%f",width,height);
    //不同分辨率微调，以iPhone6 4.7寸为基准
    //iphone 4
    if (width==320 && height==480) {
        self.View_add.frame=CGRectMake(0,64,320,416);
        self.P_add.frame=CGRectMake(70,98,180,220);
    }
    //iphone 5
    if (width==320 && height==568) {
        
        self.View_add.frame=CGRectMake(0,64,320,504);
        self.P_add.frame=CGRectMake(70,142,180,220);
        
    }
    //iphone 6
    if (width==375 && height==667) {
        
    }
    //iphone 6+
    if (width==414 && height==736) {
        
    }
}


-(void)viewWillDisappear:(BOOL)animated{
    [self.Wait_view setHidden:YES];
    [myTimer setFireDate:[NSDate distantFuture]];//关闭定时器
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushScanDeviceViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ScanDeviceViewController *scanView = [storyBoard instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];
    [scanView initData];
    [self.navigationController pushViewController:scanView animated:YES];
}
-(void)pushViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *View = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
    [View Who_in];
    [self.navigationController pushViewController:View animated:YES];
}
-(void)showWarningAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示",comment: "") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"确定",comment: "") otherButtonTitles:nil, nil];
    [alert show];
    
}


-(void)OverTime
{
    
    isSendPacket=0;
    [self Close_socket];
    [self showWarningAlert:NSLocalizedString(@"配对超时，请从新配对！",comment: "")];
    [self.Wait_view setHidden:YES];
    [self.Wait setHidden:YES];
    
}   


- (IBAction)Match:(id)sender {
    
    [self.Wait_view setHidden:NO];
    [self.Wait setHidden:NO];
     myTimer= [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(OverTime) userInfo:nil repeats:NO];
    
    //获取输入框SSID和PSW
    NSString *string_ssid = [self.SSID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    const char *char_ssid = [string_ssid cStringUsingEncoding:NSUTF8StringEncoding];

    NSString *string_psw = [self.PSW.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    const char *char_psw = [string_psw cStringUsingEncoding:NSASCIIStringEncoding];
    
    if ([string_psw isEqualToString:@"8888"]) {
        //[self pushScanDeviceViewController];
    }
    else{
    //如果密码是空，发送空
    //if(strlen(char_psw)==0)
    //char_psw=NULL;
        //printf("charssid=%s",char_ssid);

    //smartConfig 模式
    
    if(status==1 && strlen(char_ssid)!=0 ){
        /*建立socket*/
        ser_sockfd=socket(AF_INET,SOCK_DGRAM,0);
        if(ser_sockfd<0)
        {
            [self showMessage:NSLocalizedString(@"配置出错，请重新配置。",comment: "")];
        }else{
            //NSLog(@"ser_sockfd=%d",ser_sockfd);
            /*填写sockaddr_in 结构*/
            addrlen=sizeof(struct sockaddr_in);
            bzero(&ser_addr,addrlen);
            ser_addr.sin_family=AF_INET;
            ser_addr.sin_addr.s_addr=htonl(INADDR_ANY);
            ser_addr.sin_port=htons(5000);
            /*绑定客户端*/
            int bi=bind(ser_sockfd,(struct sockaddr *)&ser_addr,addrlen);
            //printf("BIND=%d",bi);
            
            /*将字串返回给client端*/
            len=strlen(seraddr);
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 耗时的操作
                isSendPacket = 1;
                int c=0;
                
                NSString *string_ssid = [self.SSID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                char *char_ssid = [string_ssid cStringUsingEncoding:NSUTF8StringEncoding];
                
                NSString *string_psw = [self.PSW.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                char *char_psw = [string_psw cStringUsingEncoding:NSASCIIStringEncoding];
                printf("SSID=%s || PSW=%s",char_ssid,char_psw);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新界面
                    //self.message.text=@"开始进行smartConfig模式配对！";
                });
                if(c==0){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 更新界面
                        // self.message.text=@"正在发送smartConfig数据！";
                    });
                    startConfig(char_ssid,char_psw);
                }
                c=c+1;
                
            });
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 耗时的操作
                
                printf("进入smartconfig的接收返回！");
                char res[100];
                bzero(res,sizeof(res));
                recvfrom(ser_sockfd,res,sizeof(res),0,(struct sockaddr*)&ser_addr,&addrlen);
                printf("res=%s",res);
                if(res[0]=='[')
                {
                    NSString *che=[NSString stringWithFormat:@"%s",res];
                    che=[che substringWithRange:NSMakeRange(1, 17)];
                    che=[che stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    NSLog(@"配对成功的设备MAC=%@",che);
                    [[NSUserDefaults standardUserDefaults] setObject:che forKey:@"ONE"];
                    isSendPacket = 0;
                    [self Close_socket];
                    [myTimer setFireDate:[NSDate distantFuture]];//关闭定时器
                    NSLog(@"开始跳转界面。");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 更新界面
                        [self pushScanDeviceViewController];
                    });
                }
            });

        }

    }
    else{
        [self showWarningAlert:NSLocalizedString(@"请正确输入信息！",comment: "")];
    }
    
    //AP模式
    if(status==0){
        
        int err;
        fd=socket(AF_INET, SOCK_STREAM, 0);
        BOOL success=(fd!=-1);
        struct sockaddr_in addr;
        
        if (success) {
            NSLog(@"socket success");
            memset(&addr, 0, sizeof(addr));
            addr.sin_len=sizeof(addr);
            addr.sin_family=AF_INET;
            addr.sin_addr.s_addr=INADDR_ANY;
            err=bind(fd, (const struct sockaddr *)&addr, sizeof(addr));
            success=(err==0);
        }
       
        if (success) {
           
            struct sockaddr_in peeraddr;
            memset(&peeraddr, 0, sizeof(peeraddr));
            peeraddr.sin_len=sizeof(peeraddr);
            peeraddr.sin_family=AF_INET;
            peeraddr.sin_port=htons(6444);
                        peeraddr.sin_addr.s_addr=inet_addr("192.168.1.1");
            //            这个地址是服务器的地址，
            socklen_t addrLen;
            addrLen =sizeof(peeraddr);
            NSLog(@"connecting");
            err=connect(fd, (struct sockaddr *)&peeraddr, addrLen);
            success=(err==0);
            if (success) {
               
                err =getsockname(fd, (struct sockaddr *)&addr, &addrLen);
                success=(err==0);
                
                if (success) {
                    NSLog(@"connect success,local address:%s,port:%d",inet_ntoa(addr.sin_addr),ntohs(addr.sin_port));
                    char cfgHead[30]={0};
                    cfgHead[0] = 0x23;
                    cfgHead[1] = 0x23;
                    cfgHead[2] = 0x43; //ap config
                    cfgHead[3] = 0x41; //ap mode
                    cfgHead[4] = strlen(char_ssid);
                    cfgHead[5] = strlen(char_psw);
                    for(int i=0;i<strlen(char_ssid);i++)
                    {
                        cfgHead[i+6]=char_ssid[i];
                    }
                    int j=strlen(cfgHead);
                    for(int i=0;i<strlen(char_psw);i++)
                    {
                        cfgHead[i+j]=char_psw[i];
                    }
                    
                    printf("cfgHead=%s || length= %lu",cfgHead,strlen(cfgHead));
                    send(fd, cfgHead, strlen(cfgHead), 0);
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        char buf[30];
                        int length=sizeof(buf);
                        printf("进入AP模式的接收返回！");
                        recv(fd, buf, length, 0);
                        printf("buf=%s",buf);
                        // 耗时的操作
                        if(buf[0]=='['){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // 更新界面
                                
                            });
                        }
                    });
                    
                    
                }
            }
            else{
                NSLog(@"connect failed");
            }
        }
       
    }
    }

}

- (void)Return{
    
    [self Close_socket];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)Stop_match{
    [self.Wait_view setHidden:YES];
    [myTimer setFireDate:[NSDate distantFuture]];//关闭定时器
    isSendPacket=0;
    [self Close_socket];
}

-(void)Close_socket{
    @try {
        if (ser_sockfd>=0) {
            close(ser_sockfd);
             NSLog(@"关闭socket");
        }
    } @catch (NSException *exception) {
        NSLog(@"关闭socket出错");
    }
}

- (IBAction)B_add:(id)sender {
    [self.View_add setHidden:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField

{
    
    //NSLog(@"textFieldDidBeginEditing");
    
    CGRect frame = textField.frame;
    
    CGFloat heights = self.view.frame.size.height;
    
    // 当前点击textfield的坐标的Y值 + 当前点击textFiled的高度 - （屏幕高度- 键盘高度 - 键盘上tabbar高度）
    
    // 在这一部 就是了一个 当前textfile的的最大Y值 和 键盘的最全高度的差值，用来计算整个view的偏移量
    
    int offset = frame.origin.y + 42- ( heights - 216.0-35.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;
    
    float height = self.view.frame.size.height;
    
    if(offset > 0)
        
    {
        
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        
        self.view.frame = rect;
        
    }
    
    [UIView commitAnimations];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.SSID isExclusiveTouch]) {
        [self.SSID resignFirstResponder];
    }
    if (![self.PSW isExclusiveTouch]) {
        [self.PSW resignFirstResponder];
    }
    
    //NSLog(@"touchesBegan");
    
    [self.view endEditing:YES];
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
