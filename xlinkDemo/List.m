//
//  ScanDeviceViewController.m
//  xlinkDemo
//
//  Created by xtmac on 6/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "List.h"
#import "AppDelegate.h"
#import "XLinkExportObject.h"
#import "DeviceEntity.h"

#import "ViewController.h"
#import "MatchViewController.h"
#import "HexInputViewController.h"
#import "Put_data.h"
#import "B8_controller.h"
#import "C7_controller.h"
#import "HttpRequest_V2.h"
#import "S9_controller.h"

@interface List ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@end

@implementation List{
    
    NSMutableArray          *_List_devices;
    DeviceEntity            *_device;
    
    BOOL                    ischeck,isHex;
    int                     a,b,c;
    NSTimer                 *re_send;
    
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

-(void)isHex:(BOOL)is{
    isHex=is;
}

-(void)initData{
    
    if (!_List_devices) {
        _List_devices = [[NSMutableArray alloc] init];
        NSArray *deviceArr = [[NSUserDefaults standardUserDefaults] arrayForKey:@"devices"];
        for (NSDictionary *deviceDic in deviceArr) {
            DeviceEntity *device = [[DeviceEntity alloc] initWithDictionary:deviceDic];
            [self addDevice:device];
            [[XLinkExportObject sharedObject] initDevice:device];
            NSLog(@"初始化设备【%@】",device.macAddress);
        }
    }

}

-(void)Check_status{
    
    if (_List_devices) {
        NSArray * array = [NSArray arrayWithArray: _List_devices];
        for (DeviceEntity * t in array) {
            if (t!=nil) {
                @try {
                    [[XLinkExportObject sharedObject] connectDevice:t andAuthKey:@(8888)];
                }
                @catch (NSException *exception) {
                    NSLog(@"发起连接设备[%@]出错",t.getMacAddressString);
                }
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogin:) name:kOnLogin object:nil];
    [self.Con_view setHidden:YES];
    
    self.navigationController.navigationBarHidden = NO;
    UIBarButtonItem *nullItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"删除设备",comment: "") style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    self.navigationItem.leftBarButtonItem = nullItem;
    
    
    UIBarButtonItem *cleanItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"添加设备",comment: "") style:UIBarButtonItemStylePlain target:self action:@selector(pushMatchViewController)];
    self.navigationItem.rightBarButtonItem = cleanItem;
    
    self.navigationItem.title=NSLocalizedString(@"设备列表",comment: "");
    //[self Adapter];
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    re_send= [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(Re_send) userInfo:nil repeats:YES];
    
    self.table_view.delegate=self;
    self.table_view.dataSource=self;
    ischeck=true;
    
}

-(void)Re_send{
    if (_List_devices) {
        NSArray * array = [NSArray arrayWithArray: _List_devices];
        for (DeviceEntity * t in array) {
            if (t!=nil) {
                NSData * data1 = [self hexToData:KA];
                int sendResult = -1;
                sendResult = [[XLinkExportObject sharedObject] sendLocalPipeData:t andPayload:data1];
                if (sendResult<0) {
                    sendResult = [[XLinkExportObject sharedObject] sendPipeData:t andPayload:data1];
                }
                if (sendResult<0) {
                    NSLog(@"开始重连[%@]",t.getMacAddressString);
                    [[XLinkExportObject sharedObject] connectDevice:t andAuthKey:@(8888)];
                }
            }
        }
    }
}
- (NSData*)hexToData:(NSString *)hexString {
    
    int len = (int)[hexString length] / 2;
    char * bytes = (char *)malloc(len);
    ListhexToBytes(bytes, [hexString UTF8String], (int)[hexString length]);
    
    NSData * data = [[NSData alloc] initWithBytes:bytes length:len];
    
    free(bytes);
    return data;
}
void ListhexToBytes(char * bytes, const char * hexString, int hexLength)
{
    char * pos = (char *)hexString;
    int count = 0;
    for(count = 0; count < hexLength / 2; count++) {
        sscanf(pos, "%2hhx", &bytes[count]);
        pos += 2 * sizeof(char);
    }
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
        //self.table_view.frame=CGRectMake(0,0,320,460);
    }
    //iphone 5
    if (width==320 && height==568) {
        //self.table_view.frame=CGRectMake(0,0,320,504);
    }
    //iphone 6
    if (width==375 && height==667) {
        
    }
    //iphone 6+
    if (width==414 && height==736) {
        
    }
}

