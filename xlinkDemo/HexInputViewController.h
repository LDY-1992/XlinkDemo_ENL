//
//  HexInputViewController.h
//  xlinkDemo
//
//  Created by Leon on 15/6/10.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceEntity;

@interface HexInputViewController : UIViewController

//View

//View_up
@property (strong, nonatomic) IBOutlet UIImageView *L_arrow;
@property (strong, nonatomic) IBOutlet UILabel *Top_name;
@property (strong, nonatomic) IBOutlet UIImageView *R_arrow;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indi;

//View_m
- (IBAction)Return_home:(id)sender;
- (IBAction)Call_menu:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *Out_pm;
@property (strong, nonatomic) IBOutlet UILabel *Out_tem;
@property (strong, nonatomic) IBOutlet UILabel *Out_water;
@property (strong, nonatomic) IBOutlet UIButton *B_menu;
@property (strong, nonatomic) IBOutlet UIButton *B_home;
@property (strong, nonatomic) IBOutlet UIImageView *P_pm;
@property (strong, nonatomic) IBOutlet UIImageView *P_tem;
@property (strong, nonatomic) IBOutlet UIImageView *P_water;

//View_middle
@property (strong, nonatomic) IBOutlet UIScrollView *SV;
@property (strong, nonatomic) IBOutlet UIImageView *Circle;

@property (strong, nonatomic) IBOutlet UIView *View1;
@property (strong, nonatomic) IBOutlet UIView *View2;
@property (strong, nonatomic) IBOutlet UIView *View3;
@property (strong, nonatomic) IBOutlet UIView *VIew4;
@property (strong, nonatomic) IBOutlet UIView *View5;


//View_1
@property (strong, nonatomic) IBOutlet UIImageView *Water1;
@property (strong, nonatomic) IBOutlet UIImageView *Water2;
@property (strong, nonatomic) IBOutlet UIImageView *Cup;
@property (strong, nonatomic) IBOutlet UIImageView *Time;
@property (strong, nonatomic) IBOutlet UIButton *Lock;
- (IBAction)B_lock:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *P_auto;

@property (strong, nonatomic) IBOutlet UIImageView *Wifi;
@property (strong, nonatomic) IBOutlet UIImageView *Fun;
@property (strong, nonatomic) IBOutlet UILabel *Pm25;
@property (strong, nonatomic) IBOutlet UIImageView *Light;
@property (strong, nonatomic) IBOutlet UIImageView *P_shajun_s;

//View_2
@property (strong, nonatomic) IBOutlet UIImageView *Water;

@property (strong, nonatomic) IBOutlet UILabel *L_w_warn;
@property (strong, nonatomic) IBOutlet UIView *View_shajun;
@property (strong, nonatomic) IBOutlet UIImageView *P_shajun;


//View_3
@property (strong, nonatomic) IBOutlet UIImageView *Fun0;
//View_4
@property (strong, nonatomic) IBOutlet UIImageView *Time0;
//View_5
@property (strong, nonatomic) IBOutlet UIImageView *Filter0;
@property (strong, nonatomic) IBOutlet UILabel *L_filter;


@property (strong, nonatomic) IBOutlet UIButton *Filter;
@property (strong, nonatomic) IBOutlet UIImageView *Page;
- (IBAction)Call_tip:(id)sender;

//View_down
- (IBAction)Open:(id)sender;
- (IBAction)Level:(id)sender;
- (IBAction)Set_time:(id)sender;
- (IBAction)Set_menu:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *B_open;
@property (strong, nonatomic) IBOutlet UIButton *B_level;
@property (strong, nonatomic) IBOutlet UIButton *B_set_time;

@property (strong, nonatomic) IBOutlet UIButton *B_set_menu;
@property (strong, nonatomic) IBOutlet UIButton *B_filter_warn;
@property (strong, nonatomic) IBOutlet UIButton *B_help;
@property (strong, nonatomic) IBOutlet UIImageView *B_page;

//View_wait
@property (strong, nonatomic) IBOutlet UIButton *B_w_open;
@property (strong, nonatomic) IBOutlet UILabel *L_open;


//View
@property (strong, nonatomic) IBOutlet UIView *View_wait;
@property (strong, nonatomic) IBOutlet UIView *View_up;
@property (strong, nonatomic) IBOutlet UIView *View_m;
@property (strong, nonatomic) IBOutlet UIView *View_middle;
@property (strong, nonatomic) IBOutlet UIView *View_down;



- (IBAction)Open0:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *L_wait;
@property (strong, nonatomic) IBOutlet UIButton *B_Open0;



-(void)setMatch:(BOOL)is;
-(void)setDevice:(DeviceEntity*)device;
    
@end
