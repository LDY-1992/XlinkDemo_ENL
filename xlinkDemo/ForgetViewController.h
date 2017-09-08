//
//  ForgetViewController.h
//  xlinkDemo
//
//  Created by kingcom on 15/12/11.
//  Copyright © 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SectionsViewController.h"
//#import "SMSSDKUI.h"
#import <SMS_SDK/Extend/SMSSDKResultHanderDef.h>

#import "SMSUIVerificationCodeViewResultDef.h"
@protocol SecondViewControllerDelegate;

@interface ForgetViewController : UIViewController<SecondViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *TF_phone;
@property (strong, nonatomic) IBOutlet UITextField *TF_check;
@property (strong, nonatomic) IBOutlet UITextField *TF_psw;
@property (strong, nonatomic) IBOutlet UIButton *B_get;
@property (strong, nonatomic) IBOutlet UITextField *nation;

@property (strong, nonatomic) IBOutlet UIView *View_wait;

@property (strong, nonatomic) IBOutlet UILabel *Lable_country_mes;
@property (strong, nonatomic) IBOutlet UILabel *Lable_country;


- (IBAction)BA_get:(id)sender;
- (IBAction)BA_check:(id)sender;

@end
