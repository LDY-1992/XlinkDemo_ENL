//
//  HexInputViewController.m
//  xlinkDemo
//
//  Created by Leon on 15/6/10.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "HexInputViewController.h"
#import "DeviceEntity.h"
#import "XLinkExportObject.h"
#import "AppDelegate.h"
#import "ScanDeviceViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ViewController.h"
#import "Reachability.h"
#import "MatchViewController.h"
#import "sys/utsname.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "List.h"
@interface HexInputViewController ()<UIActionSheetDelegate, UIAlertViewDelegate,UIScrollViewDelegate,CLLocationManagerDelegate,NSXMLParserDelegate>

{
    BOOL         isMatch;
    DeviceEntity *_device;
    BOOL         isON;
    
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
    int recon;
    int shajun_flag;
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation HexInputViewController

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


-(void)checkNetworkChange
{
    NSLog(@"开始检测网络");
    //监测网络状态变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //添加监控
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    //网络是否链接,包括蜂窝网络和WIFI
    [hostReach startNotifier];
    
    wifiReach = [Reachability reachabilityForLocalWiFi] ;
    [wifiReach startNotifier];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    
    if (status == NotReachable) {
        [self.Wifi setImage:[UIImage imageNamed:@"close_wifi.png"]];
        NSLog(@"没有网络连接kkkkk");
    }
    else{
        [self.Wifi setImage:[UIImage imageNamed:@"open_wifi.png"]];
        NSLog(@"网络连接正常kkkkk");
    }
}


//定位程序

//定位开始
-(void) Location_city
{
    @try {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 1609;
        [self.locationManager startUpdatingLocation];
        NSLog(@"【B8开始定位】");
    }
    @catch (NSException *exception) {
        NSLog(@"【B8开始定位失败】");
    }
    
    
}
// 错误信息
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"【B8定位失败！】");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    @try {
        //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
        
        CLLocation *currentLocation = [locations lastObject];
        
        CLLocation *newLocation = locations[0];
        CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
        NSLog(@"旧的经度：%f,旧的纬度：%f",oldCoordinate.longitude,oldCoordinate.latitude);
        // 获取当前所在的城市名
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        //根据经纬度反向地理编译出地址信息
        
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
         
         {
             
             if (array.count > 0)
                 
             {
                 
                 CLPlacemark *placemark = [array objectAtIndex:0];
                 
                 //将获得的所有信息显示到label上
                 
                 NSLog(@"%@",placemark.name);
                 
                 //获取城市
                 
                 NSString *city = placemark.locality;
                 
                 if (!city) {
                     
                     //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                     city = placemark.administrativeArea;
                 }
                 
                 _city=[city substringWithRange:NSMakeRange(0, city.length-1)];
                 NSLog(@"城市名为：%@",_city);
                 
                 [self Weather];
             }
             
             else
             {
                 NSLog(@"获取城市名失败");
                 [self Weather];
             }
             
         }];
        //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
        [manager stopUpdatingLocation];
        NSLog(@"结束定位");

    }
    @catch (NSException *exception) {
        [self Weather];
    }
    
}

//获取天气状况数值

-(void)Weather
{
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //NSLog(@"ESPViewController do the execute work...");
        NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@"http://wthrcdn.etouch.cn/WeatherApi?city=%@",_city]];
        NSLog(@"URL=%@",astring);
        NSURL * URL = [NSURL URLWithString:[astring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLRequest * request = [[NSURLRequest alloc]initWithURL:URL];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"[开始处理天气数据]");
        dispatch_async(dispatch_get_main_queue(), ^{
            // when canceled by user, don't show the alert view again
            if (error) {
                NSLog(@"error: %@",[error localizedDescription]);
            }else{
                
                @try {
                    
                    //NSLog(@"response : %@",response);
                    //NSLog(@"backData : %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                    
                    NSString *string0 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    
                    NSString *string11 = @"<wendu>";
                    NSString *string12 = @"</wendu>";
                    
                    NSString *string21 = @"<shidu>";
                    NSString *string22 = @"</shidu>";
                    
                    NSString *string31 = @"<pm25>";
                    NSString *string32 = @"</pm25>";
                    
                    NSRange range11 = [string0 rangeOfString:string11];
                    NSRange range12 = [string0 rangeOfString:string12];
                    NSRange range21 = [string0 rangeOfString:string21];
                    NSRange range22 = [string0 rangeOfString:string22];
                    NSRange range31 = [string0 rangeOfString:string31];
                    NSRange range32 = [string0 rangeOfString:string32];
                    
                    unsigned long location11 = range11.location;
                    unsigned long location12 = range12.location;
                    unsigned long location21 = range21.location;
                    unsigned long location22 = range22.location;
                    unsigned long location31 = range31.location;
                    unsigned long location32 = range32.location;
                    
                    
                    NSString *wendu=[string0 substringWithRange:NSMakeRange(location11+7,location12-location11-7)];
                    NSString *shidu=[string0 substringWithRange:NSMakeRange(location21+7,location22-location21-7)];
                    NSString *aqi=[string0 substringWithRange:NSMakeRange(location31+6,location32-location31-6)];
                    NSLog(@"wendu=%@,shidu=%@,aqi=%@",wendu,shidu,aqi);
                    
                    if (aqi==NULL) {
                        aqi=@"100";
                    }
                    if (wendu==NULL) {
                        wendu=@"25";
                    }
                    if (shidu==NULL) {
                        shidu=@"70";
                    }
                    self.Out_pm.text=aqi;
                    self.Out_tem.text=wendu;
                    self.Out_water.text=[shidu substringWithRange:NSMakeRange(0,shidu.length-1)];
                    
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"【获取天气数据失败，使用默认数据。】");
                    
                    // 更新界面
                    self.Out_pm.text=@"100";
                    self.Out_tem.text=@"25";
                    self.Out_water.text=@"70";
                    
                }
            }

        });
    });
    
    
}