-(void)Return
{
    [[XLinkExportObject sharedObject] stop];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectDeviceNotify:) name:kOnConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceStateChanged:) name:kOnDeviceStateChanged object:nil];
    
    if (isHex) {
        [self Check_status];
    }else{
        [self.table_view reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//用户登陆成功回调
-(void)onLogin:(NSNotification*)noti{
    int result = [[noti.object objectForKey:@"result"] intValue];
    if (result == 0) {
        NSLog(@"【APP登陆成功】");
        [self Check_status];
    }else{
        NSLog(@"【APP登陆失败】");
    }
    
}
-(void)onDeviceStateChanged:(NSNotification*)notify {
    NSLog(@"设备状态改变。");
    DeviceEntity *device = [notify.object objectForKey:@"device"];
    //NSLog(@"device=%@",[device getDictionaryFormat]);
    if (device.isConnected) {
        NSLog(@"设备[%@]在线",device.getMacAddressSimple);
    }else{
        NSLog(@"设备[%@]离线",device.getMacAddressSimple);
    }
    
    [self UpdataDeviceList:device];
    [self.table_view performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

-(void)pushViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *View = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:View animated:YES];
}

-(void)pushMatchViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MatchViewController *View = [storyBoard instantiateViewControllerWithIdentifier:@"MatchViewController"];
    [View isADD];
    [self.navigationController pushViewController:View animated:YES];
}


//Push ParametersToReadViewController.h
-(void)pushHexInputViewController:(DeviceEntity*)device{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HexInputViewController *view = [storyBoard instantiateViewControllerWithIdentifier:@"HexInputViewController"];
    [view setDevice:device];
    [view setMatch:false];
    [self.navigationController pushViewController:view animated:YES];
}
-(void)pushB8Controller:(DeviceEntity*)device{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    B8_controller *view = [storyBoard instantiateViewControllerWithIdentifier:@"B8_controller"];
    [view setDevice:device];
    [view setMatch:false];
    [self.navigationController pushViewController:view animated:YES];
}
-(void)pushC7Controller:(DeviceEntity*)device{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    C7_controller *view = [storyBoard instantiateViewControllerWithIdentifier:@"C7_controller"];
    [view setDevice:device];
    [view setMatch:false];
    [self.navigationController pushViewController:view animated:YES];
}
-(void)pushS9Controller:(DeviceEntity*)device{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    S9_controller *view = [storyBoard instantiateViewControllerWithIdentifier:@"S9_controller"];
    [view setDevice:device];
    [view setMatch:false];
    [self.navigationController pushViewController:view animated:YES];
}
//显示消息框
-(void)showWarningAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

#pragma mark UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _List_devices.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"生成单元行。%lu",(unsigned long)_List_devices.count);
    
    DeviceEntity *device = _List_devices[indexPath.row];
    
    
    NSString *d_name=device.deviceName;
    NSLog(@"deviceList=%@ || d_name=%@",_List_devices,d_name);
    if (!d_name) {
        NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",[device getMacAddressString],@"d_name"]];
        
        d_name=[[NSUserDefaults standardUserDefaults] objectForKey:astring];
    }
    NSLog(@"deviceList=%@ || d_name=%@",_List_devices,d_name);
    //SLog(@"device=%@",[device getDictionaryFormat]);
    
    UITableViewCell *cell;
    NSString *d_Name = [[NSUserDefaults standardUserDefaults] objectForKey:[device getMacAddressString]];
   
    if ([d_name isEqualToString:DEVICE_O2]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"o2"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        
        if (d_Name) {
            nameLabel.text=d_Name;
        }
        else{
            nameLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"AIR VALLEY O2 (%ld)",(long)indexPath.row+1]];
        }
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        UIImageView *status=(UIImageView *)[cell viewWithTag:3];
        if (device.isConnected) {
            status.image=[UIImage imageNamed:@"list_status_on.png"];
        }else{
            status.image=[UIImage imageNamed:@"list_status_off.png"];
        }
        
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
        
    }
    else if ([d_name isEqualToString:DEVICE_PRO]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"pro"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        
        if (d_Name) {
            nameLabel.text=d_Name;
        }
        else{
            nameLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"AIR VALLEY PRO (%ld)",(long)indexPath.row+1]];
        }
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        UIImageView *status=(UIImageView *)[cell viewWithTag:3];
        if (device.isConnected) {
            status.image=[UIImage imageNamed:@"list_status_on.png"];
        }else{
            status.image=[UIImage imageNamed:@"list_status_off.png"];
        }
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
    }
    else if ([d_name isEqualToString:DEVICE_C7]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"c7"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        
        if (d_Name) {
            nameLabel.text=d_Name;
        }
        else{
            nameLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"AIR VALLEY 婴儿方 (%ld)",(long)indexPath.row+1]];
        }
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        UIImageView *status=(UIImageView *)[cell viewWithTag:3];
        if (device.isConnected) {
            status.image=[UIImage imageNamed:@"list_status_on.png"];
        }else{
            status.image=[UIImage imageNamed:@"list_status_off.png"];
        }
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
    }
    else if ([d_name isEqualToString:DEVICE_P6]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"p6"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        
        if (d_Name) {
            nameLabel.text=d_Name;
        }
        else{
            nameLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"AIR LIGHT PENDANT (%ld)",(long)indexPath.row+1]];
        }
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        UIImageView *status=(UIImageView *)[cell viewWithTag:3];
        if (device.isConnected) {
            status.image=[UIImage imageNamed:@"list_status_on.png"];
        }else{
            status.image=[UIImage imageNamed:@"list_status_off.png"];
        }
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
    }
    else if ([d_name isEqualToString:DEVICE_S9]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"s9"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        
        if (d_Name) {
            nameLabel.text=d_Name;
        }
        else{
            nameLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"AIR VALLEY WINE (%ld)",(long)indexPath.row+1]];
        }
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        UIImageView *status=(UIImageView *)[cell viewWithTag:3];
        if (device.isConnected) {
            status.image=[UIImage imageNamed:@"list_status_on.png"];
        }else{
            status.image=[UIImage imageNamed:@"list_status_off.png"];
        }
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
    }
    
    if (!cell) {
        NSLog(@"设备数据结构错误!使用默认O2");
        cell = [tableView dequeueReusableCellWithIdentifier:@"o2"];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        
        if (d_Name) {
            nameLabel.text=d_Name;
        }
        else{
            nameLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"AIR VALLEY O2 (%ld)",(long)indexPath.row+1]];
        }
        UILabel *macLabel = (UILabel *)[cell viewWithTag:2];
        UIImageView *status=(UIImageView *)[cell viewWithTag:3];
        if (device.isConnected) {
            status.image=[UIImage imageNamed:@"list_status_on.png"];
        }else{
            status.image=[UIImage imageNamed:@"list_status_off.png"];
        }
        
        macLabel.text = device.getMacAddressString;
        [macLabel setTextColor:[UIColor grayColor]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectDevice:(int)indexPath.row];
}

