//
//  ScanDeviceViewController.m
//  xlinkDemo
//
//  Created by xtmac on 6/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "ScanDeviceViewController.h"
#import "AppDelegate.h"
#import "XLinkExportObject.h"
#import "DeviceEntity.h"

#import "ViewController.h"
#import "MatchViewController.h"
#import "HexInputViewController.h"
#import "Put_data.h"
#import "B8_controller.h"
#import "C7_controller.h"
#import "S9_controller.h"

@interface ScanDeviceViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@end

@implementation ScanDeviceViewController{
    IBOutlet UITableView    *_tableView;
    NSMutableArray          *_devices;
    NSMutableArray          *_scanList;
    DeviceEntity            *_device;
    NSString                *_pwd;
    IBOutlet UIActivityIndicatorView *_activityView;
    NSTimer *timer1,*timer2,*timer3;
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
    showview.frame = CGRectMake((width - LabelSize.width - 20)/2, height - 100, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:1.5 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}

-(void)initData{
    _scanList = [[NSMutableArray alloc] init];
    if (!_devices) {
        _devices = [[NSMutableArray alloc] init];
    }
    _pwd = [[NSString alloc] init];
}

-(void)Dell_controller{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self Dell_controller];
    self.automaticallyAdjustsScrollViewInsets=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGotDeviceByScan:) name:kOnGotDeviceByScan object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectDeviceNotify:) name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSetLocalDeviceAuthorizeCode:) name:kOnSetLocalDeviceAuthorizeCode object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSetDeviceAccessKey:) name:kOnSetDeviceAccessKey object:nil];
    self.navigationController.navigationBarHidden = NO;
    
    UIBarButtonItem *nullItem = [[UIBarButtonItem alloc] initWithTitle:@"返回添加" style:UIBarButtonItemStylePlain target:self action:@selector(Return)];
    self.navigationItem.leftBarButtonItem = nullItem;
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [self Scan_device];
    timer1= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Scan_device) userInfo:nil repeats:YES];
    //timer2= [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(Scan_device) userInfo:nil repeats:NO];
    timer3= [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(Over_timer) userInfo:nil repeats:NO];
}