#pragma mark-----UIScrollViewDelegate---------
//实现协议UIScrollViewDelegate的方法，必须实现的
-(void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    float n=scrollView.contentOffset.x;
    float x=self.SV.frame.size.width;
    NSLog(@"位置：%f",n);
    if (n==0) {
        [self.Page setImage:[UIImage imageNamed:@"page_51.png"]];
    }
    if (n==x) {
        [self.Page setImage:[UIImage imageNamed:@"page_52.png"]];
    }
    if (n==(2*x)) {
        [self.Page setImage:[UIImage imageNamed:@"page_53.png"]];
    }
    if (n==(3*x)) {
        [self.Page setImage:[UIImage imageNamed:@"page_54.png"]];
    }
    if (n==(4*x)) {
        [self.Page setImage:[UIImage imageNamed:@"page_55.png"]];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"[控制界面生成：viewDidLoad]");
    self.navigationController.navigationBarHidden = YES;
    //_city=@"上海";
    isON=true;
    //[self Location_city];
    //[self checkNetworkChange];
    _city = [[NSUserDefaults standardUserDefaults] objectForKey:@"location_city"];
    if (!_city) {
        _city=@"上海";
    }
    [self Weather];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped)];
    [self.L_arrow addGestureRecognizer:singleTap];
    _input = @"";
    [self.indi setHidden:YES];
    [self.L_w_warn setHidden:YES];
    [self.Filter setHidden:YES];
    [self.View_shajun setHidden:YES];
    [self.P_shajun_s setHidden:YES];
    
    self.SV.delegate=self;
    self.SV.contentSize = CGSizeMake(self.SV.frame.size.width*5, self.SV.frame.size.height);
    
    NSLog(@"Contentsize=%f,%f",self.SV.frame.size.height,self.SV.frame.size.width);
    
    //[self Adapter];
    
    islight=iswifi=true;
    islock=isopen=ison=false;
    shajun_flag=0;
    roll3=roll2=1;
    
    NSString *d_Name = [[NSUserDefaults standardUserDefaults] objectForKey:[_device getMacAddressString]];
    if (d_Name) {
        self.Top_name.text=d_Name;
    }
    
    timer =  [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(Send_check) userInfo:nil repeats:YES];
    timer2 =  [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(Location_city) userInfo:nil repeats:YES];
    //添加滤网重置点击事件
    UITapGestureRecognizer *FIlter_Tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage)];
    [self.Filter0 addGestureRecognizer:FIlter_Tap];
    self.Filter0.userInteractionEnabled=YES;
}