-(void)selectDevice:(int)deviceIndex{
    DeviceEntity *device = _List_devices[deviceIndex];
    NSLog(@"设备局域网在线%d -- 设备外网在线%d",device.isLANOnline,device.isWANOnline);
    int status = [device getInitStatus];
    if (status) {
        if (device.isConnected) {
            NSString *d_name=device.deviceName;
            if (!d_name) {
                NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@",[device getMacAddressString],@"d_name"]];
                
                d_name=[[NSUserDefaults standardUserDefaults] objectForKey:astring];
            }
            NSLog(@"d_name=%@",d_name);
            if ([d_name isEqualToString:DEVICE_O2]) {
                [self pushHexInputViewController:device];
            }
            else if ([d_name isEqualToString:DEVICE_PRO]) {
                [self pushB8Controller:device];
            }
            else if ([d_name isEqualToString:DEVICE_C7]) {
                [self pushC7Controller:device];
            }
            else if ([d_name isEqualToString:DEVICE_P6]) {
                
            }
            else if ([d_name isEqualToString:DEVICE_S9]) {
                [self pushS9Controller:device];
            }else{
                [self pushHexInputViewController:device];
            }
        }else{
            [self showWarningAlert:NSLocalizedString(@"设备不在线",comment: "")];
        }
    }
}

