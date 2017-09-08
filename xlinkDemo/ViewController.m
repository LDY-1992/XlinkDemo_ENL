//
//  ViewController.m
//  xlinkDemo
//
//  Created by xtmac on 6/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//
#import "Put_data.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ScanDeviceViewController.h"
#import "XLinkExportObject.h"
#import "HttpRequest.h"
#import "HttpRequest_V2.h"
#import <CommonCrypto/CommonDigest.h>
#import "RegisterViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ForgetViewController.h"
#import "HexInputViewController.h"
#import "DeviceEntity.h"
#import "MatchViewController.h"
#import "List.h"
#import "UIView+Toast.h"
#import "Z_controller.h"
#import "BlackBoxViewController.h"
@interface ViewController ()<UIAlertViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate>{
    NSTimer *timer1,*timer2;
    NSString *my_uid,*my_psw,*_city;
    DeviceEntity *_device;
    int n;
}
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ViewController
BOOL in=true;

//定位程序

//定位开始
-(void) Location_city
{
    @try {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
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
                 
                 NSLog(@"地址：%@",placemark.name);
                 [[NSUserDefaults standardUserDefaults] setObject:placemark.name forKey:@"uaddress"];
                 //获取城市
                 
                 NSString *city = placemark.locality;
                 
                 if (!city) {
                     
                     //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                     city = placemark.administrativeArea;
                 }
                 
                 _city=[city substringWithRange:NSMakeRange(0, city.length-1)];
                 NSLog(@"城市名为：%@",_city);
                 [[NSUserDefaults standardUserDefaults] setObject:_city forKey:@"location_city"];
                 //[self Weather];
             }
             
             else
             {
                 NSLog(@"获取城市名失败");
                 //[self Weather];
             }
             
         }];
        //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
        [manager stopUpdatingLocation];
        NSLog(@"结束定位");
        
    }
    @catch (NSException *exception) {
        //[self Weather];
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

-(void)Who_in{
    in=false;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self Location_city];
    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.Ssid.delegate=self;
    self.Psw.delegate=self;
    
    //[self Adapter];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *str3 = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"当前版本号",comment: ""),app_Version];
    [self showMessage:str3];
    
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
        self.Ssid.frame=CGRectMake(20,126,280,40);
        self.Psw.frame=CGRectMake(20,168,280,40);
    }
    //iphone 5
    if (width==320 && height==568) {
        self.Ssid.frame=CGRectMake(20,151,280,40);
        self.Psw.frame=CGRectMake(20,193,280,40);
        
    }
    //iphone 6
    if (width==375 && height==667) {
        
    }
    //iphone 6+
    if (width==414 && height==736) {
        
    }
}


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStart) name:kOnStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogin:) name:kOnLogin object:nil];
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
    if (userData) {
        NSLog(@"【已有账号登陆】");
        NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"myuid"];
        NSString *psw=[[NSUserDefaults standardUserDefaults] objectForKey:@"mypsw"];
        if (phone && psw) {
            self.Ssid.text=phone;
            self.Psw.text=psw;
            [self authWithAccount:phone withPassword:psw];
            [self.Wait_view setHidden:NO];
        }else{
            NSLog(@"【第一次登陆】");
            [self.Wait_view setHidden:YES];
        }
    }else{
        NSLog(@"【第一次登陆】");
        [self.Wait_view setHidden:YES];
    }
    
    [self pushBlockBoxController];
}
-(void)viewWillDisappear:(BOOL)animated{
    //[timer1 setFireDate:[NSDate distantFuture]];//关闭定时器
    //[timer2 setFireDate:[NSDate distantFuture]];//关闭定时器
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnStart object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kOnLogin object:nil];
}


-(void)showWarningAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示",comment: "") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"确定",comment: "") otherButtonTitles:nil, nil];
    [alert show];
    
}

#pragma mark HttpRequest Delegate