//滤网重置
-(void)onClickImage{
    NSLog(@"重置滤网命令");
    Reset_filter = [[UIAlertView alloc] initWithTitle:@"复位提示" message:@"更换滤芯前请勿进行复位操作，复位后滤芯寿命将重新计算，为保证数据准确性，请更换后进行操作。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"复位", nil];
    Reset_filter.tag=4;
    [Reset_filter show];
    //[self sendData:RESET_FILTER];
}

-(void)photoTapped{
    //[_device stopHeatBeat];
    [self Return_list];
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
        //All View
        self.View_up.frame=CGRectMake(0,20,320,55);
        self.View_m.frame=CGRectMake(0,75,320,50);
        self.View_middle.frame=CGRectMake(0,125,320,278);
        self.View_down.frame=CGRectMake(0,403,320,77);
        self.View_wait.frame=CGRectMake(0,125,320,355);
        //View_up
        self.L_arrow.frame=CGRectMake(0,15,49,28);
        self.R_arrow.frame=CGRectMake(265,15,49,28);
        //self.Top_name.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:30.0];
        //View_m
        self.B_home.frame=CGRectMake(17,15,33,28);
        self.B_menu.frame=CGRectMake(272,15,33,28);
        self.Out_pm.frame=CGRectMake(100,32,38,18);
        self.Out_pm.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:15.0];
        self.Out_tem.frame=CGRectMake(141,32,38,18);
        self.Out_tem.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:15.0];
        self.Out_water.frame=CGRectMake(175,32,38,18);
        self.Out_water.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:15.0];
        //View_middle
        self.SV.frame=CGRectMake(75,55,172,137);
        NSLog(@"Contentsize=%f,%f",self.SV.frame.size.height,self.SV.frame.size.width);
        self.SV.contentSize = CGSizeMake(self.SV.frame.size.width*5, self.SV.frame.size.height);
        self.View1.frame=CGRectMake(0,0,172,137);
        self.View2.frame=CGRectMake(172,0,172,137);
        self.View3.frame=CGRectMake(344,0,172,137);
        self.VIew4.frame=CGRectMake(516,0,172,137);
        self.View5.frame=CGRectMake(688,0,172,137);
        
        self.Circle.frame=CGRectMake(31,0,258,248);
       
        self.B_filter_warn.frame=CGRectMake(8,231,48,39);
        self.B_help.frame=CGRectMake(277,235,35,35);
        self.B_page.frame=CGRectMake(125,256,73,7);
         //View1
        self.Time.frame=CGRectMake(7,1,21,21);
        self.Light.frame=CGRectMake(50,0,21,21);
        self.Lock.frame=CGRectMake(100,1,21,21);
        self.Wifi.frame=CGRectMake(137,1,21,20);
        
        self.Water1.frame=CGRectMake(28,36,47,59);
        self.Water2.frame=CGRectMake(79,36,47,59);
        self.Cup.frame=CGRectMake(7,110,25,27);
        self.Fun.frame=CGRectMake(38,110,27,27);
        self.P_auto.frame=CGRectMake(67,110,24,20);
        self.Pm25.frame=CGRectMake(95,113,62,28);
        self.Pm25.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:31.0];
         //View2
        self.Water.frame=CGRectMake(13,21,147,81);
        self.L_w_warn.font=[UIFont fontWithName:@"Helvetica Neue" size:25.0];
        self.P_shajun.frame=CGRectMake(44,3,84,132);
         //View3
        self.Fun0.frame=CGRectMake(8,24,156,79);
         //View4
        self.Time0.frame=CGRectMake(13,29,147,79);
         //View5
        self.Filter0.frame=CGRectMake(33,0,106,98);
        self.L_filter.font=[UIFont fontWithName:@"Helvetica Neue" size:25.0];
        //View_down
        self.B_open.frame=CGRectMake(20,18,41,41);
        self.B_level.frame=CGRectMake(100,18,41,41);
        self.B_set_time.frame=CGRectMake(179,18,41,41);
        self.B_set_menu.frame=CGRectMake(259,18,41,41);
        //View_wait
        self.B_w_open.frame=CGRectMake(111,102,98,103);
        self.L_open.frame=CGRectMake(8,213,304,19);
        self.L_open.font=[UIFont fontWithName:@"Helvetica Neue" size:20.0];
        
    }
    //iphone 5
    if (width==320 && height==568) {
         //All View
        self.View_up.frame=CGRectMake(0,20,320,65);
        self.View_m.frame=CGRectMake(0,85,320,60);
        self.View_middle.frame=CGRectMake(0,145,320,327);
        self.View_down.frame=CGRectMake(0,471,320,97);
        self.View_wait.frame=CGRectMake(0,145,320,423);
        //View_up
        self.L_arrow.frame=CGRectMake(0,18,53,30);
        self.R_arrow.frame=CGRectMake(267,18,53,30);
        self.Top_name.font=[UIFont fontWithName:@"Helvetica Neue" size:30.0];
        //View_m
        self.B_home.frame=CGRectMake(17,16,28,25);
        self.B_menu.frame=CGRectMake(273,16,29,26);
        
        self.P_pm.frame=CGRectMake(97,12,24,11);
        self.P_tem.frame=CGRectMake(157,12,8,11);
        self.P_water.frame=CGRectMake(203,12,9,11);
        
        self.Out_pm.frame=CGRectMake(91,27,38,25);
        self.Out_pm.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:17.0];
        self.Out_tem.frame=CGRectMake(143,27,38,25);
        self.Out_tem.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:17.0];
        self.Out_water.frame=CGRectMake(189,27,38,25);
        self.Out_water.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:17.0];
        //View_middle
        self.SV.frame=CGRectMake(65,65,190,164);
        NSLog(@"Contentsize=%f,%f",self.SV.frame.size.height,self.SV.frame.size.width);
        self.SV.contentSize = CGSizeMake(self.SV.frame.size.width*5, self.SV.frame.size.height);
        self.View1.frame=CGRectMake(0,0,190,160);
        self.View2.frame=CGRectMake(190,0,190,160);
        self.View3.frame=CGRectMake(380,0,190,160);
        self.VIew4.frame=CGRectMake(570,0,190,160);
        self.View5.frame=CGRectMake(760,0,190,160);
        self.Filter.frame=CGRectMake(8,276,57,42);
        self.B_help.frame=CGRectMake(276,279,36,35);
         //View1
        self.Circle.frame=CGRectMake(24,8,273,273);
        self.Water1.frame=CGRectMake(27,40,56,75);
        self.Water2.frame=CGRectMake(87,40,56,75);
        
        self.B_page.frame=CGRectMake(124,300,73,7);
        self.Time.frame=CGRectMake(4,2,23,23);
        self.Light.frame=CGRectMake(50,0,23,23);
        self.Lock.frame=CGRectMake(100,1,23,23);
        self.Wifi.frame=CGRectMake(150,1,23,23);
        
        self.Cup.frame=CGRectMake(7,132,31,31);
        self.Fun.frame=CGRectMake(41,132,31,31);
        self.P_auto.frame=CGRectMake(74,132,24,20);
        self.Pm25.frame=CGRectMake(107,132,62,35);
        self.Pm25.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:38.0];
        //View2
        self.Water.frame=CGRectMake(13,30,147,82);
        //self.L_w_warn.font=[UIFont fontWithName:@"HelveticaNeue-ThinCond" size:25.0];
        self.P_shajun.frame=CGRectMake(43,0,105,165);
        //View3
        self.Fun0.frame=CGRectMake(17,37,145,76);
        //View4
        self.Time0.frame=CGRectMake(13,32,149,86);
        //View5
        self.Filter0.frame=CGRectMake(38,8,106,98);
        
        //View_down
        self.B_open.frame=CGRectMake(20,29,42,42);
        self.B_level.frame=CGRectMake(100,29,42,42);
        self.B_set_time.frame=CGRectMake(179,29,42,42);
        self.B_set_menu.frame=CGRectMake(260,29,42,42);
        //View_wait
        self.B_w_open.frame=CGRectMake(111,110,98,110);
        self.L_open.frame=CGRectMake(8,228,304,21);
        self.L_open.font=[UIFont fontWithName:@"Helvetica Neue" size:20.0];
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
    NSLog(@"[控制界面出现：viewWillAppear]");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendPipeData:) name:kOnSendPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSendLocalPipeData:) name:kOnSendLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvPipeData:) name:kOnRecvPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvPipeData:) name:kOnRecvPipeSyncData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceStateChanged:) name:kOnDeviceStateChanged object:nil];
    [self Send_check];
}

