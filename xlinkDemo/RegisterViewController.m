//
//  RegisterViewController.m
//  xlinkDemo
//
//  Created by kingcom on 15/9/18.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//
#import "Put_data.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ScanDeviceViewController.h"
#import "XLinkExportObject.h"
#import "HttpRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "HttpRequest_V2.h"

#import "VerifyViewController.h"
#import "SectionsViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/Extend/SMSSDKCountryAndAreaCode.h>
#import <SMS_SDK/Extend/SMSSDK+DeprecatedMethods.h>
#import <SMS_SDK/Extend/SMSSDK+ExtexdMethods.h>
#import <MOBFoundation/MOBFoundation.h>
#import "YJLocalCountryData.h"

@interface RegisterViewController ()<UIAlertViewDelegate, HttpRequestDelegate,UITextFieldDelegate>
{
    NSString *my_uid,*my_psw,*name,*city,*country;
    NSTimer *timer;
    BOOL isbe;
    
    SMSSDKCountryAndAreaCode* _data2;
    
    NSString* _defaultCode;
    NSString* _defaultCountryName;
    NSBundle *_bundle;
    
    int stop;
}

@property (nonatomic, strong) NSMutableArray* areaArray;

@end

@implementation RegisterViewController

- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data
{
    _data2 = data;
    NSLog(@"the area data：%@,%@", data.areaCode,data.countryName);
    _nation.text = [NSString stringWithFormat:@"+%@",data.areaCode];
    _Lable_nation.text=data.countryName;
}

-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* tt = [locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode = [dictCodes objectForKey:tt];
    _nation.text = [NSString stringWithFormat:@"+%@",defaultCode];
    
    NSString* defaultCountryName = [locale displayNameForKey:NSLocaleCountryCode value:tt];
    _defaultCode = defaultCode;
    _defaultCountryName = defaultCountryName;
    _Lable_nation.text=_defaultCountryName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    UIBarButtonItem *nullItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回",comment: "") style:UIBarButtonItemStylePlain target:self action:@selector(Return)];
    self.navigationItem.leftBarButtonItem = nullItem;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title=NSLocalizedString(@"注册",comment: "");
    
    
    [self.Wait_view setHidden:YES];
    isbe=false;
    
    self.User_name.delegate=self;
    self.User_city.delegate=self;
    self.Uid.delegate=self;
    self.Psw.delegate=self;
    self.Check.delegate=self;
    self.nation.delegate=self;
    
    //[self.nation addTarget:self action:@selector(dropdown) forControlEvents:UIControlEventAllTouchEvents];
    
    _Lable_nation.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dropdown)];
    [_Lable_nation addGestureRecognizer:labelTapGestureRecognizer];
    
    //设置本地区号
    [self setTheLocalAreaCode];
    
    NSString *saveTimeString = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveDate"];
    
    NSDateComponents *dateComponents = nil;
    
    if (saveTimeString.length != 0)
    {
        dateComponents = [YJLocalCountryData compareTwoDays:saveTimeString];
    }
    
    if (dateComponents.day >= 1 || saveTimeString.length == 0)
    { //day = 0 ,代表今天，day = 1  代表昨天  day >= 1 表示至少过了一天  saveTimeString.length == 0表示从未进行过缓存
        __weak RegisterViewController *registerViewController = self;
        //获取支持的地区列表
        [SMSSDK getCountryZone:^(NSError *error, NSArray *zonesArray) {
            
            if (!error)
            {
                NSLog(@"get the area code sucessfully");
                //区号数据
                if ([zonesArray isKindOfClass:[NSArray class]])
                {
                    registerViewController.areaArray = [NSMutableArray arrayWithArray:zonesArray];
                }
                //获取到国家列表数据后对进行缓存
                [[MOBFDataService sharedInstance] setCacheData:registerViewController.areaArray forKey:@"countryCodeArray" domain:nil];
                //设置缓存时间
                NSDate *saveDate = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:[MOBFDate stringByDate:saveDate withFormat:@"yyyy-MM-dd"] forKey:@"saveDate"];
                
                //NSLog(@"_areaArray_%@",registerViewController.areaArray);
            }
            else
            {
                NSLog(@"failed to get the area code _%@______error_%@",[error.userInfo objectForKey:@"getZone"],error);
            }
        }];
    }
    else
    {
        _areaArray = [[MOBFDataService sharedInstance] cacheDataForKey:@"countryCodeArray" domain:nil];
    }
}