#pragma mark 删除
-(void)remove{
    //直接通过下面的方法设置编辑状态没有动画
    //_tableView.editing=!_tableView.isEditing;
    
    [self.table_view setEditing:!self.table_view.isEditing animated:true];
}
#pragma mark 删除操作
//实现了此方法向左滑动就会显示删除按钮
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [self CleanNetDevice:_List_devices[indexPath.row]];
        [self CleanDeviceCache:_List_devices[indexPath.row]];
        [_List_devices removeObject:_List_devices[indexPath.row]];
        //使用下面的方法既可以局部刷新又有动画效果
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}
#pragma mark
#pragma mark XlinkExportObject Delegate
//把device订阅在网络端删除
-(void)CleanNetDevice:(DeviceEntity *)device{
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
    NSNumber *userID= [NSNumber numberWithInt:[[userData objectForKey:@"user_id"] intValue]];
    NSNumber *deviceID=[NSNumber numberWithInt:device.getDeviceID];
    [HttpRequest_V2 unsubscribeDeviceWithUserID:userID withAccessToken:[userData objectForKey:@"access_token"] withDeviceID:deviceID didLoadData:^(id result, NSError *err) {
        if (err) {
            NSLog(@"[设备%d删除订阅失败]ERR=%@",device.getDeviceID,err);
        }else{
            NSLog(@"[设备%d删除订阅成功]",device.getDeviceID);
        }
    }];
}
//把device记录在本地删除
-(void)CleanDeviceCache:(DeviceEntity *)device{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:device.getMacAddressString];
    
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

//在TableView上添加device
-(void)addDevice:(DeviceEntity *)device{
    DeviceEntity *d = device;
    for (DeviceEntity * t in _List_devices) {
        if ([device.macAddress isEqualToData:t.macAddress]) {
            [_List_devices removeObject:t];
            break;
        }
    }
    [_List_devices addObject:d];
    [self.table_view performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)UpdataDeviceList:(DeviceEntity *)device{
    for (int i=0 ; i<_List_devices.count ;i++) {
        DeviceEntity *device1 = _List_devices[i];
        if ([device1.macAddress isEqualToData:device.macAddress]) {
            //NSLog(@"device.name=%@",device1.deviceName);
            //device.deviceName=device1.deviceName;
            [_List_devices replaceObjectAtIndex:i withObject:device];
            break;
        }
    }
}
//把device记录保存在本地
-(void)addDeviceCache:(DeviceEntity *)device{
    NSMutableDictionary *deviceDic = [[NSMutableDictionary alloc] initWithDictionary:[device getDictionaryFormat]];
    NSMutableArray *deviceArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"devices"]];
    int n=-1;
    for (NSDictionary *dic in deviceArr) {
        n=n+1;
        if ([[deviceDic objectForKey:@"macAddress"] isEqualToString:[dic objectForKey:@"macAddress"]]) {
            [deviceArr removeObject:dic];
            break;
        }
    }
    [deviceArr addObject:deviceDic];
    [[NSUserDefaults standardUserDefaults] setObject:deviceArr forKey:@"devices"];
}

- (void)onConnectDevice:(NSNotification *)notify {
    int result = [[notify.object objectForKey:@"result"] intValue];
    DeviceEntity *device = [notify.object objectForKey:@"device"];
    //NSLog(@"con_device=%@",[device getDictionaryFormat]);
    if (result == 0 ){
        NSLog(@"设备MAC[%@]连接成功，内网在线%d,外网在线%d",device.getMacAddressString,device.isLANOnline,device.isWANOnline);
        }
    else
        {
        if( result == CODE_DEVICE_OFFLINE || result == CODE_DEVICE_CLOUD_OFFLINE ) {
            NSLog(@"设备MAC[%@]连接失败[原因：设备离线]",device.getMacAddressString);
        } else if( result == CODE_TIMEOUT ) {
            NSLog(@"设备MAC[%@]连接失败[原因：连接超时]",device.getMacAddressString);
        } else if( result == CODE_DEVICE_UNINIT) {
            NSLog(@"设备MAC[%@]连接失败[原因：未设密码]",device.getMacAddressString);
        } else if( result == CODE_FUNC_NETWOR_ERROR ) {
            NSLog(@"设备MAC[%@]连接失败[原因：网络异常]",device.getMacAddressString);
        } else {
            NSLog(@"设备MAC[%@]连接失败[原因：连接失败]",device.getMacAddressString);
        }
        
    }
    
}

- (void)onConnectDeviceNotify:(NSNotification*)notify{
    [self performSelectorOnMainThread:@selector(onConnectDevice:) withObject:notify waitUntilDone:NO];
}
@end