-(void)Over_timer{
    [timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
    [self.View_wait setHidden:YES];
    [self showWarningAlert:NSLocalizedString(@"扫描不到设备，请手动扫描。",comment: "")];
}
-(void)Return
{
    [self.navigationController popViewControllerAnimated:YES];
}
//扫描设备
-(void)Scan_device{
    int ret = [[XLinkExportObject sharedObject] scanByDeviceProductID:PRODUCT_ID];
    if( ret == CODE_STATE_NO_WIFI ) {
        [self showWarningAlert:NSLocalizedString(@"请开启WIFI环境",comment: "")];
        [timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
        //[timer2 setFireDate:[NSDate distantFuture]];//关闭定时器
        [timer3 setFireDate:[NSDate distantFuture]];//关闭定时器
        [self.View_wait setHidden:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated{
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
    //[timer2 setFireDate:[NSDate distantFuture]];//关闭定时器
    [timer3 setFireDate:[NSDate distantFuture]];//关闭定时器
  
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
}

//点击扫描设备按钮
- (IBAction)scanBtnAction {
    int ret = [[XLinkExportObject sharedObject] scanByDeviceProductID:PRODUCT_ID];
    if( ret == CODE_STATE_NO_WIFI ) {
        [self showWarningAlert:NSLocalizedString(@"请开启WIFI环境",comment: "")];
        //[self showMessage:@"请开启WIFI"];
    }
}

//推出登陆界面
-(void)pushViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *View = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:View animated:YES];
}
//推出匹配界面
-(void)pushMatchViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MatchViewController *View = [storyBoard instantiateViewControllerWithIdentifier:@"MatchViewController"];
    [self.navigationController pushViewController:View animated:YES];
}
//推出操作界面
-(void)pushHexInputViewController:(DeviceEntity*)device{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HexInputViewController *view = [storyBoard instantiateViewControllerWithIdentifier:@"HexInputViewController"];
    [view setDevice:device];
    [view setMatch:true];
    [self.navigationController pushViewController:view animated:YES];
}
//推出P8操作界面
-(void)pushB8Controller:(DeviceEntity*)device{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    B8_controller *view = [storyBoard instantiateViewControllerWithIdentifier:@"B8_controller"];
    [view setDevice:device];
    [view setMatch:true];
    [self.navigationController pushViewController:view animated:YES];
}
-(void)pushC7Controller:(DeviceEntity*)device{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    C7_controller *view = [storyBoard instantiateViewControllerWithIdentifier:@"C7_controller"];
    [view setDevice:device];
    [view setMatch:true];
    [self.navigationController pushViewController:view animated:YES];
}
-(void)pushS9Controller:(DeviceEntity*)device{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    S9_controller *view = [storyBoard instantiateViewControllerWithIdentifier:@"S9_controller"];
    [view setDevice:device];
    [view setMatch:true];
    [self.navigationController pushViewController:view animated:YES];
}
//显示消息框
-(void)showWarningAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

#pragma mark UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _devices.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"生成单元行。");
    DeviceEntity *device = _devices[indexPath.row];
    NSString *d_name=device.deviceName;
    UITableViewCell *cell;
    if ([d_name isEqualToString:DEVICE_O2]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"o2"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        nameLabel.text = @"AIR VALLEY O2";
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
        
    }
    else if ([d_name isEqualToString:DEVICE_PRO]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"pro"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        nameLabel.text = @"AIR VALLEY PRO";
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
    }
    else if ([d_name isEqualToString:DEVICE_C7]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"c7"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        nameLabel.text = @"AIR VALLEY 婴儿方";
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
    }
    else if ([d_name isEqualToString:DEVICE_P6]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"p6"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        nameLabel.text = @"Air Light Pendant";
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
    }
    else if ([d_name isEqualToString:DEVICE_S9]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"s9"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        nameLabel.text = @"AIR VALLEY WINE";
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
    }
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectDevice:(int)indexPath.row];
}

-(void)selectDevice:(int)deviceIndex{

    @try {
        [self.View_wait setHidden:NO];
        DeviceEntity *device = _devices[deviceIndex];
        if (device.accessKey>0) {
            [[XLinkExportObject sharedObject] connectDevice:device andAuthKey:@(8888)];
        }
        else{
            device.accessKey=@(8888);
            [[XLinkExportObject sharedObject] setAccessKey:@(8888) withDevice:device];
        }
    } @catch (NSException *exception) {
        [self showMessage:NSLocalizedString(@"程序出错，请重新操作。",comment: "")];
    }

}

#pragma mark
#pragma mark XlinkExportObject Delegate
-(void)onSetDeviceAccessKey:(NSNotification *)noti{
    DeviceEntity *device = [noti.object objectForKey:@"device"];
    NSNumber *ack = device.accessKey;
    [[XLinkExportObject sharedObject] connectDevice:device andAuthKey:ack];
}
-(void)onSetLocalDeviceAuthorizeCode:(NSNotification *)noti{
    DeviceEntity *device=[noti.object objectForKey:@"device"];
    [[XLinkExportObject sharedObject] connectDevice:device andAuthKey:@(8888)];
    //UInt8 result = [[noti.object objectForKey:@"result"] unsignedCharValue];
}
//扫描设备回调
-(void)onGotDeviceByScan:(NSNotification *)noti{
    DeviceEntity *device = noti.object;
    NSString *two=device.getMacAddressString;
    NSString *one=[[NSUserDefaults standardUserDefaults] objectForKey:@"ONE"];
    
    two=[two stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSLog(@"one=%@,two=%@",one,two);
    if ([one caseInsensitiveCompare:two] == NSOrderedSame) {
        [self addScanList:device];
        [self addDevice:device];
        [self addDeviceCache:device];
        NSLog(@"找到设备：%@",one);
        [timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
        //[timer2 setFireDate:[NSDate distantFuture]];//关闭定时器
        [timer3 setFireDate:[NSDate distantFuture]];//关闭定时器
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.View_wait setHidden:YES];
        });
       
    }
}

