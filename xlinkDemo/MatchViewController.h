//
//  MatchViewController.h
//  xlinkDemo
//
//  Created by kingcom on 15/9/23.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *SSID;
@property (strong, nonatomic) IBOutlet UITextField *PSW;
@property (strong, nonatomic) IBOutlet UIView *Wait_view;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *Wait;
@property (strong, nonatomic) IBOutlet UIView *View_add;
@property (strong, nonatomic) IBOutlet UIButton *P_add;


- (IBAction)Match:(id)sender;
- (IBAction)B_add:(id)sender;

-(void)isADD;

@end