-(void)didFinishLoadingData:(NSDictionary *)dic{
    
    NSLog(@"查询V1返回：%@",dic);
    //[HttpRequest_put putWithUID:@"2345567" withID:@"15000884350" withUname:@"111" withUcity:@"222" withDelegate:nil];
    if ([[dic objectForKey:@"status"] intValue] == 200) {
        NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
        if (userData) {
            NSDictionary *result= [dic objectForKey:@"results"];
            //NSLog(@"userData=%@",userData);
            int ID=[[userData objectForKey:@"user_id"] intValue];
            NSString *myID=[NSString stringWithFormat:@"%d",ID];
            
            @try {
                if (result.count>2) {
                    NSString *ucity=[result objectForKey:@"ucity"];
                    NSString *ufrom=@"IOS2.3";
                    NSString *uname=[result objectForKey:@"uname"];
                    NSString *uaddress=[[NSUserDefaults standardUserDefaults] objectForKey:@"uaddress"];
                    if (!uaddress) {
                        uaddress=@"NULL";
                    }
                    NSString *uphone=[[NSUserDefaults standardUserDefaults] objectForKey:@"myuid"];
                    NSString *ucountry=@"86";
                    NSString *uid=myID;
                    
                    NSDictionary *all_data=@{@"ucity" : ucity, @"ufrom" : ufrom, @"uname":uname , @"uaddress":uaddress , @"uphone":uphone , @"ucountry":ucountry , @"uid":uid};
                    [HttpRequest_V2 addData:all_data withTableName:@"ENL_USER_V2" withAccessToken:[userData objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                        if (err) {
                            NSLog(@"err=%@",err);
                        }else{
                            NSLog(@"result=%@",result);
                        }
                    }];
                }
            } @catch (NSException *exception) {
                NSString *ucity=[[NSUserDefaults standardUserDefaults] objectForKey:@"ucity"];
                if (!ucity) {
                    ucity=@"NULL";
                }
                NSString *ufrom=@"IOS2.3";
                NSString *uname=[[NSUserDefaults standardUserDefaults] objectForKey:@"uname"];
                if (!uname) {
                    uname=@"NULL";
                }
                NSString *uaddress=[[NSUserDefaults standardUserDefaults] objectForKey:@"uaddress"];
                if (!uaddress) {
                    uaddress=@"NULL";
                }
                NSString *uphone=[[NSUserDefaults standardUserDefaults] objectForKey:@"myuid"];
                NSString *ucountry=[[NSUserDefaults standardUserDefaults] objectForKey:@"ucountry"];
                if (!ucountry) {
                    ucountry=@"NULL";
                }
                NSString *uid=myID;
                
                NSDictionary *all_data=@{@"ucity" : ucity, @"ufrom" : ufrom, @"uname":uname , @"uaddress":uaddress , @"uphone":uphone , @"ucountry":ucountry , @"uid":uid};
                [HttpRequest_V2 addData:all_data withTableName:@"ENL_USER_V2" withAccessToken:[userData objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
                    if (err) {
                        NSLog(@"err=%@",err);
                    }else{
                        NSLog(@"result=%@",result);
                    }
                }];
            }
        }else{
            NSLog(@"未知错误");
        }
        
    }
    else
    {
        NSLog(@"[获取数据列表失败]");
    }
    
}

