//
//  C7_controller.m
//  xlinkDemo
//
//  Created by kingcom on 16/5/13.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import "HexInputViewController.h"
#import "DeviceEntity.h"
#import "XLinkExportObject.h"
#import "AppDelegate.h"
#import "ScanDeviceViewController.h"
#import "ViewController.h"
#import "Reachability.h"
#import "MatchViewController.h"
#import "List.h"
#import "C7_controller.h"

@interface C7_controller ()<UIActionSheetDelegate, UIAlertViewDelegate>
{
    BOOL         isMatch;
    DeviceEntity *_device;
    BOOL         isON;
    
    int          n;
    NSString * _input,*_psw,*_city;
    UIAlertView *Name,*Auther,*Clean,*Relogin,*Version,*Reset_filter;
    bool isopen,iswifi,islock,islight,ison;
    int roll1,roll2,roll3;
    dispatch_queue_t myQueue;
    NSTimer *timer,*timer1,*timer2;
    Reachability  *hostReach,*wifiReach,*internetReach ;
    //解析XML
    NSString *currentElement;
    
    NSString *currentValue;
    
    NSMutableDictionary *rootDic;
    
    NSMutableArray *finalArray;
    NSArray *keyElements,*rootElements;
}
@end
@implementation C7_controller

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


-(void)setDevice:(DeviceEntity*)device{
    NSLog(@"设置设备。");
    _device = device;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    isON=true;
    // Do any additional setup after loading the view.
    [self Adapter];
    
    
    _input = @"";
    islight=iswifi=true;
    islock=isopen=ison=false;
    roll1=roll3=roll2=1;
    timer =[NSTimer scheduledTimerWithTimeInterval:40.0 target:self selector:@selector(Send_check) userInfo:nil repeats:YES];

    [self.B_power setHidden:YES];
    NSString *d_Name = [[NSUserDefaults standardUserDefaults] objectForKey:[_device getMacAddressString]];
    if (d_Name) {
        self.L_name.text=d_Name;
    }
    //添加滤网重置点击事件
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage)];
    UITapGestureRecognizer *singleTap1 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage)];
    UITapGestureRecognizer *singleTap2 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage)];
    [self.P_filter_change addGestureRecognizer:singleTap2];
    [self.P_filter addGestureRecognizer:singleTap1];
    [self.L_filter addGestureRecognizer:singleTap];
    self.P_filter_change.userInteractionEnabled=YES;
    self.P_filter.userInteractionEnabled=YES;
    self.L_filter.userInteractionEnabled=YES;
}