-(void)dropdown{
    
    SectionsViewController* country2 = [[SectionsViewController alloc] init];
    country2.delegate = self;
    
    //读取本地countryCode
    if (_areaArray.count == 0)
    {
        NSMutableArray *dataArray = [YJLocalCountryData localCountryDataArray];
        
        _areaArray = dataArray;
    }
    
    [country2 setAreaArray:_areaArray];
    [self presentViewController:country2 animated:YES completion:^{
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showWarningAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示",comment: "") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"确定",comment: "") otherButtonTitles:nil, nil];
    [alert show];
    
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


-(void)didFinishLoadingData:(NSDictionary *)dic{
    
        [timer setFireDate:[NSDate distantFuture]];//关闭定时器
        
        if ([[dic objectForKey:@"status"] intValue] == 200) {
            
            [self.Wait_view setHidden:YES];
            
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"user"] forKey:@"userData"];
            
            [[NSUserDefaults standardUserDefaults] setObject:my_uid forKey:@"myuid"];
            [[NSUserDefaults standardUserDefaults] setObject:my_psw forKey:@"mypsw"];
            [[NSUserDefaults standardUserDefaults] setObject:country forKey:@"ucountry"];
            [[NSUserDefaults standardUserDefaults] setObject:city forKey:@"ucity"];
            [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"uname"];
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isregister"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            //NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
            //NSLog(@"userdata=%@",userData);
            //int num_id=[[userData objectForKey:@"id"] intValue];
            //NSString *ID=[NSString stringWithFormat:@"%d",num_id];
            //[HttpRequest_put putWithUID:ID withID:my_uid withUname:name withUcity:city withDelegate:nil];
            
            //NSLog(@"%@",dic);
            //NSLog(@"uid=%@,ID=%@,name=%@,city=%@",my_uid,ID,name,city);
            
            
            
            [self performSelectorOnMainThread:@selector(Return) withObject:nil waitUntilDone:NO];
            
        }
        else if([[dic objectForKey:@"status"] intValue] == 201){
            [self showWarningAlert:NSLocalizedString(@"注册失败，手机号已被注册！",comment: "")];
            [self.Wait_view setHidden:YES];
        }
        else{
            [self showWarningAlert:NSLocalizedString(@"注册失败，请重新注册！",comment: "")];
            [self.Wait_view setHidden:YES];
        }
    
}

-(void)pushLoginViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *Login = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
    [Login Who_in];
    [self.navigationController pushViewController:Login animated:YES];
}
- (IBAction)Register:(id)sender {
    
    NSString *_name=[self.User_name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *_city=[self.User_city.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *_phone=[self.Uid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    long long l=[_phone longLongValue];
    _phone=[NSString stringWithFormat:@"%lld",l];
    
    NSString *_pw=[self.Psw.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *_pin=[self.Check.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //NSString *my_nation=[self.nation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    name=_name;
    if (name==nil) {
        name=@"无";
    }
    city=_city;
    if (!city) {
        city=@"无";
    }
    
    NSString* nation_code = [_nation.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    if(_phone.length>=8 && _pw.length>=6 && _pw.length<=18 && _pin.length>=4 && _nation.text.length>0)
    {
        //进入等待页面
        [self.Wait_view setHidden:NO];
        [self.Wait startAnimating];
        
        [SMSSDK  commitVerificationCode:self.Check.text
         //传获取到的区号
                            phoneNumber:self.Uid.text
                                   zone:nation_code
                                 result:^(SMSSDKUserInfo *userInfo, NSError *error)
         {
             
             if (!error)
             {
                 NSLog(@"验证成功");
                 
                 //timer= [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(OverTime) userInfo:nil repeats:NO];
                 my_uid=_phone;
                 my_psw=_pw;
                 country=nation_code;
                 NSLog(@"V2注册");
                 //[HttpRequest registerWithUID:self.Uid.text withName:self.Uid.text withPWD:self.Psw.text withDelegate:self];
                 //去掉手机好前面的零
                 
                 
                 [HttpRequest_V2 registerWithAccount:_phone withPhone_zone:_nation.text withNickname:name withVerifyCode:nil withPassword:_pw didLoadData:^(id result, NSError *err) {
                     
                     //[timer setFireDate:[NSDate distantFuture]];//关闭定时器
                     if(err){
                         NSLog(@"[V2注册失败]%@[%@]",err,[HttpRequest_V2 getErrorInfoWithErrorCode:err.code]);
                         [self performSelectorOnMainThread:@selector(Hide_WaitView) withObject:nil waitUntilDone:NO];
                         NSString *err_mes=[HttpRequest_V2 getErrorInfoWithErrorCode:err.code];
                         [self performSelectorOnMainThread:@selector(showWarningAlert:) withObject:err_mes waitUntilDone:NO];
                     }else{
                         [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"userData"];
                         [[NSUserDefaults standardUserDefaults] setObject:my_uid forKey:@"myuid"];
                         [[NSUserDefaults standardUserDefaults] setObject:my_psw forKey:@"mypsw"];
                         [[NSUserDefaults standardUserDefaults] setObject:country forKey:@"ucountry"];
                         [[NSUserDefaults standardUserDefaults] setObject:city forKey:@"ucity"];
                         [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"uname"];
                         [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isregister"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         
                         [self performSelectorOnMainThread:@selector(Return) withObject:nil waitUntilDone:NO];
                     }
                 }];
                 
             }
             else
             {
                 NSLog(@"验证失败");
                 [self performSelectorOnMainThread:@selector(Fail_ver) withObject:nil waitUntilDone:NO];
             }
             
         }];
        
    }
    else
    {
        [self showWarningAlert:NSLocalizedString(@"请正确输入信息！",comment: "")];
    }
    
}

//隐藏等待界面
-(void)Hide_WaitView{
    [self.Wait_view setHidden:YES];
}

//验证失败
-(void)Fail_ver{
    [self.Wait_view setHidden:YES];
    [self showWarningAlert:NSLocalizedString(@"验证码错误，请重新验证！",comment: "")];
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
    [self showWarningAlert:NSLocalizedString(@"连接超时，请检查网络后重新登陆。",comment: "")];
}

- (void)Return {
    //[self pushLoginViewController];
    //[self performSelectorOnMainThread:@selector(pushLoginViewController) withObject:nil waitUntilDone:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)Get_code{
    
    NSString *_phone=[self.Uid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //NSString *my_nation=[self.nation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* nation_code = [_nation.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    if (_phone.length!=0 && nation_code.length!=0) {
        
        //变更获取验证码按钮
        stop=0;
        [self.B_get setEnabled:NO];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 耗时的操作
            for (int i=60; i>=1; i--) {
                if(stop==1){
                    break;
                }
                NSString *chr=[NSString stringWithFormat:@"%d",i];
                [NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.B_get setTitle:chr forState:UIControlStateNormal];
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.B_get setEnabled:YES];
                [self.B_get setTitle:NSLocalizedString(@"获取验证码",comment: "") forState:UIControlStateNormal];
            });
            
        });
        
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS
         //这个参数可以选择是通过发送验证码还是语言来获取验证码
                                phoneNumber:self.Uid.text
                                       zone:nation_code
                           customIdentifier:nil //自定义短信模板标识
                                     result:^(NSError *error)
         {
             
             if (!error)
             {
                 NSLog(@"block 获取验证码成功");
                 
             }
             else
             {
                 NSLog(@"获取验证码失败！%@",error);
                 stop=1;
                 [self showWarningAlert:NSLocalizedString(@"获取验证码失败！",comment: "")];
             }
             
         }];
        
    }else{
        [self showWarningAlert:NSLocalizedString(@"请正确输入信息！",comment: "")];
    }
    
}

- (IBAction)Get:(id)sender {
    [self Get_code];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.Uid isExclusiveTouch]) {
        [self.Uid resignFirstResponder];
    }
    if (![self.Psw isExclusiveTouch]) {
        [self.Psw resignFirstResponder];
    }
    if (![self.User_name isExclusiveTouch]) {
        [self.User_name resignFirstResponder];
    }
    if (![self.User_city isExclusiveTouch]) {
        [self.User_city resignFirstResponder];
    }
    if (![self.Check isExclusiveTouch]) {
        [self.Check resignFirstResponder];
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