//在扫描列表上添加device
-(void)addScanList:(DeviceEntity *)device{
    DeviceEntity *d = device;
    for (DeviceEntity *t in _scanList) {
        if ([device.macAddress isEqualToData:t.macAddress]) {
            d = t;
            device.fromIP = t.fromIP;
            device.devicePort = t.devicePort;
            [_devices removeObject:t];
            break;
        }
    }
    [_scanList addObject:d];
}

//在TableView上添加device
-(void)addDevice:(DeviceEntity *)device{
    DeviceEntity *d = device;
    for (DeviceEntity * t in _devices) {
        if ([device.macAddress isEqualToData:t.macAddress]) {
            [_devices removeObject:t];
            [self addDeviceCache:device];
            break;
        }
    }
    [_devices addObject:d];
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

//把device记录保存在本地
-(void)addDeviceCache:(DeviceEntity *)device{
    
    NSMutableDictionary *deviceDic = [[NSMutableDictionary alloc] initWithDictionary:[device getDictionaryFormat]];
    
    NSMutableArray *deviceArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"devices"]];
    for (NSDictionary *dic in deviceArr) {
        if ([[deviceDic objectForKey:@"macAddress"] isEqualToString:[dic objectForKey:@"macAddress"]]) {
            [deviceArr removeObject:dic];
            break;
        }
    }
    [deviceArr addObject:deviceDic];
    [[NSUserDefaults standardUserDefaults] setObject:deviceArr forKey:@"devices"];
}

- (void)onConnectDevice:(NSNotification *)notify {
    NSLog(@"[连接设备结果回调]");
    
    [self.View_wait setHidden:YES];
    NSInteger result = [[notify.object objectForKey:@"result"] integerValue];
    DeviceEntity *device = [notify.object objectForKey:@"device"];
    NSString *d_name=device.deviceName;
    NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",[device getMacAddressString],@"d_name"]];
    [[NSUserDefaults standardUserDefaults] setObject:d_name forKey:astring];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"%@ || d_name=%@",astring,d_name);
    //[self addDevice:device];
    if (result == 0 ){
        [self addDeviceCache:device];
        if ([d_name isEqualToString:DEVICE_O2]) {
            [self pushHexInputViewController:device];
        }
        else if ([d_name isEqualToString:DEVICE_PRO]) {
            [self pushB8Controller:device];
        }
        else if ([d_name isEqualToString:DEVICE_C7]) {
            [self pushC7Controller:device];
        }
        else if ([d_name isEqualToString:DEVICE_S9]) {
            [self pushS9Controller:device];
        }
        else if ([d_name isEqualToString:DEVICE_P6]) {
            
        }
    } else {
        [self showMessage:NSLocalizedString(@"连接设备失败",comment: "")];
        if( result == CODE_DEVICE_OFFLINE || result == CODE_DEVICE_CLOUD_OFFLINE ) {
            //[self showMessage:@"设备离线，不能连接该设备"];
        } else if( result == CODE_TIMEOUT ) {
            //[self showMessage:@"连接该设备超时"];
        } else if( result == CODE_DEVICE_UNINIT) {
            //[self showMessage:@"设备未设置授权码"];
        } else if( result == CODE_FUNC_NETWOR_ERROR ) {
            //[self showMessage:@"网络异常，不能连接该设备"];
        } else {
            //未知错误
        }
    }
    
}

- (void)onConnectDeviceNotify:(NSNotification*)notify{
    [self performSelectorOnMainThread:@selector(onConnectDevice:) withObject:notify waitUntilDone:NO];
}

@end
