//
//  S9_controller.m
//  xlinkDemo
//
//  Created by kingcom on 16/9/26.
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
#import "S9_controller.h"

//s9_controller
@interface S9_controller ()<UIActionSheetDelegate, UIAlertViewDelegate>
{
    BOOL         isMatch;
    DeviceEntity *_device;
    BOOL         bool_on,bool_power,bool_lock,bool_light,bool_send,bool_updata;
    NSInteger    int_fun,int_time,int_light;
    NSTimer      *timer1;
    
    UIImage      *stetchLeftTrack, *stetchRightTrack;
    UIAlertController *filter_alert,*menu_alert;
}
@end
@implementation S9_controller

//内部函数
-(void)setDevice:(DeviceEntity*)device{
    _device = device;
}

-(void)setMatch:(BOOL)is{
    isMatch=is;
}

//view回调
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    //init uislider
    _Sli_light.transform = CGAffineTransformMakeRotation(-M_PI_2);
    //滑块拖动时的事件
    [_Sli_light addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    //滑动拖动后的事件
    [_Sli_light addTarget:self action:@selector(sliderDragUp) forControlEvents:UIControlEventTouchUpInside];
    int_light=-1;
    bool_send=YES;
    bool_updata=YES;
    [self Init_data];
    [self reset_filter_alert];
    [self menu_alert];
    [_View_add setHidden:YES];
    
    //name
    NSString *d_Name = [[NSUserDefaults standardUserDefaults] objectForKey:[_device getMacAddressString]];
    if (d_Name) {
        _Lab_top_name.text=d_Name;
    }
    
    // 设置各按键响应
    _View_l.userInteractionEnabled=YES;
    _Ima_menu.userInteractionEnabled=YES;
    _Ima_lock.userInteractionEnabled=YES;
    _Ima_filter.userInteractionEnabled=YES;
    
    _Ima_white.userInteractionEnabled=YES;
    _Ima_yellow.userInteractionEnabled=YES;
    _Ima_red.userInteractionEnabled=YES;
    _Ima_blue.userInteractionEnabled=YES;
    _Ima_pink.userInteractionEnabled=YES;
    _Ima_color.userInteractionEnabled=YES;
    _Ima_main_color.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *Tab_view_l = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Return_list)];
    UITapGestureRecognizer *Tab_menu = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_menu)];
    UITapGestureRecognizer *Tab_lock = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_lock)];
    UITapGestureRecognizer *Tab_filter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_filter)];
    UITapGestureRecognizer *Tab_white = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_white)];
    UITapGestureRecognizer *Tab_yellow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_yellow)];
    UITapGestureRecognizer *Tab_red = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_red)];
    UITapGestureRecognizer *Tab_blue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_blue)];
    UITapGestureRecognizer *Tab_pink = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_pink)];
    UITapGestureRecognizer *Tab_color = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_color)];
    UITapGestureRecognizer *Tab_main_color = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_tap_main_color:)];
    UIPanGestureRecognizer *Pan_main_color = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_pan_main_color:)];
    
    Tab_main_color.delegate=self;
    Pan_main_color.delegate=self;
    
    [_View_l addGestureRecognizer:Tab_view_l];
    [_Ima_menu addGestureRecognizer:Tab_menu];
    [_Ima_lock addGestureRecognizer:Tab_lock];
    [_Ima_filter addGestureRecognizer:Tab_filter];
    [_Ima_white addGestureRecognizer:Tab_white];
    [_Ima_yellow addGestureRecognizer:Tab_yellow];
    [_Ima_red addGestureRecognizer:Tab_red];
    [_Ima_blue addGestureRecognizer:Tab_blue];
    [_Ima_pink addGestureRecognizer:Tab_pink];
    [_Ima_color addGestureRecognizer:Tab_color];
    [_Ima_main_color addGestureRecognizer:Tab_main_color];
    [_Ima_main_color addGestureRecognizer:Pan_main_color];
    //add_view
    _View_add_return.userInteractionEnabled=YES;
    _Ima_add_c1.userInteractionEnabled=YES;
    _Ima_add_c2.userInteractionEnabled=YES;
    _Ima_add_c3.userInteractionEnabled=YES;
    _Ima_add_c4.userInteractionEnabled=YES;
    _Ima_add_c5.userInteractionEnabled=YES;
    _Ima_add_c6.userInteractionEnabled=YES;
    _Ima_add_c7.userInteractionEnabled=YES;
    _Ima_add_c8.userInteractionEnabled=YES;
    _Ima_add_c9.userInteractionEnabled=YES;
    _Ima_add_c10.userInteractionEnabled=YES;
    _Ima_add_c11.userInteractionEnabled=YES;
    _Ima_add_c12.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *Tab_add_return = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_return)];
    UITapGestureRecognizer *Tab_add_c1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c1)];
    UITapGestureRecognizer *Tab_add_c2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c2)];
    UITapGestureRecognizer *Tab_add_c3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c3)];
    UITapGestureRecognizer *Tab_add_c4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c4)];
    UITapGestureRecognizer *Tab_add_c5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c5)];
    UITapGestureRecognizer *Tab_add_c6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c6)];
    UITapGestureRecognizer *Tab_add_c7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c7)];
    UITapGestureRecognizer *Tab_add_c8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c8)];
    UITapGestureRecognizer *Tab_add_c9 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c9)];
    UITapGestureRecognizer *Tab_add_c10 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c10)];
    UITapGestureRecognizer *Tab_add_c11 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c11)];
    UITapGestureRecognizer *Tab_add_c12 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuc_add_c12)];
    
    [_View_add_return addGestureRecognizer:Tab_add_return];
    [_Ima_add_c1 addGestureRecognizer:Tab_add_c1];
    [_Ima_add_c2 addGestureRecognizer:Tab_add_c2];
    [_Ima_add_c3 addGestureRecognizer:Tab_add_c3];
    [_Ima_add_c4 addGestureRecognizer:Tab_add_c4];
    [_Ima_add_c5 addGestureRecognizer:Tab_add_c5];
    [_Ima_add_c6 addGestureRecognizer:Tab_add_c6];
    [_Ima_add_c7 addGestureRecognizer:Tab_add_c7];
    [_Ima_add_c8 addGestureRecognizer:Tab_add_c8];
    [_Ima_add_c9 addGestureRecognizer:Tab_add_c9];
    [_Ima_add_c10 addGestureRecognizer:Tab_add_c10];
    [_Ima_add_c11 addGestureRecognizer:Tab_add_c11];
    [_Ima_add_c12 addGestureRecognizer:Tab_add_c12];
}

