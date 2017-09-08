//
//  RegisterViewController.h
//  xlinkDemo
//
//  Created by kingcom on 15/9/18.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SectionsViewController.h"
//#import "SMSSDKUI.h"
#import <SMS_SDK/Extend/SMSSDKResultHanderDef.h>

#import "SMSUIVerificationCodeViewResultDef.h"
@protocol SecondViewControllerDelegate;

@interface RegisterViewController : UIViewController<SecondViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *Lable_nation_mes;
@property (strong, nonatomic) IBOutlet UILabel *Lable_nation;

@property (strong, nonatomic) IBOutlet UITextField *User_name;
@property (strong, nonatomic) IBOutlet UITextField *User_city;

@property (strong, nonatomic) IBOutlet UITextField *Uid;
@property (strong, nonatomic) IBOutlet UITextField *Psw;
@property (strong, nonatomic) IBOutlet UIView *Wait_view;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *Wait;
@property (strong, nonatomic) IBOutlet UIButton *B_get;

@property (strong, nonatomic) IBOutlet UITextField *Check;
@property (strong, nonatomic) IBOutlet UITextField *nation;

- (IBAction)Register:(id)sender;
- (IBAction)Get:(id)sender;

@end