//滤网重置
-(void)onClickImage{
    NSLog(@"重置滤网命令");
    Reset_filter = [[UIAlertView alloc] initWithTitle:@"复位提示" message:@"更换滤芯前请勿进行复位操作，复位后滤芯寿命将重新计算，为保证数据准确性，请更换后进行操作。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"复位", nil];
    Reset_filter.tag=1;
    [Reset_filter show];
    //[self sendData:RESET_FILTER];
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
        //all view
        self.view_1.frame=CGRectMake(0,20,320,90);
        self.view_2.frame=CGRectMake(0,110,320,185);
        self.view_3.frame=CGRectMake(0,295,320,185);
        self.view_4.frame=CGRectMake(0,110,320,370);
        //view1
        self.B_left_arrow.frame=CGRectMake(0,12,59,31);
        self.B_right_arrow.frame=CGRectMake(261,12,59,31);
        self.L_name.frame=CGRectMake(56,12,208,30);
        self.B_power.frame=CGRectMake(146,51,29,33);
        //view2
        self.P_wifi.frame=CGRectMake(44,18,29,24);
        self.B_lock.frame=CGRectMake(121,16,21,26);
        self.P_filter.frame=CGRectMake(194,18,24,24);
        self.L_filter.frame=CGRectMake(226,18,74,24);
        self.P_filter_change.frame=CGRectMake(194,18,83,24);
        
        self.P_b1.frame=CGRectMake(61,78,43,121);
        self.P_b2.frame=CGRectMake(110,78,43,121);
        self.P_b3.frame=CGRectMake(160,78,43,121);
        self.P_pm.frame=CGRectMake(206,78,60,20);
        self.P_ug.frame=CGRectMake(206,118,59,25);
        
        self.P_fug.frame=CGRectMake(207,144,59,24);
        //view3
        self.P_bar1.frame=CGRectMake(80,10,2,155);
        self.P_bar2.frame=CGRectMake(160,10,2,155);
        self.P_bar3.frame=CGRectMake(240,10,2,155);
        
        self.P_mode4.frame=CGRectMake(29,40,30,14);
        self.P_mode3.frame=CGRectMake(29,63,30,14);
        self.P_mode2.frame=CGRectMake(29,85,30,14);
        self.P_mode1.frame=CGRectMake(29,107,30,14);
        self.B_mode.frame=CGRectMake(24,128,40,40);
        
        
        self.P_fun4.frame=CGRectMake(116,40,9,14);
        self.P_fun3.frame=CGRectMake(116,63,9,14);
        self.P_fun2.frame=CGRectMake(116,85,9,14);
        self.P_fun1.frame=CGRectMake(116,107,9,14);
        self.B_fun.frame=CGRectMake(102,128,40,40);
        
        self.P_time4.frame=CGRectMake(185,40,37,14);
        self.P_time3.frame=CGRectMake(185,63,37,14);
        self.P_time2.frame=CGRectMake(185,85,37,14);
        self.P_time1.frame=CGRectMake(185,107,37,14);
        self.B_time.frame=CGRectMake(183,128,40,40);
        
        self.P_light.frame=CGRectMake(267,94,30,27);
        self.B_light.frame=CGRectMake(262,128,40,40);
        //view4
        self.B_open.frame=CGRectMake(112,133,97,103);
    }
    //iphone 5
    if (width==320 && height==568) {
        //all view
        self.view_1.frame=CGRectMake(0,20,320,95);
        self.view_2.frame=CGRectMake(0,115,320,245);
        self.view_3.frame=CGRectMake(0,360,320,209);
        self.view_4.frame=CGRectMake(0,115,320,453);
        //view1
        self.B_left_arrow.frame=CGRectMake(0,12,59,31);
        self.B_right_arrow.frame=CGRectMake(261,12,59,31);
        self.L_name.frame=CGRectMake(51,13,218,30);
        self.B_power.frame=CGRectMake(146,55,29,32);
        //view2
        self.P_wifi.frame=CGRectMake(35,42,29,24);
        self.B_lock.frame=CGRectMake(120,42,21,26);
        self.P_filter.frame=CGRectMake(199,45,24,24);
        self.L_filter.frame=CGRectMake(231,45,69,24);
        self.P_filter_change.frame=CGRectMake(199,45,83,24);
        
        self.P_b1.frame=CGRectMake(59,123,43,121);
        self.P_b2.frame=CGRectMake(109,123,43,121);
        self.P_b3.frame=CGRectMake(160,123,43,121);
        self.P_pm.frame=CGRectMake(211,123,60,20);
        self.P_ug.frame=CGRectMake(211,163,59,25);
       
        self.P_fug.frame=CGRectMake(211,190,59,24);
        //view3
        self.P_bar1.frame=CGRectMake(80,15,2,175);
        self.P_bar2.frame=CGRectMake(160,15,2,175);
        self.P_bar3.frame=CGRectMake(240,15,2,175);
        
        self.P_mode4.frame=CGRectMake(29,40,30,14);
        self.P_mode3.frame=CGRectMake(29,63,30,14);
        self.P_mode2.frame=CGRectMake(29,85,30,14);
        self.P_mode1.frame=CGRectMake(29,107,30,14);
        self.B_mode.frame=CGRectMake(24,145,43,43);
        
        
        self.P_fun4.frame=CGRectMake(116,40,9,14);
        self.P_fun3.frame=CGRectMake(116,63,9,14);
        self.P_fun2.frame=CGRectMake(116,85,9,14);
        self.P_fun1.frame=CGRectMake(116,107,9,14);
        self.B_fun.frame=CGRectMake(102,145,43,43);
        
        self.P_time4.frame=CGRectMake(185,40,37,14);
        self.P_time3.frame=CGRectMake(185,63,37,14);
        self.P_time2.frame=CGRectMake(185,85,37,14);
        self.P_time1.frame=CGRectMake(185,107,37,14);
        self.B_time.frame=CGRectMake(182,145,43,43);
        
        self.P_light.frame=CGRectMake(267,94,30,27);
        self.B_light.frame=CGRectMake(261,145,43,43);
        //view4
        self.B_open.frame=CGRectMake(112,175,97,103);
    }
    //iphone 6
    if (width==375 && height==667) {
        
    }
    //iphone 6+
    if (width==414 && height==736) {
        
    }
}