//alert_view
-(void)reset_filter_alert{
    filter_alert = [UIAlertController alertControllerWithTitle:@"复位提示" message:@"更换滤芯前请勿进行复位操作，复位后滤芯寿命将重新计算，为保证数据准确性，请更换后进行操作。" preferredStyle:UIAlertControllerStyleAlert];
    
    [filter_alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // 点击确定按钮的时候, 会调用这个block
        [self sendData:RESET_FILTER];
    }]];
    
    [filter_alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
}

-(void)menu_alert{
    menu_alert=[UIAlertController alertControllerWithTitle:@"菜单" message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    [menu_alert addAction:[UIAlertAction actionWithTitle:@"修改名称" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // 点击确定按钮的时候, 会调用这个block
        
        UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"修改设备名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"请填写新的设备名称";
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            // 点击确定按钮的时候, 会调用这个block
            UITextField *name = alert.textFields.firstObject;
            [[NSUserDefaults standardUserDefaults] setObject:name.text forKey:[_device getMacAddressString]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _Lab_top_name.text=name.text;
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }]];
    
    [menu_alert addAction:[UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // 点击确定按钮的时候, 会调用这个block
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userData"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"myuid"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mypsw"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[XLinkExportObject sharedObject] logout];
        [[XLinkExportObject sharedObject] stop];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *str_ver=[NSString stringWithFormat:@"版本号：%@",app_Version];
    [menu_alert addAction:[UIAlertAction actionWithTitle:str_ver style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // 点击确定按钮的时候, 会调用这个block
    }]];
    [menu_alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
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
    [[NSUserDefaults standardUserDefaults] setObject:deviceArr forKey:@"devices"];
}

//uislider

-(UIImage*)scaleToSize:(UIImage *)image toSize:(CGSize)size

{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    //Determine whether the screen is retina
    if([[UIScreen mainScreen] scale] == 2.0){
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    }else{
        UIGraphicsBeginImageContext(size);
    }
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

-(void)sliderDragUp{
    NSLog(@"sliderDragUp");
    NSInteger n=_Sli_light.value;
    
    if (n==0) {
        [self sendData:LIGHTNESS0];
        NSLog(@"b4=[0]");
    }else if (n==100){
        [self sendData:LIGHTNESS100];
        NSLog(@"b4=[100]");
    }else{
        NSString *b1=@"2642317c";
        NSInteger c2=n/10;
        NSInteger c1=n%10;
        NSInteger c3=303030+c2*100+c1;
        NSString *b2 = [NSString stringWithFormat:@"%ld",(long)c3];
        NSString *b4 = [NSString stringWithFormat:@"%@%@",b1,b2];
        NSLog(@"b4=[%ld]",(long)n);
        
        [self sendData:b4];
    }
    
}

-(void)sliderValueChanged{
    NSInteger n=_Sli_light.value;
    NSLog(@"sliderValueChanged[%ld]",(long)n);
    NSString *mes = [NSString stringWithFormat:@"%ld%%",(long)n];
    _Lab_light.text=mes;
    
    if(n==0 && int_light!=0){
        [self sendData:LIGHTNESS0];
        NSLog(@"b4=[0]");
    }
    else if(n==100 && int_light!=100){
        [self sendData:LIGHTNESS100];
        NSLog(@"b4=[100]");
    }
    else if(labs(n-int_light)>0){
        
        if (bool_send) {
            bool_send=NO;
            timer1= [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(Set_issend) userInfo:nil repeats:NO];
            
            NSString *b1=@"2642317c";
            NSInteger c2=n/10;
            NSInteger c1=n%10;
            NSInteger c3=303030+c2*100+c1;
            NSString *b2 = [NSString stringWithFormat:@"%ld",(long)c3];
            NSString *b4 = [NSString stringWithFormat:@"%@%@",b1,b2];
            NSLog(@"b4=[%ld]",(long)n);
            
            [self sendData:b4];
        }
    }
    int_light=n;
}

-(void)Set_issend{
    bool_send=YES;
}

//init_data
-(void)Init_data{
    bool_power=NO;
    bool_lock=NO;
    bool_light=NO;
    bool_on=YES;
    int_fun=int_time=0;
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

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"控制界面消失");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//发送数据通用函数
- (NSData*)hexToData:(NSString *)hexString {
    
    int len = (int)[hexString length] / 2;
    char * bytes = (char *)malloc(len);
    S9hexToBytes(bytes, [hexString UTF8String], (int)[hexString length]);
    
    NSData * data = [[NSData alloc] initWithBytes:bytes length:len];
    
    free(bytes);
    return data;
}

void S9hexToBytes(char * bytes, const char * hexString, int hexLength)
{
    char * pos = (char *)hexString;
    int count = 0;
    for(count = 0; count < hexLength / 2; count++) {
        sscanf(pos, "%2hhx", &bytes[count]);
        pos += 2 * sizeof(char);
    }
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

-(void)sendData:(NSString*)data
{
    NSData * data1 = [self hexToData:data];
    int sendResult = -1;
    if (bool_on) {
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

-(void)Send_check{
    NSLog(@"[发送查询命令]");
    [self sendData:S9_CHECK];
}

- (void)notifySendPipeResult:(NSNotification*)notify {
    
    int result = [[notify.object objectForKey:@"result"] intValue];
    if (result == 0){
        NSLog(@"发送PIPE数据成功");
    }else{
        NSLog(@"发送PIPE数据失败");
    }
}

//推送各界面
-(void)pushViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *View = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
    [View Who_in];
    [self.navigationController pushViewController:View animated:YES];
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



//SDK回调
-(void)onSendPipeData:(NSNotification*)notify {
    [self performSelectorOnMainThread:@selector(notifySendPipeResult:) withObject:notify waitUntilDone:NO];
}

-(void)onSendLocalPipeData:(NSNotification*)notify {
    [self performSelectorOnMainThread:@selector(notifySendPipeResult:) withObject:notify waitUntilDone:NO];
}

- (void)onRecvPipeData:(NSNotification*)notify{
    [self performSelectorOnMainThread:@selector(RecvPipeData:) withObject:notify waitUntilDone:NO];
}
//接受回调
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
                    [_View_close setHidden:YES];
                    [_View_add setHidden:YES];
                    bool_power=YES;
                }
                else
                {
                    NSLog(@"关闭净化器");
                    [_Ima_pick setHidden:YES];
                    [_View_close setHidden:NO];
                    [_View_add setHidden:YES];
                    bool_power=NO;
                }
            }
            //童锁
            if ([output hasPrefix:@"2"]) {
                NSString *ss = [output substringWithRange:NSMakeRange(2, 1)];
                if ([ss isEqualToString:@"1"]) {
                    bool_lock=YES;
                    [_Ima_lock setImage:[UIImage imageNamed:@"s9_add_lockon.png"]];
                }
                else
                {
                    bool_lock=NO;
                    [_Ima_lock setImage:[UIImage imageNamed:@"s9_add_lockoff.png"]];
                }
            }
            
            if ([output hasPrefix:@"4"]) {
                NSString *hh = [output substringWithRange:NSMakeRange(2, 1)];
                NSString *ss = [output substringWithRange:NSMakeRange(4, 1)];
                //auto
                if ([hh intValue]==1 ) {
                    
                    [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun_auto1.png"]];
                    int_fun=1;
                    
                }else if ([hh intValue]==0){
                    switch ([ss intValue]) {
                        case 0:
                            [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun0.png"]];
                            int_fun=0;
                            break;
                        case 1:
                            [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun1.png"]];
                            int_fun=2;
                            break;
                        case 2:
                            [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun2.png"]];
                            int_fun=3;
                            break;
                        case 3:
                            [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun3.png"]];
                            int_fun=4;
                            break;
                        case 4:
                            [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun4.png"]];
                            int_fun=5;
                            break;
                        case 5:
                            [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun5.png"]];
                            int_fun=-1;
                            break;
                        default:
                            
                            break;
                    }
                }
                
            }
            
            //定时关机
            if ([output hasPrefix:@"8"]) {
                NSString *ss = [output substringWithRange:NSMakeRange(2, 1)];
                switch ([ss intValue]) {
                    case 0:
                        [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time.png"]];
                        int_time=1;
                        break;
                    case 1:
                        [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time1.png"]];
                        int_time=2;
                        break;
                    case 2:
                        [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time2.png"]];
                        int_time=3;
                        break;
                    case 3:
                        [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time4.png"]];
                        int_time=4;
                        break;
                    case 4:
                        [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time8.png"]];
                        int_time=0;
                        break;
                    default:
                        
                        break;
                }
            }
            
            //light
            if ([output hasPrefix:@"9"]) {
                NSString *ss = [output substringWithRange:NSMakeRange(2, 1)];
                if ([ss isEqualToString:@"0"])
                {
                    bool_light=NO;
                }
                else
                {
                    bool_light=YES;
                }
            }
            
            //查询返回
            if ([output hasPrefix:@"7"]) {
                
                NSArray *list=[output componentsSeparatedByString:@"|"];
                NSString *open = list[6];
                //open state
                if ([open isEqualToString:@"1"]) {
                    
                    [_View_close setHidden:YES];
                    bool_power=YES;
                    
                    NSString *pm = list[2];
                    NSString *mode =list[3];
                    NSString *level = list[4];
                    NSString *lock = list[5];
                    NSString *filter = list[8];
                    NSString *light = list[9];
                    NSString *time = list[10];
                    NSString *lightness = list[11];
                    //NSString *auto_color = list[12];
                    //NSString *color = list[13];
                    
                    //updata pm2.5
                    NSString *pm1=[pm substringWithRange:NSMakeRange(2,1)];
                    NSString *pm2=[pm substringWithRange:NSMakeRange(3,1)];
                    NSString *pm3=[pm substringWithRange:NSMakeRange(4,1)];
                    
                    switch ([pm1 intValue]) {
                        case 0:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p0.png"]];
                            break;
                        case 1:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p1.png"]];
                            break;
                        case 2:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p2.png"]];
                            
                            break;
                        case 3:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p3.png"]];
                            
                            break;
                        case 4:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p4.png"]];
                            
                            break;
                        case 5:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p5.png"]];
                            
                            break;
                        case 6:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p6.png"]];
                            
                            break;
                        case 7:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p7.png"]];
                            
                            break;
                        case 8:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p8.png"]];
                            
                            break;
                        case 9:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p9.png"]];
                            
                            break;
                        default:
                            [_Ima_num1 setImage:[UIImage imageNamed:@"s9_num_p0.png"]];
                            
                            break;
                    }
                    switch ([pm2 intValue]) {
                        case 0:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p0.png"]];
                            
                            break;
                        case 1:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p1.png"]];
                            
                            break;
                        case 2:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p2.png"]];
                            
                            break;
                        case 3:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p3.png"]];
                            
                            break;
                        case 4:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p4.png"]];
                            
                            break;
                        case 5:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p5.png"]];
                            
                            break;
                        case 6:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p6.png"]];
                            
                            break;
                        case 7:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p7.png"]];
                            
                            break;
                        case 8:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p8.png"]];
                            
                            break;
                        case 9:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p9.png"]];
                            
                            break;
                        default:
                            [_Ima_num2 setImage:[UIImage imageNamed:@"s9_num_p0.png"]];
                            
                            break;
                    }
                    switch ([pm3 intValue]) {
                        case 0:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p0.png"]];
                            
                            break;
                        case 1:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p1.png"]];
                            
                            break;
                        case 2:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p2.png"]];
                            
                            break;
                        case 3:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p3.png"]];
                            
                            break;
                        case 4:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p4.png"]];
                            
                            break;
                        case 5:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p5.png"]];
                            
                            break;
                        case 6:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p6.png"]];
                            
                            break;
                        case 7:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p7.png"]];
                            
                            break;
                        case 8:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p8.png"]];
                            
                            break;
                        case 9:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p9.png"]];
                            
                            break;
                        default:
                            [_Ima_num3 setImage:[UIImage imageNamed:@"s9_num_p0.png"]];
                            
                            break;
                    }
                    
                    //updata level
                    if ([mode intValue]==1 ) {
                        switch ([level intValue]) {
                            case 1:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun_auto1.png"]];
                                int_fun=1;
                                break;
                            case 2:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun_auto2.png"]];
                                int_fun=1;
                                break;
                            case 3:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun_auto3.png"]];
                                int_fun=1;
                                break;
                            case 4:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun_auto4.png"]];
                                int_fun=1;
                                break;
                            case 5:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun_auto5.png"]];
                                int_fun=1;
                                break;
                            default:
                                
                                break;
                        }
                    }else {
                        switch ([level intValue]) {
                            case 0:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun0.png"]];
                                int_fun=0;
                                break;
                            case 1:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun1.png"]];
                                int_fun=2;
                                break;
                            case 2:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun2.png"]];
                                int_fun=3;
                                break;
                            case 3:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun3.png"]];
                                int_fun=4;
                                break;
                            case 4:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun4.png"]];
                                int_fun=5;
                                break;
                            case 5:
                                [_Ima_fun setImage:[UIImage imageNamed:@"s9_fun5.png"]];
                                int_fun=-1;
                                break;
                            default:
                                
                                break;
                        }
                    }
                    
                    //lock
                    if ([lock isEqualToString:@"1"]) {
                        bool_lock=YES;
                        [_Ima_lock setImage:[UIImage imageNamed:@"s9_add_lockon.png"]];
                    }
                    else
                    {
                        bool_lock=NO;
                        [_Ima_lock setImage:[UIImage imageNamed:@"s9_add_lockoff.png"]];
                    }
                    
                    //filter
                    if ([filter isEqualToString:@"000"]) {
                        [_Lab_filter setHidden:YES];
                        [_Ima_filter_warn setHidden:NO];
                        
                    }
                    else
                    {
                        [_Lab_filter setHidden:NO];
                        [_Ima_filter_warn setHidden:YES];
                        
                        NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%ld%%",(long)[filter integerValue]]];
                        _Lab_filter.text=astring;
                    }
                    
                    //light
                    if ([light isEqualToString:@"0"])
                    {
                        bool_light=NO;
                    }
                    else
                    {
                        bool_light=YES;
                    }
                    
                    //time
                    switch ([time intValue]) {
                        case 0:
                            [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time.png"]];
                            int_time=1;
                            break;
                        case 1:
                            [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time1.png"]];
                            int_time=2;
                            break;
                        case 2:
                            [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time2.png"]];
                            int_time=3;
                            break;
                        case 3:
                            [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time4.png"]];
                            int_time=4;
                            break;
                        case 4:
                            [_Ima_time setImage:[UIImage imageNamed:@"s9_add_time8.png"]];
                            int_time=0;
                            break;
                        default:
                            
                            break;
                    }
                    
                    if (bool_updata) {
                        bool_updata=NO;
                        NSInteger n=[lightness integerValue];
                        _Sli_light.value=n;
                        NSString *str=[NSString stringWithFormat:@"%ld%%",(long)n];
                        _Lab_light.text=str;
                    }
                    
                }else{//close state
                    [_Ima_pick setHidden:YES];
                    [_View_close setHidden:NO];
                    [_View_add setHidden:YES];
                    bool_power=NO;
                }
            }
        }
    }
}

//设备状态改变回调
-(void)onDeviceStateChanged:(NSNotification*)notify {
    NSLog(@"设备状态改变。");
    DeviceEntity *device = [notify.object objectForKey:@"device"];
    if ([device.getMacAddressString isEqualToString:_device.getMacAddressString]) {
        _device=device;
        if (device.isConnected) {
            NSLog(@"设备[%@]在线",device.getMacAddressSimple);
            bool_on=YES;
            
        }else{
            NSLog(@"设备[%@]离线",device.getMacAddressSimple);
            bool_on=NO;
            
        }
    }
}

//内部方法
-(void)Return_list{
    if (isMatch) {
        NSLog(@"pushList");
        [self pushList];
    }else{
        NSLog(@"POP");
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)fuc_menu{
    [self presentViewController:menu_alert animated:YES completion:nil];
}

//内部按钮
-(void)fuc_lock{
    if (bool_lock) {
        [self sendData:UNLOCK];
    }else{
        [self sendData:LOCK];
    }
}

-(void)fuc_filter{
    [self presentViewController:filter_alert animated:YES completion:nil];
}

-(void)fuc_white{
    [self sendData:C1];
}

-(void)fuc_yellow{
    [self sendData:C2];
}

-(void)fuc_red{
    [self sendData:C3];
}

-(void)fuc_blue{
    [self sendData:C4];
}

-(void)fuc_pink{
    [self sendData:C5];
}

-(void)fuc_color{
    
    [_View_add setHidden:NO];
}

//handle main color
-(void)fuc_tap_main_color:(UITapGestureRecognizer *)sender{
    CGPoint point = [sender locationInView:_Ima_main_color];
    //NSLog(@"fuc_tap_main_color!pointx:%f,y:%f",point.x,point.y);
    
    //判断是否在圆内
    float n4=_Ima_main_color.frame.size.width/2;
    float n1=point.x-n4;
    float n2=point.y-n4;
    float n3=n1*n1+n2*n2;
    float n5=n4*n4;
    
    if (n3<=n5) {
        [self getPixelColorAtLocation:point];
        [_Ima_pick setHidden:NO];
        //考虑到参考系为父View
        point.x=point.x+_Ima_main_color.frame.origin.x;
        point.y=point.y+_Ima_main_color.frame.origin.y;
        _Ima_pick.center=point;
    }
    
}

-(void)fuc_pan_main_color:(UIPanGestureRecognizer *)sender{
    
    CGPoint point = [sender locationInView:_Ima_main_color];
    NSLog(@"fuc_pan_main_color!pointx:%f,y:%f",point.x,point.y);
    
    //判断是否在圆内
    float n4=_Ima_main_color.frame.size.width/2-2;
    float n1=point.x-n4;
    float n2=point.y-n4;
    float n3=n1*n1+n2*n2;
    float n5=n4*n4;
    
    if (n3>n5) {
        
        point.x=point.x-n4;
        point.y=point.y-n4;
     
        if (point.x==0) {
            if (point.y>0) {
                point.y=n4;
            }else if(point.y<0){
                point.y=-n4;
            }
        }else if(point.x>0){
            float f1=point.y/point.x;
            float f2=f1*f1;
            float f3=sqrtf(1+f2);
            float f4=n4/f3;
            float f5=sqrtf(n4*n4-f4*f4);
            
            if (point.y<0) {
                f5=-f5;
            }
            
            point.x=f4;
            point.y=f5;
        }else {
            float f1=point.y/point.x;
            float f2=f1*f1;
            float f3=sqrtf(1+f2);
            float f4=-n4/f3;
            float f5=sqrtf(n4*n4-f4*f4);
            
            if (point.y<0) {
                f5=-f5;
            }
            
            point.x=f4;
            point.y=f5;
        }
        
        point.x=point.x+n4;
        point.y=point.y+n4;
        
    }
    
    if (sender.state==UIGestureRecognizerStateEnded) {
        NSLog(@"手指抬起");
        [self getPixelColorAtLocation:point];
    }else{
        point.x=point.x+_Ima_main_color.frame.origin.x;
        point.y=point.y+_Ima_main_color.frame.origin.y;
        [_Ima_pick setHidden:NO];
        _Ima_pick.center=point;
        
    }
    
}



//图片缩放
- (UIImage *)scaleToSize:(UIImage *)image :(CGSize)newsize {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(newsize);
    
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, newsize.width, newsize.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
    UIColor* color = nil;
    
    UIImage *img=[self scaleToSize:[UIImage imageNamed:@"s9_main_color.png"] :_Ima_main_color.frame.size];
    //NSLog(@"img %f %f main %f %F",img.size.height,img.size.width,_Ima_main_color.frame.size.height,_Ima_main_color.frame.size.width);
    
    CGImageRef inImage = img.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil;  }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        @try {
            int offset = 4*((w*round(point.y))+round(point.x));
            NSLog(@"offset: %d", offset);
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
            color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
            
            if (alpha!=0) {
                
                
                
                NSString *hexString1=nil;
                if (red>15) {
                    hexString1 =[NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",red]];
                }else{
                    hexString1 =[NSString stringWithFormat:@"0%@",[[NSString alloc] initWithFormat:@"%1x",red]];
                }
                
                NSString *hexString2=nil;
                if (green>15) {
                    hexString2 =[NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",green]];
                }else{
                    hexString2 =[NSString stringWithFormat:@"0%@",[[NSString alloc] initWithFormat:@"%1x",green]];
                }
                
                NSString *hexString3=nil;
                if (blue>15) {
                    hexString3 =[NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",blue]];
                }else{
                    hexString3 =[NSString stringWithFormat:@"0%@",[[NSString alloc] initWithFormat:@"%1x",blue]];
                }
                
                if (hexString1 && hexString2 && hexString3) {
                    NSString *str=[NSString stringWithFormat:@"&B2|0%@%@%@",hexString1,hexString2,hexString3];
                    str=[self reform:str];
                    NSLog(@"all=%@",str);
                    [self sendData:str];
                }
                
            }
            
            
        }
        @catch (NSException * e) {
            NSLog(@"%@",[e reason]);
        }
        @finally {
        }
        
    }
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}

-(NSString *)reform:(NSString *) str{
    
    NSString *ch=@"";
    for (int i=0; i<str.length; i++) {
        NSString *tem=[NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",[str characterAtIndex:i]]];
        ch=[NSString stringWithFormat:@"%@%@",ch,tem];
    }
    return ch;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color spacen");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

//add_view
-(void)fuc_add_return{
    [_View_add setHidden:YES];
}

-(void)fuc_add_c1{
    [self sendData:ADD_C1];
}

-(void)fuc_add_c2{
    [self sendData:ADD_C2];
}

-(void)fuc_add_c3{
    [self sendData:ADD_C3];
}

-(void)fuc_add_c4{
    [self sendData:ADD_C4];
}

-(void)fuc_add_c5{
    [self sendData:ADD_C5];
}

-(void)fuc_add_c6{
    [self sendData:ADD_C6];
}

-(void)fuc_add_c7{
    [self sendData:ADD_C7];
}

-(void)fuc_add_c8{
    [self sendData:ADD_C8];
}

-(void)fuc_add_c9{
    [self sendData:ADD_C9];
}

-(void)fuc_add_c10{
    [self sendData:ADD_C10];
}

-(void)fuc_add_c11{
    [self sendData:ADD_C11];
}

-(void)fuc_add_c12{
    [self sendData:ADD_C12];
}

- (IBAction)BA_open:(id)sender {
    [self sendData:OPEN];
}

- (IBAction)BA_close:(id)sender {
    [self sendData:CLOSE];
}

- (IBAction)BA_fun:(id)sender {
    switch (int_fun) {
        case -1:
            [self sendData:CLOSE_FUN];
            break;
        case 0:
            [self sendData:SMART];
            break;
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
        case 5:
            [self sendData:STRONG];
            break;
        default:
            break;
    }
}

- (IBAction)BA_time:(id)sender {
    switch (int_time) {
        case 0:
            [self sendData:TIME0];
            break;
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
        default:
            break;
    }
}

- (IBAction)BA_light:(id)sender {
    if (bool_light) {
        [self sendData:LIGHT0];
    }else{
        [self sendData:LIGHT1];
    }
}
@end

