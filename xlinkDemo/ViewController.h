//
//  ViewController.h
//  xlinkDemo
//
//  Created by xtmac on 6/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
-(void)Who_in;
@property (strong, nonatomic) IBOutlet UITextField *Ssid;
@property (strong, nonatomic) IBOutlet UITextField *Psw;
@property (strong, nonatomic) IBOutlet UIView *Login_view;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *Wait;
@property (strong, nonatomic) IBOutlet UIView *Wait_view;
@property (strong, nonatomic) IBOutlet UIImageView *Logo;


- (IBAction)Login:(id)sender;
- (IBAction)Register:(id)sender;
- (IBAction)BA_forget:(id)sender;

@end