-(void)Send_check{
    NSLog(@"[发送查询命令]");
    [self sendData:CHECK];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"控制界面出现");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendPipeData:) name:kOnSendPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendLocalPipeData:) name:kOnSendLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvPipeData:) name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceStateChanged:) name:kOnDeviceStateChanged object:nil];
    [self Send_check];
}

-(void)onDeviceStateChanged:(NSNotification*)notify {
    NSLog(@"设备状态改变。");
    DeviceEntity *device = [notify.object objectForKey:@"device"];
    if ([device.getMacAddressString isEqualToString:_device.getMacAddressString]) {
        _device=device;
        if (device.isConnected) {
            NSLog(@"设备[%@]在线",device.getMacAddressSimple);
            isON=true;
            //[self showMessage:@"设备在线"];
        }else{
            NSLog(@"设备[%@]离线",device.getMacAddressSimple);
            isON=false;
            //[self showMessage:@"设备离线"];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"控制界面消失");
    
    [timer setFireDate:[NSDate distantFuture]];//关闭定时器
    [timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
    [timer2 setFireDate:[NSDate distantFuture]];//关闭定时器
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//发送数据通用函数
-(void)sendData:(NSString*)data
{
    NSData * data1 = [self hexToData:data];
    
    //[self showActivityView:YES];
    
    int sendResult = -1;
    if (isON) {
        if (_device.isLANOnline) {
            NSLog(@"设备局域网在线");
            sendResult = [[XLinkExportObject sharedObject] sendLocalPipeData:_device andPayload:data1];
        }else if(_device.isWANOnline){
            NSLog(@"设备外网在线");
            sendResult = [[XLinkExportObject sharedObject] sendPipeData:_device andPayload:data1];
        }

    }else{
        [self showMessage:@"设备离线"];
    }
    
    if( sendResult < 0 ) {
       
        NSLog(@"发送命令失败！");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//显示消息框
-(void)showWarningAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

-(void)pushViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *View = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
    [View Who_in];
    [self.navigationController pushViewController:View animated:YES];
}

- (NSData*)hexToData:(NSString *)hexString {
    
    int len = (int)[hexString length] / 2;
    char * bytes = (char *)malloc(len);
    C7hexToBytes(bytes, [hexString UTF8String], (int)[hexString length]);
    
    NSData * data = [[NSData alloc] initWithBytes:bytes length:len];
    
    free(bytes);
    return data;
}

void C7hexToBytes(char * bytes, const char * hexString, int hexLength)
{
    char * pos = (char *)hexString;
    int count = 0;
    for(count = 0; count < hexLength / 2; count++) {
        sscanf(pos, "%2hhx", &bytes[count]);
        pos += 2 * sizeof(char);
    }
}
-(void)pushList{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    List *view = [storyBoard instantiateViewControllerWithIdentifier:@"List"];
    [view initData];
    [view isHex:YES];
    [self.navigationController pushViewController:view animated:YES];
}
-(void)pushScanDeviceViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ScanDeviceViewController *scanView = [storyBoard instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];
    [scanView initData];
    [self.navigationController pushViewController:scanView animated:YES];
}
-(void)pushMatchViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MatchViewController *View = [storyBoard instantiateViewControllerWithIdentifier:@"MatchViewController"];
    [self.navigationController pushViewController:View animated:YES];
}
-(void)pushMenu{
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"菜单列表" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"修改名称" otherButtonTitles:@"退出登录",@"查看版本号", nil];
    [sheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            Name = [[UIAlertView alloc] initWithTitle:@"设备名称修改" message:@"请输入设备新名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            [Name setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [Name textFieldAtIndex:0].placeholder = @"设备名称(不超过六位)";
            //[Name textFieldAtIndex:0].keyboardType=UIKeyboardTypeDefault;
            Name.tag=0;
            [Name show];
            
        }
            break;
        case 1:
            Relogin = [[UIAlertView alloc] initWithTitle:@"是否重新登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            Relogin.tag=3;
            [Relogin show];
            break;
        case 2:{
            NSString *_version=[NSString stringWithFormat:@"异亮生活的版本号：%@",VERSION];
            Version = [[UIAlertView alloc] initWithTitle:@"版本号" message:_version delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            Version.tag=4;
            [Version show];
            
        }
            break;
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"clickButtonAtIndex:%ld",(long)buttonIndex);
    switch (alertView.tag) {
        case 0:
            if (buttonIndex == 1) {
                NSString *name=[Name textFieldAtIndex:0].text;
                if(name.length!=0)
                {
                    if (name.length<=15) {
                        NSLog(@"修改设备名字成功");
                        [[NSUserDefaults standardUserDefaults] setObject:name forKey:[_device getMacAddressString]];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        self.L_name.text=name;
                    }
                    else{
                        [self showMessage:@"设备名称过长"];
                    }
                    
                }
                else
                {
                    [self showMessage:@"设备名不能为空"];
                }
            }
            break;
        case 1:
            if (buttonIndex == 1) {
                [self sendData:RESET_FILTER];
            }
            break;
        case 2:
            if (buttonIndex == 1) {
                [timer setFireDate:[NSDate distantFuture]];//关闭定时器
                [self CleanDeviceCache:_device];
                //[self pushList];
                [self Return_list];
            }
            break;
        case 3:
            if (buttonIndex == 1) {
                [timer setFireDate:[NSDate distantFuture]];//关闭定时器
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userData"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"myuid"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mypsw"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[XLinkExportObject sharedObject] logout];
                [[XLinkExportObject sharedObject] stop];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            break;
        default:
            break;
    }
}

-(void)push_match{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MatchViewController *View = [storyBoard instantiateViewControllerWithIdentifier:@"MatchViewController"];
    [self presentViewController:View animated:YES completion:nil];
}

//把device记录在本地删除
-(void)CleanDeviceCache:(DeviceEntity *)device{
    NSMutableDictionary *deviceDic = [[NSMutableDictionary alloc] initWithDictionary:[device getDictionaryFormat]];
    NSMutableArray *deviceArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"devices"]];
    for (NSDictionary *dic in deviceArr) {
        if ([[deviceDic objectForKey:@"macAddress"] isEqualToString:[dic objectForKey:@"macAddress"]]) {
            [deviceArr removeObject:dic];
            break;
        }
    }
    //[deviceArr addObject:deviceDic];
    [[NSUserDefaults standardUserDefaults] setObject:deviceArr forKey:@"devices"];
}


-(void)setMatch:(BOOL)is{
    isMatch=is;
}

- (void)notifySendPipeResult:(NSNotification*)notify {
    
    int result = [[notify.object objectForKey:@"result"] intValue];
    if (result == 0){
        NSLog(@"发送PIPE数据成功");
    }else{
        NSLog(@"发送PIPE数据失败");
    }
}

//接收数据的地方
- (void)RecvPipeData:(NSNotification*)notify {
    DeviceEntity *my_device = [notify.object objectForKey:@"device"];
    NSLog(@"%@",my_device.getMacAddressString);
    if ([my_device.getMacAddressString isEqualToString:_device.getMacAddressString]) {
        
        NSData * payload = [notify.object objectForKey:@"payload"];
        // DeviceEntity *device = [notify.object objectForKey:@"device"];
        if (payload != nil){
            NSString *output = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
            NSLog(@"接收信息=%@",output);
            output=[output substringWithRange:NSMakeRange(2,output.length-2)];
            //处理返回数据更新UI
            NSLog(@"output=%@",output);
            //开关
            if ([output hasPrefix:@"1"]) {
                NSString *ss = [output substringWithRange:NSMakeRange(2,1)];
                if ([ss isEqualToString:@"1"]) {
                    NSLog(@"开启净化器");
                    [self.view_4 setHidden:YES];
                    [self.B_power setHidden:NO];
                    isopen=true;
                }
                else
                {
                    NSLog(@"关闭净化器");
                    [self.view_4 setHidden:NO];
                    [self.B_power setHidden:YES];
                    isopen=false;
                }
            }
            //童锁
            if ([output hasPrefix:@"2"]) {
                NSString *ss = [output substringWithRange:NSMakeRange(2, 1)];
                if ([ss isEqualToString:@"1"]) {
                    islock=true;
                    //[self.Lock setImage:[UIImage imageNamed:@"open_lock.png"]];
                    [self.B_lock setBackgroundImage:[UIImage imageNamed:@"b8_lock_on.png"] forState:UIControlStateNormal];
                }
                else
                {
                    islock=false;
                    //[self.Lock setImage:[UIImage imageNamed:@"close_lock.png"]];
                    [self.B_lock setBackgroundImage:[UIImage imageNamed:@"b8_lock_off.png"] forState:UIControlStateNormal];
                }
            }
            
            if ([output hasPrefix:@"3"]) {
                
                
            }
            
            //档位
            if ([output hasPrefix:@"4"]) {
                NSString *hh = [output substringWithRange:NSMakeRange(2, 1)];
                NSString *ss = [output substringWithRange:NSMakeRange(4, 1)];
                
                if ([hh intValue]==1 ) {
                    roll1=2;
                    [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_on.png"]];
                    [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_off.png"]];
                    [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_off.png"]];
                    [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_off.png"]];
                    switch ([ss intValue]) {
                        case 0:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            roll2=1;
                            break;
                        case 1:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_onel.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            roll2=2;
                            break;
                        case 2:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twol.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            roll2=3;
                            break;
                        case 3:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threel.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            roll2=4;
                            break;
                        case 4:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourl.png"]];
                            roll2=1;
                            break;
                        default:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            NSLog(@"档位更新错误！");
                            roll2=1;
                        break;
                    }
                    
                }else if ([hh intValue]==0 ){
                    [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_off.png"]];
                    [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_off.png"]];
                    [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_off.png"]];
                    [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_off.png"]];
                    switch ([ss intValue]) {
                        case 0:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            roll2=1;
                            break;
                        case 1:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_onel.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            roll2=2;
                            break;
                        case 2:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twol.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            roll2=3;
                            break;
                        case 3:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threel.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            roll2=4;
                            break;
                        case 4:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourl.png"]];
                            roll2=1;
                            break;
                        default:
                            [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                            [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                            [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                            [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                            
                            NSLog(@"档位更新错误！");
                            roll2=1;
                            break;
                    }
                    
                }else if ([hh intValue]==2 ){
                    roll1=3;
                    [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_off.png"]];
                    [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_on.png"]];
                    [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_off.png"]];
                    [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_off.png"]];
                    roll2=2;
                    islight=false;
                    [self Close_all];
                    
                }else if ([hh intValue]==3 ){
                    roll1=1;
                    [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_off.png"]];
                    [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_off.png"]];
                    [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_on.png"]];
                    [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_off.png"]];
                    
                    [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                    [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                    [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                    [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                    
                    roll2=1;
                    
                    
                }else if ([hh intValue]==4 ){
                    roll1=1;
                    [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_off.png"]];
                    [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_off.png"]];
                    [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_off.png"]];
                    [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_on.png"]];
                    
                    [self Close_all];
                }
            }
            //定时关机
            if ([output hasPrefix:@"8"]) {
                NSString *ss = [output substringWithRange:NSMakeRange(2, 1)];
                
                switch ([ss intValue]) {
                    case 0:
                        [self.P_time1 setImage:[UIImage imageNamed:@"b8_time1_off.png"]];
                        [self.P_time2 setImage:[UIImage imageNamed:@"b8_time2_off.png"]];
                        [self.P_time3 setImage:[UIImage imageNamed:@"b8_time3_off.png"]];
                        [self.P_time4 setImage:[UIImage imageNamed:@"b8_time4_off.png"]];
                        roll3=1;
                        break;
                    case 1:
                        [self.P_time1 setImage:[UIImage imageNamed:@"b8_time1_on.png"]];
                        [self.P_time2 setImage:[UIImage imageNamed:@"b8_time2_off.png"]];
                        [self.P_time3 setImage:[UIImage imageNamed:@"b8_time3_off.png"]];
                        [self.P_time4 setImage:[UIImage imageNamed:@"b8_time4_off.png"]];
                        roll3=2;
                        break;
                    case 2:
                        [self.P_time1 setImage:[UIImage imageNamed:@"b8_time1_off.png"]];
                        [self.P_time2 setImage:[UIImage imageNamed:@"b8_time2_on.png"]];
                        [self.P_time3 setImage:[UIImage imageNamed:@"b8_time3_off.png"]];
                        [self.P_time4 setImage:[UIImage imageNamed:@"b8_time4_off.png"]];
                        roll3=3;
                        break;
                    case 3:
                        [self.P_time1 setImage:[UIImage imageNamed:@"b8_time1_off.png"]];
                        [self.P_time2 setImage:[UIImage imageNamed:@"b8_time2_off.png"]];
                        [self.P_time3 setImage:[UIImage imageNamed:@"b8_time3_on.png"]];
                        [self.P_time4 setImage:[UIImage imageNamed:@"b8_time4_off.png"]];
                        roll3=4;
                        break;
                    case 4:
                        [self.P_time1 setImage:[UIImage imageNamed:@"b8_time1_off.png"]];
                        [self.P_time2 setImage:[UIImage imageNamed:@"b8_time2_off.png"]];
                        [self.P_time3 setImage:[UIImage imageNamed:@"b8_time3_off.png"]];
                        [self.P_time4 setImage:[UIImage imageNamed:@"b8_time4_on.png"]];
                        roll3=0;
                        break;
                    default:
                        [self.P_time1 setImage:[UIImage imageNamed:@"b8_time1_off.png"]];
                        [self.P_time2 setImage:[UIImage imageNamed:@"b8_time2_off.png"]];
                        [self.P_time3 setImage:[UIImage imageNamed:@"b8_time3_off.png"]];
                        [self.P_time4 setImage:[UIImage imageNamed:@"b8_time4_off.png"]];
                        roll3=1;
                        break;
                }
                
            }
            
            if ([output hasPrefix:@"5"]) {
                
            }
            
            if ([output hasPrefix:@"6"]) {
                
            }
            //查询返回
            if ([output hasPrefix:@"7"]) {
                
                NSArray *list=[output componentsSeparatedByString:@"|"];
                NSString *open = list[6];
                
                if([open isEqualToString:@"1"])
                {
                    
                    [self.view_4 setHidden:YES];
                    [self.B_power setHidden:NO];
                    isopen=true;
                    
                    //解析各数据
                    NSString *pm     =list[2];
                    NSString *autu   =list[3];
                    NSString *level  =list[4];
                    NSString *lock   =list[5];
                    NSString *shidu  =list[8];
                    NSString *water  =list[10];
                    NSString *filter =list[11];
                    NSString *light  =list[12];
                    //更新湿度
                    //NSString *P1=[shidu substringWithRange:NSMakeRange(0,1)];
                    //NSString *P2=[shidu substringWithRange:NSMakeRange(1,1)];
                    //NSLog(@"P1=%@,P2=%@",P1,P2);
                    
                    //更新PM2.5
                    NSString *pm1=[pm substringWithRange:NSMakeRange(2,1)];
                    NSString *pm2=[pm substringWithRange:NSMakeRange(3,1)];
                    NSString *pm3=[pm substringWithRange:NSMakeRange(4,1)];
                    switch ([pm1 intValue]) {
                        case 0:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_0.png"]];
                            
                            break;
                        case 1:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_1.png"]];
                            
                            break;
                        case 2:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_2.png"]];
                            
                            break;
                        case 3:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_3.png"]];
                            
                            break;
                        case 4:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_4.png"]];
                            
                            break;
                        case 5:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_5.png"]];
                            
                            break;
                        case 6:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_6.png"]];
                            
                            break;
                        case 7:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_7.png"]];
                            
                            break;
                        case 8:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_8.png"]];
                            
                            break;
                        case 9:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_9.png"]];
                           
                            break;
                        default:
                            [self.P_b1 setImage:[UIImage imageNamed:@"N_0.png"]];
                            
                            break;
                    }
                    switch ([pm2 intValue]) {
                        case 0:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_0.png"]];
                            
                            break;
                        case 1:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_1.png"]];
                            
                            break;
                        case 2:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_2.png"]];
                            
                            break;
                        case 3:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_3.png"]];
                            
                            break;
                        case 4:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_4.png"]];
                           
                            break;
                        case 5:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_5.png"]];
                          
                            break;
                        case 6:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_6.png"]];
                          
                            break;
                        case 7:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_7.png"]];
                            
                            break;
                        case 8:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_8.png"]];
                            
                            break;
                        case 9:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_9.png"]];
                           
                            break;
                        default:
                            [self.P_b2 setImage:[UIImage imageNamed:@"N_0.png"]];
                            
                            break;
                    }
                    switch ([pm3 intValue]) {
                        case 0:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_0.png"]];
                            
                            break;
                        case 1:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_1.png"]];
                            
                            break;
                        case 2:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_2.png"]];
                            
                            break;
                        case 3:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_3.png"]];
                           
                            break;
                        case 4:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_4.png"]];
                            
                            break;
                        case 5:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_5.png"]];
                            
                            break;
                        case 6:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_6.png"]];
                            
                            break;
                        case 7:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_7.png"]];
                            
                            break;
                        case 8:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_8.png"]];
                            
                            break;
                        case 9:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_9.png"]];
                            
                            break;
                        default:
                            [self.P_b3 setImage:[UIImage imageNamed:@"N_0.png"]];
                            
                            break;
                    }
                    
                    //更新档位风速
                    if ([autu intValue]==1) {
                        roll1=2;
                        [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_on.png"]];
                        [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_off.png"]];
                        [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_off.png"]];
                        [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_off.png"]];
                        
                        switch ([level intValue]) {
                            case 0:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                                
                                roll2=1;
                                break;
                            case 1:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_onel.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                                
                                roll2=2;
                                break;
                            case 2:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twol.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                               
                                roll2=3;
                                break;
                            case 3:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threel.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                                
                                roll2=4;
                                break;
                            case 4:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourl.png"]];
                                roll2=1;
                                break;
                            default:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                                
                                NSLog(@"档位更新错误！");
                                roll2=1;
                                break;
                        }
                        
                    }else if([autu intValue]==0){
                        roll1=1;
                        [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_off.png"]];
                        [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_off.png"]];
                        [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_off.png"]];
                        [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_off.png"]];
                        switch ([level intValue]) {
                            case 0:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                                
                                roll2=1;
                                break;
                            case 1:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_onel.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                                
                                roll2=2;
                                break;
                            case 2:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twol.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                               
                                roll2=3;
                                break;
                            case 3:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threel.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                               
                                roll2=4;
                                break;
                            case 4:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourl.png"]];
                                
                                roll2=1;
                                break;
                            default:
                                [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
                                [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
                                [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
                                [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
                                
                                NSLog(@"档位更新错误！");
                                roll2=1;
                                break;
                        }
                    }else if([autu intValue]==2){
                        roll1=3;
                        [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_off.png"]];
                        [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_on.png"]];
                        [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_off.png"]];
                        [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_off.png"]];
                        light=0;
                        [self Close_all];
                    }else if([autu intValue]==3){
                        roll1=1;
                        [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_off.png"]];
                        [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_off.png"]];
                        [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_on.png"]];
                        [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_off.png"]];
                        
                    }else if([autu intValue]==4){
                        roll1=1;
                        [self.P_mode1 setImage:[UIImage imageNamed:@"b8_mode1_off.png"]];
                        [self.P_mode2 setImage:[UIImage imageNamed:@"b8_mode2_off.png"]];
                        [self.P_mode3 setImage:[UIImage imageNamed:@"b8_mode3_off.png"]];
                        [self.P_mode4 setImage:[UIImage imageNamed:@"b8_mode4_on.png"]];
                        light=0;
                        [self Close_all];
                        
                    }
                    if ([lock isEqualToString:@"1"]) {
                        islock=true;
                        //[self.Lock setImage:[UIImage imageNamed:@"open_lock.png"]];
                        [self.B_lock setBackgroundImage:[UIImage imageNamed:@"b8_lock_on.png"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        islock=false;
                        //[self.Lock setImage:[UIImage imageNamed:@"close_lock.png"]];
                        [self.B_lock setBackgroundImage:[UIImage imageNamed:@"b8_lock_off.png"] forState:UIControlStateNormal];
                    }
                    
                    
                    if ([filter isEqualToString:@"00"]) {
                        [self.P_filter setHidden:YES];
                        [self.L_filter setHidden:YES];
                        [self.P_filter_change setHidden:NO];
                    }
                    else
                    {
                        [self.P_filter_change setHidden:YES];
                        [self.P_filter setHidden:NO];
                        [self.L_filter setHidden:NO];
                        
                        NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%%",filter]];
                        self.L_filter.text=astring;
                    }
                    
                    if ([light isEqualToString:@"0"])
                    {
                        [self.P_light setImage:[UIImage imageNamed:@"b8_light_off.png"]];
                        islight=false;
                    }
                    else
                    {
                        [self.P_light setImage:[UIImage imageNamed:@"b8_light_on.png"]];
                        islight=true;
                    }
                }
                else
                {
                    [self.view_4 setHidden:NO];
                    [self.B_power setHidden:YES];
                    isopen=false;
                }
                
                
            }
            
            if ([output hasPrefix:@"9"]) {
                NSString *ss = [output substringWithRange:NSMakeRange(2, 1)];
                if ([ss isEqualToString:@"0"])
                {
                    [self.P_light setImage:[UIImage imageNamed:@"b8_light_off.png"]];
                    islight=false;
                }
                else
                {
                    [self.P_light setImage:[UIImage imageNamed:@"b8_light_on.png"]];
                    islight=true;
                }
            }
        }
    }
}

-(void)Close_all{
    [self.P_fun1 setImage:[UIImage imageNamed:@"flow_oneh.png"]];
    [self.P_fun2 setImage:[UIImage imageNamed:@"flow_twoh.png"]];
    [self.P_fun3 setImage:[UIImage imageNamed:@"flow_threeh.png"]];
    [self.P_fun4 setImage:[UIImage imageNamed:@"flow_fourh.png"]];
   
    
    [self.P_time1 setImage:[UIImage imageNamed:@"b8_time1_off.png"]];
    [self.P_time2 setImage:[UIImage imageNamed:@"b8_time2_off.png"]];
    [self.P_time3 setImage:[UIImage imageNamed:@"b8_time3_off.png"]];
    [self.P_time4 setImage:[UIImage imageNamed:@"b8_time4_off.png"]];
    
}

-(void)onSendPipeData:(NSNotification*)notify {
    [self performSelectorOnMainThread:@selector(notifySendPipeResult:) withObject:notify waitUntilDone:NO];
}

-(void)onSendLocalPipeData:(NSNotification*)notify {
    [self performSelectorOnMainThread:@selector(notifySendPipeResult:) withObject:notify waitUntilDone:NO];
}

- (void)onRecvPipeData:(NSNotification*)notify{
    [self performSelectorOnMainThread:@selector(RecvPipeData:) withObject:notify waitUntilDone:NO];
}

-(void)Return_list{
    if (isMatch) {
        NSLog(@"pushList");
        [self pushList];
    }else{
        NSLog(@"POP");
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)BA_power:(id)sender {
    [self sendData:CLOSE];
}
- (IBAction)BA_lock:(id)sender {
    if (islock) {
        [self sendData:UNLOCK];
    }
    else
    {
        [self sendData:LOCK];
    }
}
- (IBAction)BA_mode:(id)sender {
    switch (roll1) {
        case 1:
            [self sendData:SMART];
            break;
        case 2:
            [self sendData:SLEEP];
            break;
        case 3:
            [self sendData:MODE3];
            break;
        default:
            break;
    }
    
}

- (IBAction)BA_fun:(id)sender {
    switch (roll2) {
        case 1:
            [self sendData:MUTE];
            break;
        case 2:
            [self sendData:LOW];
            break;
        case 3:
            [self sendData:CENTER];
            break;
        case 4:
            [self sendData:HIGH];
            break;
        default:
            break;
    }
    
}

- (IBAction)BA_time:(id)sender {
    switch (roll3) {
        case 1:
            [self sendData:TIME1];
            break;
        case 2:
            [self sendData:TIME2];
            break;
        case 3:
            [self sendData:TIME4];
            break;
        case 4:
            [self sendData:TIME8];
            break;
        case 0:
            [self sendData:TIME0];
            break;
        default:
            break;
    }
    
}

- (IBAction)BA_light:(id)sender {
    if (islight) {
        [self sendData:LIGHT0];
    }
    else
    {
        [self sendData:LIGHT1];
    }
}
- (IBAction)BA_open:(id)sender {
    [self sendData:OPEN];
}

- (IBAction)BA_right_arrow:(id)sender {
    //[self pushMenu];
}

- (IBAction)BA_left_arrow:(id)sender {
    [self Return_list];
}


@end