-(void) Wright_V2{
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
    int ID=[[userData objectForKey:@"user_id"] intValue];
    NSString *myID=[NSString stringWithFormat:@"%d",ID];
    
    NSString *ucity=[[NSUserDefaults standardUserDefaults] objectForKey:@"ucity"];
    if (!ucity) {
        ucity=@"NULL";
    }
    NSString *ufrom=@"IOS2.3";
    NSString *uname=[[NSUserDefaults standardUserDefaults] objectForKey:@"uname"];
    if (!uname) {
        uname=@"NULL";
    }
    NSString *uaddress=[[NSUserDefaults standardUserDefaults] objectForKey:@"uaddress"];
    if (!uaddress) {
        uaddress=@"NULL";
    }
    NSString *uphone=[[NSUserDefaults standardUserDefaults] objectForKey:@"myuid"];
    NSString *ucountry=[[NSUserDefaults standardUserDefaults] objectForKey:@"ucountry"];
    if (!ucountry) {
        ucountry=@"NULL";
    }
    NSString *uid=myID;
    
    NSDictionary *all_data=@{@"ucity" : ucity, @"ufrom" : ufrom, @"uname":uname , @"uaddress":uaddress , @"uphone":uphone , @"ucountry":ucountry , @"uid":uid};
    [HttpRequest_V2 addData:all_data withTableName:@"ENL_USER_V2" withAccessToken:[userData objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        if (err) {
            NSLog(@"err=%@",err);
        }else{
            NSLog(@"result=%@",result);
            
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isregister"];
    }];
}

#pragma mark
#pragma mark Xlink Delegate
-(void)onStart{
    NSLog(@"【start回调返回。】");
    
    NSArray *deviceArr = [[NSUserDefaults standardUserDefaults] arrayForKey:@"devices"];
    if (deviceArr.count>0) {
        NSLog(@"【进入列表界面！】");
        [self performSelectorOnMainThread:@selector(pushList) withObject:nil waitUntilDone:NO];
    }
    else{
        NSLog(@"【进入添加设备界面！】");
        [self performSelectorOnMainThread:@selector(pushMatchViewController) withObject:nil waitUntilDone:NO];
    }
    
    [NSThread sleepForTimeInterval:1.0f];
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
    if (userData) {
        if ([[XLinkExportObject sharedObject] loginWithAppID:[[userData objectForKey:@"user_id"] intValue] andAuthStr:[userData objectForKey:@"authorize"]] == 0) {
            NSLog(@"【调用APP登陆成功。】");
            
        }else{
            NSLog(@"【调用APP登陆失败。】");
        }
        [self Set_data];
    }
}

//
-(void)Set_data{
    NSLog(@"开始修改");
    
    NSString *isre=[[NSUserDefaults standardUserDefaults] objectForKey:@"isregister"];
    if (isre) {
        NSLog(@"直接修改");
        [self Wright_V2];
        
    }else{
        NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
        [HttpRequest_V2 QueryDataWithTableName:@"ENL_USER_V2" withAccessToken:[userData objectForKey:@"access_token"] withPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"myuid"] didLoadData:^(id result, NSError *err) {
            if (err) {
                NSLog(@"err=%@",err);
            }else{
                NSLog(@"result=%@",result);
                NSInteger count=[[result objectForKey:@"count"] integerValue];
                if (count==0) {
                    NSLog(@"开始查询V1");
                    //[HttpRequest getWithTable:@"airuser" withID:[[NSUserDefaults standardUserDefaults] objectForKey:@"myuid"] withDelegate:self];
                    [self performSelectorOnMainThread:@selector(Check_V1) withObject:nil waitUntilDone:NO];
                }
            }
            
        }];
    }
}

-(void)Check_V1{
    [HttpRequest getWithTable:@"airuser" withID:[[NSUserDefaults standardUserDefaults] objectForKey:@"myuid"] withDelegate:self];
}
//APP登陆成功回调
-(void)onLogin:(NSNotification*)noti{
    int result = [[noti.object objectForKey:@"result"] intValue];
    if (result == 0) {
        NSLog(@"【APP登陆成功】");
        
    }else{
        NSLog(@"【APP登陆失败】");
        //[self performSelectorOnMainThread:@selector(Login_failed) withObject:nil waitUntilDone:NO];
    }
    
}

//推出各个界面
-(void)pushHexInputViewController:(DeviceEntity*)device{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HexInputViewController *view = [storyBoard instantiateViewControllerWithIdentifier:@"HexInputViewController"];
    [view setDevice:device];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)pushList{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    List *view = [storyBoard instantiateViewControllerWithIdentifier:@"List"];
    [view initData];
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
    //[View isADD];
    [self.navigationController pushViewController:View animated:YES];
}