-(void)viewDidAppear:(BOOL)animated{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    NSLog(@"x=%f y=%f",width,height);
    if (width==414 && height==736) {
        self.SV.contentSize = CGSizeMake(self.SV.frame.size.width*5, self.SV.frame.size.height);
    }
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
    NSLog(@"[控制界面消失：viewWillDisappear]");
    
    //[[XLinkExportObject sharedObject] disconnectDevice:_device withReason:0];
    [timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
    [timer2 setFireDate:[NSDate distantFuture]];//关闭定时器
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//发送数据通用函数
-(void)sendData:(NSString*)data
{
    NSData * data1 = [self hexToData:data];
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
    
    if ( sendResult < 0) {
        NSLog(@"发送命令失败%d",sendResult);
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
    hexToBytes(bytes, [hexString UTF8String], (int)[hexString length]);
    
    NSData * data = [[NSData alloc] initWithBytes:bytes length:len];
    
    free(bytes);
    return data;
}

void hexToBytes(char * bytes, const char * hexString, int hexLength)
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
            Name.tag=0;
            [Name show];
            
        }
            break;
            
        case 1:{
            Relogin = [[UIAlertView alloc] initWithTitle:@"是否退出登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            Relogin.tag=2;
            [Relogin show];
        }
            break;
            
        case 2:{
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            NSString *str3 = [NSString stringWithFormat:@"当前版本号：%@",app_Version];
            Version = [[UIAlertView alloc] initWithTitle:@"版本号" message:str3 delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            Version.tag=3;
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
                //NSLog(@"auther=%@",_device.getDeviceKeyData);
                NSString *name=[Name textFieldAtIndex:0].text;
                if(name.length!=0)
                {
                    if (name.length<=15) {
                        NSLog(@"修改设备名字成功");
                        [[NSUserDefaults standardUserDefaults] setObject:name forKey:[_device getMacAddressString]];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        self.Top_name.text=name;
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
                [timer setFireDate:[NSDate distantFuture]];//关闭定时器
                [self CleanDeviceCache:_device];
                [self Return_list];
            }
            break;
        case 2:
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
        case 4:
            if (buttonIndex == 1) {
                [self sendData:RESET_FILTER];
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
    [[NSUserDefaults standardUserDefaults] setObject:deviceArr forKey:@"devices"];
}

-(void)setDevice:(DeviceEntity*)device{
    NSLog(@"设置设备。");
    _device = device;
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


//接收数据的地方
- (void)RecvPipeData:(NSNotification*)notify {
    @try {
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
                [self Return_Home];
                NSLog(@"开启净化器");
                [self.View_wait setHidden:YES];
                isopen=true;
            }
            else
            {
                NSLog(@"关闭净化器");
                [self.View_wait setHidden:NO];
                isopen=false;
            }
        }
        //童锁
        if ([output hasPrefix:@"2"]) {
            NSString *ss = [output substringWithRange:NSMakeRange(2, 1)];
            if ([ss isEqualToString:@"1"]) {
                islock=true;
                //[self.Lock setImage:[UIImage imageNamed:@"open_lock.png"]];
                [self.Lock setBackgroundImage:[UIImage imageNamed:@"open_lock.png"] forState:UIControlStateNormal];
            }
            else
            {
                islock=false;
                //[self.Lock setImage:[UIImage imageNamed:@"close_lock.png"]];
                [self.Lock setBackgroundImage:[UIImage imageNamed:@"close_lock.png"] forState:UIControlStateNormal];
            }
        }
        
        if ([output hasPrefix:@"3"]) {
            NSString *ss = [output substringWithRange:NSMakeRange(4, 1)];
            
            switch ([ss intValue]) {
                case 1:
                    [self.Fun setImage:[UIImage imageNamed:@"fun0.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_0.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular1.png"]];
                    roll2=2;
                    break;
                case 2:
                    [self.Fun setImage:[UIImage imageNamed:@"fun1.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_1.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular2.png"]];
                    roll2=3;
                    break;
                case 3:
                    [self.Fun setImage:[UIImage imageNamed:@"fun2.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_2.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular3.png"]];
                    roll2=4;
                    break;
                case 4:
                    [self.Fun setImage:[UIImage imageNamed:@"fun3.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_3.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular4.png"]];
                    roll2=5;
                    break;
                case 5:
                    [self.Fun setImage:[UIImage imageNamed:@"fun4.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_4.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular5.png"]];
                    roll2=1;
                    break;
                default:
                    [self.Fun setImage:[UIImage imageNamed:@"fun0.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_0.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular1.png"]];
                    roll2=2;
                    NSLog(@"档位更新错误！");
                    break;
            }

            
        }
        
        //档位
        if ([output hasPrefix:@"4"]) {
            NSString *hh = [output substringWithRange:NSMakeRange(2, 1)];
            NSString *ss = [output substringWithRange:NSMakeRange(4, 1)];
            
            if ([hh intValue]==1 ) {
                roll2=1;
                [self.P_auto setHidden:NO];
                [self.Fun0 setImage:[UIImage imageNamed:@"auto_fun0.png"]];
                switch ([ss intValue]) {
                    case 1:
                        [self.Fun setImage:[UIImage imageNamed:@"fun0.png"]];
                        [self.Circle setImage:[UIImage imageNamed:@"circular1.png"]];
                        break;
                    case 2:
                        [self.Fun setImage:[UIImage imageNamed:@"fun1.png"]];
                        
                        [self.Circle setImage:[UIImage imageNamed:@"circular2.png"]];
                       
                        break;
                    case 3:
                        [self.Fun setImage:[UIImage imageNamed:@"fun2.png"]];
                        
                        [self.Circle setImage:[UIImage imageNamed:@"circular3.png"]];
                        
                        break;
                    case 4:
                        [self.Fun setImage:[UIImage imageNamed:@"fun3.png"]];
                        
                        [self.Circle setImage:[UIImage imageNamed:@"circular4.png"]];
                        
                        break;
                    case 5:
                        [self.Fun setImage:[UIImage imageNamed:@"fun4.png"]];
                        [self.Circle setImage:[UIImage imageNamed:@"circular5.png"]];
                        
                        break;
                    default:
                        [self.Fun setImage:[UIImage imageNamed:@"fun0.png"]];
                        [self.Circle setImage:[UIImage imageNamed:@"circular1.png"]];
                        NSLog(@"档位更新错误！");
                        break;
                }

            }else{
            
            [self.P_auto setHidden:YES];
            switch ([ss intValue]) {
                case 1:
                    [self.Fun setImage:[UIImage imageNamed:@"fun0.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_0.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular1.png"]];
                    roll2=2;
                    break;
                case 2:
                    [self.Fun setImage:[UIImage imageNamed:@"fun1.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_1.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular2.png"]];
                    roll2=3;
                    break;
                case 3:
                    [self.Fun setImage:[UIImage imageNamed:@"fun2.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_2.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular3.png"]];
                    roll2=4;
                    break;
                case 4:
                    [self.Fun setImage:[UIImage imageNamed:@"fun3.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_3.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular4.png"]];
                    roll2=5;
                    break;
                case 5:
                    [self.Fun setImage:[UIImage imageNamed:@"fun4.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_4.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular5.png"]];
                    roll2=6;
                    break;
                default:
                    [self.Fun setImage:[UIImage imageNamed:@"fun0.png"]];
                    [self.Fun0 setImage:[UIImage imageNamed:@"FUN_0.png"]];
                    [self.Circle setImage:[UIImage imageNamed:@"circular1.png"]];
                    roll2=2;
                    NSLog(@"档位更新错误！");
                    break;
            }
            
            }
        }
        //定时关机
        if ([output hasPrefix:@"8"]) {
            NSString *ss = [output substringWithRange:NSMakeRange(2, 1)];
            
            switch ([ss intValue]) {
                case 0:
                    [self.Time setImage:[UIImage imageNamed:@"close_time.png"]];
                    [self.Time0 setImage:[UIImage imageNamed:@"TIME.png"]];
                    roll3=1;
                    break;
                case 1:
                    [self.Time setImage:[UIImage imageNamed:@"open_time.png"]];
                    [self.Time0 setImage:[UIImage imageNamed:@"TIME_1.png"]];
                    roll3=2;
                    break;
                case 2:
                    [self.Time setImage:[UIImage imageNamed:@"open_time.png"]];
                    [self.Time0 setImage:[UIImage imageNamed:@"TIME_2.png"]];
                    roll3=3;
                    break;
                case 3:
                    [self.Time setImage:[UIImage imageNamed:@"open_time.png"]];
                    [self.Time0 setImage:[UIImage imageNamed:@"TIME_3.png"]];
                    roll3=4;
                    break;
                case 4:
                    [self.Time setImage:[UIImage imageNamed:@"open_time.png"]];
                    [self.Time0 setImage:[UIImage imageNamed:@"TIME_4.png"]];
                    roll3=0;
                    break;
                default:
                    [self.Time setImage:[UIImage imageNamed:@"close_time.png"]];
                    [self.Time0 setImage:[UIImage imageNamed:@"TIME.png"]];
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
                
                [self.View_wait setHidden:YES];
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
                @try {
                NSString *time   =list[13];
                NSString *shajun =list[14];
                //杀菌状态下
                    if (shajun_flag==0) {
                        if ([shajun intValue]==1) {
                            [self.View_shajun setHidden:NO];
                            [self.P_shajun_s setHidden:NO];
                            float x=self.SV.frame.size.width;
                            CGPoint point = CGPointMake(x, 0.0f);
                            [self.SV setContentOffset:point animated:YES];
                            [self.Page setImage:[UIImage imageNamed:@"page_52.png"]];
                            self.SV.scrollEnabled=NO;
                            if(timer1!=nil)
                                [timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
                            timer1=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(Jump_home) userInfo:nil repeats:NO];
                        }
                        else{
                            self.SV.scrollEnabled=YES;
                            [self.View_shajun setHidden:YES];
                            [self.P_shajun_s setHidden:YES];
                        }
                        
                    }else{
                        if ([shajun intValue]==1) {
                            
                        }
                        else{
                            self.SV.scrollEnabled=YES;
                            [self.View_shajun setHidden:YES];
                            [self.P_shajun_s setHidden:YES];
                        }
                    }
                    shajun_flag=[shajun intValue];
                //更新定时
                switch ([time intValue]) {
                    case 0:
                        [self.Time setImage:[UIImage imageNamed:@"close_time.png"]];
                        [self.Time0 setImage:[UIImage imageNamed:@"TIME.png"]];
                        roll3=1;
                        break;
                    case 1:
                        [self.Time setImage:[UIImage imageNamed:@"open_time.png"]];
                        [self.Time0 setImage:[UIImage imageNamed:@"TIME_1.png"]];
                        roll3=2;
                        break;
                    case 2:
                        [self.Time setImage:[UIImage imageNamed:@"open_time.png"]];
                        [self.Time0 setImage:[UIImage imageNamed:@"TIME_2.png"]];
                        roll3=3;
                        break;
                    case 3:
                        [self.Time setImage:[UIImage imageNamed:@"open_time.png"]];
                        [self.Time0 setImage:[UIImage imageNamed:@"TIME_3.png"]];
                        roll3=4;
                        break;
                    case 4:
                        [self.Time setImage:[UIImage imageNamed:@"open_time.png"]];
                        [self.Time0 setImage:[UIImage imageNamed:@"TIME_4.png"]];
                        roll3=0;
                        break;
                    default:
                        [self.Time setImage:[UIImage imageNamed:@"close_time.png"]];
                        [self.Time0 setImage:[UIImage imageNamed:@"TIME.png"]];
                        roll3=1;
                        break;
                }
                }
                @catch (NSException *exception) {
                    NSLog(@"更新定时和杀菌失败！");
                }
                
                //更新湿度
                NSString *P1=[shidu substringWithRange:NSMakeRange(0,1)];
                NSString *P2=[shidu substringWithRange:NSMakeRange(1,1)];
                NSLog(@"P1=%@,P2=%@",P1,P2);
                switch ([P1 intValue]) {
                    case 0:
                        [self.Water1 setImage:[UIImage imageNamed:@"b0.png"]];
                        break;
                    case 1:
                        [self.Water1 setImage:[UIImage imageNamed:@"b1.png"]];
                        break;
                    case 2:
                        [self.Water1 setImage:[UIImage imageNamed:@"b2.png"]];
                        break;
                    case 3:
                        [self.Water1 setImage:[UIImage imageNamed:@"b3.png"]];
                        break;
                    case 4:
                        [self.Water1 setImage:[UIImage imageNamed:@"b4.png"]];
                        break;
                    case 5:
                        [self.Water1 setImage:[UIImage imageNamed:@"b5.png"]];
                        break;
                    case 6:
                        [self.Water1 setImage:[UIImage imageNamed:@"b6.png"]];
                        break;
                    case 7:
                        [self.Water1 setImage:[UIImage imageNamed:@"b7.png"]];
                        break;
                    case 8:
                        [self.Water1 setImage:[UIImage imageNamed:@"b8.png"]];
                        break;
                    case 9:
                        [self.Water1 setImage:[UIImage imageNamed:@"b9.png"]];
                        break;
                        
                    default:
                        break;
                }
                switch ([P2 intValue]) {
                    case 0:
                        [self.Water2 setImage:[UIImage imageNamed:@"b0.png"]];
                        break;
                    case 1:
                        [self.Water2 setImage:[UIImage imageNamed:@"b1.png"]];
                        break;
                    case 2:
                        [self.Water2 setImage:[UIImage imageNamed:@"b2.png"]];
                        break;
                    case 3:
                        [self.Water2 setImage:[UIImage imageNamed:@"b3.png"]];
                        break;
                    case 4:
                        [self.Water2 setImage:[UIImage imageNamed:@"b4.png"]];
                        break;
                    case 5:
                        [self.Water2 setImage:[UIImage imageNamed:@"b5.png"]];
                        break;
                    case 6:
                        [self.Water2 setImage:[UIImage imageNamed:@"b6.png"]];
                        break;
                    case 7:
                        [self.Water2 setImage:[UIImage imageNamed:@"b7.png"]];
                        break;
                    case 8:
                        [self.Water2 setImage:[UIImage imageNamed:@"b8.png"]];
                        break;
                    case 9:
                        [self.Water2 setImage:[UIImage imageNamed:@"b9.png"]];
                        break;
                        
                    default:
                        break;
                }

                //更新PM2.5
                self.Pm25.text=[pm substringWithRange:NSMakeRange(2,3)];
                //更新档位风速
                if ([autu intValue]==1) {
                    roll2=1;
                    [self.P_auto setHidden:NO];
                    [self.Fun0 setImage:[UIImage imageNamed:@"auto_fun0.png"]];
                    /*
                    switch ([level intValue]) {
                        case 1:
                            [self.Fun setImage:[UIImage imageNamed:@"fun0.png"]];

                            [self.Circle setImage:[UIImage imageNamed:@"circular1.png"]];
                           
                            break;
                        case 2:
                            [self.Fun setImage:[UIImage imageNamed:@"fun1.png"]];
                           
                            [self.Circle setImage:[UIImage imageNamed:@"circular2.png"]];
                            
                            break;
                        case 3:
                            [self.Fun setImage:[UIImage imageNamed:@"fun2.png"]];
                           
                            [self.Circle setImage:[UIImage imageNamed:@"circular3.png"]];
                            
                            break;
                        case 4:
                            [self.Fun setImage:[UIImage imageNamed:@"fun3.png"]];
                           
                            [self.Circle setImage:[UIImage imageNamed:@"circular4.png"]];
                            
                            break;
                        case 5:
                            [self.Fun setImage:[UIImage imageNamed:@"fun4.png"]];
                            
                            [self.Circle setImage:[UIImage imageNamed:@"circular5.png"]];
                            
                            break;
                        default:
                    
                            break;
                    }*/

                }else{
                [self.P_auto setHidden:YES];
                roll2=1;
                    /*
                switch ([level intValue]) {
                    case 1:
                        [self.Fun setImage:[UIImage imageNamed:@"fun0.png"]];
                        [self.Fun0 setImage:[UIImage imageNamed:@"FUN_0.png"]];
                        [self.Circle setImage:[UIImage imageNamed:@"circular1.png"]];
                        roll2=2;
                        break;
                    case 2:
                        [self.Fun setImage:[UIImage imageNamed:@"fun1.png"]];
                        [self.Fun0 setImage:[UIImage imageNamed:@"FUN_1.png"]];
                        [self.Circle setImage:[UIImage imageNamed:@"circular2.png"]];
                        roll2=3;
                        break;
                    case 3:
                        [self.Fun setImage:[UIImage imageNamed:@"fun2.png"]];
                        [self.Fun0 setImage:[UIImage imageNamed:@"FUN_2.png"]];
                        [self.Circle setImage:[UIImage imageNamed:@"circular3.png"]];
                        roll2=4;
                        break;
                    case 4:
                        [self.Fun setImage:[UIImage imageNamed:@"fun3.png"]];
                        [self.Fun0 setImage:[UIImage imageNamed:@"FUN_3.png"]];
                        [self.Circle setImage:[UIImage imageNamed:@"circular4.png"]];
                        roll2=5;
                        break;
                    case 5:
                        [self.Fun setImage:[UIImage imageNamed:@"fun4.png"]];
                        [self.Fun0 setImage:[UIImage imageNamed:@"FUN_4.png"]];
                        [self.Circle setImage:[UIImage imageNamed:@"circular5.png"]];
                        roll2=6;
                        break;
                    default:
    
                        break;
                }*/
                }
                if ([lock isEqualToString:@"1"]) {
                    islock=true;
                    //[self.Lock setImage:[UIImage imageNamed:@"open_lock.png"]];
                    [self.Lock setBackgroundImage:[UIImage imageNamed:@"open_lock.png"] forState:UIControlStateNormal];
                }
                else
                {
                    islock=false;
                    //[self.Lock setImage:[UIImage imageNamed:@"close_lock.png"]];
                    [self.Lock setBackgroundImage:[UIImage imageNamed:@"close_lock.png"] forState:UIControlStateNormal];
                }
                
                //int n1=[[shidu substringWithRange:NSMakeRange(0, 1)] intValue];
                //int n2=[[shidu substringWithRange:NSMakeRange(1, 1)] intValue];
                
                
               
                if ([water isEqualToString:@"00"]) {
                    
                    [self.Cup setImage:[UIImage imageNamed:@"s_water0.png"]];
                    [self.Water setImage:[UIImage imageNamed:@"water_0.png"]];
                    [self.L_w_warn setHidden:NO];
                    [self showMessage:@"请及时加水！"];
                }
                else
                {
                    //[self.Cup setImage:[UIImage imageNamed:@"cup1.png"]];
                    
                    if ([water isEqualToString:@"100"]) {
                        [self.Cup setImage:[UIImage imageNamed:@"s_water100.png"]];
                        [self.Water setImage:[UIImage imageNamed:@"water_100.png"]];
                        [self.L_w_warn setHidden:YES];
                    }
                    else
                    {
                        int n=[[water substringWithRange:NSMakeRange(0, 1)] intValue];
                        switch (n) {
                            case 0:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water0.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_0.png"]];
                                [self.L_w_warn setHidden:NO];
                                [self showMessage:@"请及时加水！"];
                                break;
                            case 1:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water10.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_10.png"]];
                                [self.L_w_warn setHidden:YES];
                                break;
                            case 2:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water20.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_20.png"]];
                                [self.L_w_warn setHidden:YES];
                                break;
                            case 3:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water30.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_30.png"]];
                                [self.L_w_warn setHidden:YES];
                                break;
                            case 4:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water40.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_40.png"]];
                                [self.L_w_warn setHidden:YES];
                                break;
                            case 5:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water50.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_50.png"]];
                                [self.L_w_warn setHidden:YES];
                                break;
                            case 6:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water60.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_60.png"]];
                                [self.L_w_warn setHidden:YES];
                                break;
                            case 7:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water70.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_70.png"]];
                                [self.L_w_warn setHidden:YES];
                                break;
                            case 8:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water80.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_80.png"]];
                                [self.L_w_warn setHidden:YES];
                                break;
                            case 9:
                                [self.Cup setImage:[UIImage imageNamed:@"s_water90.png"]];
                                [self.Water setImage:[UIImage imageNamed:@"water_90.png"]];
                                [self.L_w_warn setHidden:YES];
                                break;
                            default:
                                break;
                        }
                    }
                }
                
                NSString *_filter = [NSString stringWithFormat:@"%@%s",filter,"%"];
                
                if ([filter isEqualToString:@"00"]) {
                    
                    [self.Filter setHidden:NO];
                    [self.Filter0 setImage:[UIImage imageNamed:@"filter_0.png"]];
                    self.L_filter.text=@"更换过滤器";
                    
                    [self showMessage:@"请更换过滤器！"];
                    self.L_filter.textColor=[UIColor redColor];
                }
                else
                {
                    if ([filter isEqualToString:@"100"]) {
                        [self.Filter0 setImage:[UIImage imageNamed:@"filter_100.png"]];
                        self.L_filter.text=_filter;
                        self.L_filter.textColor=[UIColor blackColor];
                        [self.Filter setHidden:YES];
                    }
                    else
                    {
                        int n=[[filter substringWithRange:NSMakeRange(0, 1)] intValue];
                        switch (n) {
                            case 0:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_0.png"]];
                                self.L_filter.text=@"更换过滤器";
                                
                                [self showMessage:@"请更换过滤器！"];
                                self.L_filter.textColor=[UIColor redColor];
                                [self.Filter setHidden:NO];
                                break;
                            case 1:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_10.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                [self.Filter setHidden:YES];
                                break;
                            case 2:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_20.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                
                                [self.Filter setHidden:YES];
                                break;
                            case 3:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_30.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                
                                [self.Filter setHidden:YES];
                                break;
                            case 4:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_40.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                
                                [self.Filter setHidden:YES];
                                break;
                            case 5:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_50.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                
                                [self.Filter setHidden:YES];
                                break;
                            case 6:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_60.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                
                                [self.Filter setHidden:YES];
                                break;
                            case 7:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_70.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                
                                [self.Filter setHidden:YES];
                                break;
                            case 8:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_80.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                
                                [self.Filter setHidden:YES];
                                break;
                            case 9:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_90.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                
                                [self.Filter setHidden:YES];
                                break;
                            default:
                                [self.Filter0 setImage:[UIImage imageNamed:@"filter_60.png"]];
                                self.L_filter.text=_filter;
                                self.L_filter.textColor=[UIColor blackColor];
                                
                                [self.Filter setHidden:YES];
                                break;
                        }
                    }
                }
                
                if ([light isEqualToString:@"0"])
                {
                    [self.Light setImage:[UIImage imageNamed:@"light_off.png"]];
                    islight=false;
                }
                else
                {
                    [self.Light setImage:[UIImage imageNamed:@"light_on.png"]];
                    islight=true;
                }
            }
            else
            {
                [self.View_wait setHidden:NO];
                isopen=false;
            }
            
            
        }
        //负离子
        if ([output hasPrefix:@"9"]) {
            NSString *ss = [output substringWithRange:NSMakeRange(2, 1)];
            if ([ss isEqualToString:@"0"])
            {
                [self.Light setImage:[UIImage imageNamed:@"light_off.png"]];
                islight=false;
            }
            else
            {
                [self.Light setImage:[UIImage imageNamed:@"light_on.png"]];
                islight=true;
            }
        }
    }
    }
        
    }
    @catch (NSException *exception) {
        NSLog(@"更新命令出错");
    }
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

-(void)Jump_home
{
    [self.View_shajun setHidden:YES];
    self.SV.scrollEnabled=YES;
    CGPoint point = CGPointMake(0.0f, 0.0f);
    [self.SV setContentOffset:point animated:YES];
    [self.Page setImage:[UIImage imageNamed:@"page_51.png"]];
}


- (IBAction)Call_tip:(id)sender {
}

- (IBAction)Open:(id)sender {
    self.SV.scrollEnabled=YES;
    [self.View_shajun setHidden:YES];
    [self sendData:CLOSE];
}

- (IBAction)Level:(id)sender {
    self.SV.scrollEnabled=YES;
    [self.View_shajun setHidden:YES];
    float x=self.SV.frame.size.width;
    CGPoint point = CGPointMake(2*x, 0.0f);
    [self.SV setContentOffset:point animated:YES];
    [self.Page setImage:[UIImage imageNamed:@"page_53.png"]];
    if(timer1!=nil)
    [timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
    timer1=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(Jump_home) userInfo:nil repeats:NO];
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
        case 5:
            [self sendData:STRONG];
            break;
        case 6:
            [self sendData:SMART];
            break;
        default:
            break;
    }
    
}

- (IBAction)Set_time:(id)sender {
    self.SV.scrollEnabled=YES;
    [self.View_shajun setHidden:YES];
    float x=self.SV.frame.size.width;
    CGPoint point = CGPointMake(3*x, 0.0f);
    [self.SV setContentOffset:point animated:YES];
    [self.Page setImage:[UIImage imageNamed:@"page_54.png"]];
    if(timer1!=nil)
    [timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
    timer1=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(Jump_home) userInfo:nil repeats:NO];
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

- (IBAction)Set_menu:(id)sender {
    
    if (islight) {
        [self sendData:LIGHT0];
    }
    else
    {
        [self sendData:LIGHT1];
    }
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
-(void)Return_Home{
    self.SV.scrollEnabled=YES;
    CGPoint point = CGPointMake(0.0f, 0.0f);
    [self.SV setContentOffset:point animated:YES];
    [self.Page setImage:[UIImage imageNamed:@"page_51.png"]];
    
}
- (IBAction)Return_home:(id)sender {
    [self Return_Home];
}

- (IBAction)Call_menu:(id)sender {
    [self pushMenu];
}
- (IBAction)Open0:(id)sender {
        self.SV.scrollEnabled=YES;
        [self sendData:OPEN];
        [self Send_check];
}
- (IBAction)B_lock:(id)sender {
    if (islock) {
        [self sendData:UNLOCK];
    }
    else
    {
        [self sendData:LOCK];
    }
}
@end