-(void)pushRegisterViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterViewController *Register = [storyBoard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:Register animated:YES];
}
-(void)pushForgetViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterViewController *Forget = [storyBoard instantiateViewControllerWithIdentifier:@"ForgetViewController"];
    [self.navigationController pushViewController:Forget animated:YES];
}
-(void)pushZViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    Z_controller *Z_c = [storyBoard instantiateViewControllerWithIdentifier:@"Z_controller"];
    [self.navigationController pushViewController:Z_c animated:YES];
}
-(void)pushBlockBoxController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BlackBoxViewController *Z_c = [storyBoard instantiateViewControllerWithIdentifier:@"BlackBoxViewController"];
    [self.navigationController pushViewController:Z_c animated:YES];
}


-(NSString *) md5:(NSString *) input
{
    
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
    
}

- (IBAction)Login:(id)sender {
    [self.Wait_view setHidden:NO];
    
    NSString *UID = [self.Ssid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    long long l=[UID longLongValue];
    UID=[NSString stringWithFormat:@"%lld",l];
    
    NSString *PSW = [self.Psw.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    my_uid=UID; my_psw=PSW;
    
    NSLog(@"UID=%@  PSW=%@",UID,PSW);
    
    if(PSW.length>=6 && PSW.length<=18){
        
        [self authWithAccount:UID withPassword:PSW];
    }
    else
    {
        [self.Wait_view setHidden:YES];
        [self showWarningAlert:NSLocalizedString(@"密码长度必须大于6位小于18位",comment: "")];
    }
    
    
}

-(void)authWithAccount:(NSString *)account withPassword:(NSString *)pwd{
    
    //[timer2 setFireDate:[NSDate distantFuture]];//关闭定时器
    
    [HttpRequest_V2 authWithAccount:account withPassword:pwd didLoadData:^(id result, NSError *err) {
        if (err) {
            NSLog(@"[登陆失败]%@",err);
            
            NSString *err_mes=[HttpRequest_V2 getErrorInfoWithErrorCode:err.code];
            [self performSelectorOnMainThread:@selector(Failed_login:) withObject:err_mes waitUntilDone:NO];
            
        }else{
            NSLog(@"[登陆成功]");
            //[self.Wait_view setHidden:YES];
            [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"userData"];
            
            if (my_uid && my_psw) {
                
                [[NSUserDefaults standardUserDefaults] setObject:my_uid forKey:@"myuid"];
                [[NSUserDefaults standardUserDefaults] setObject:my_psw forKey:@"mypsw"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if ([[XLinkExportObject sharedObject] start] == 0) {
                NSLog(@"调用start成功");
            }else{
                NSLog(@"调用start失败");
            }
            
        }
    }];
}


-(void)Failed_login:(NSString *)err{
    [self.Wait_view setHidden:YES];
    [self showWarningAlert:err];
}

//判断邮箱格式是否正确的代码：
//利用正则表达式验证
-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}
//手机号码验证
/*
 130~139  145,147 15[012356789] 180~189
 */
-(BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^(0|86|17951)?(13[0-9]|14[0-9]|15[0-9]|17[0-9]|18[0-9])[0-9]{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

-(void)OverTime{
    [self.Wait_view setHidden:YES];
    [self.Wait setHidden:YES];
    [self showWarningAlert:NSLocalizedString(@"连接超时，请检查网络后重新操作。",comment: "")];
}

- (IBAction)Register:(id)sender {
    //[self pushRegisterViewController];
    [self performSelectorOnMainThread:@selector(pushRegisterViewController) withObject:nil waitUntilDone:NO];
}

- (IBAction)BA_forget:(id)sender {
    [self pushForgetViewController];
}

//处理文本输入框
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.Ssid isExclusiveTouch]) {
        [self.Ssid resignFirstResponder];
    }
    if (![self.Psw isExclusiveTouch]) {
        [self.Psw resignFirstResponder];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
