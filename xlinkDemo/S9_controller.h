//
//  S9_controller.h
//  xlinkDemo
//
//  Created by kingcom on 16/9/26.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceEntity;

@interface S9_controller : UIViewController <UIGestureRecognizerDelegate>
-(void)setDevice:(DeviceEntity*)device;
-(void)setMatch:(BOOL)is;


//view_close
- (IBAction)BA_open:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *View_close;

//view1
@property (strong, nonatomic) IBOutlet UILabel *Lab_top_name;
@property (strong, nonatomic) IBOutlet UIView *View_l;//tab
@property (strong, nonatomic) IBOutlet UIView *View_r;
//view2
@property (strong, nonatomic) IBOutlet UIImageView *Ima_time;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_lock;//tab
@property (strong, nonatomic) IBOutlet UIImageView *Ima_wifi;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_menu;//tab

//view3
@property (strong, nonatomic) IBOutlet UIImageView *Ima_fun;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_num1;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_num2;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_num3;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_filter;//tab
@property (strong, nonatomic) IBOutlet UILabel *Lab_filter;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_filter_warn;
//view4
@property (strong, nonatomic) IBOutlet UIView *View_light;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_white;//tab
@property (strong, nonatomic) IBOutlet UIImageView *Ima_yellow;//tab
@property (strong, nonatomic) IBOutlet UIImageView *Ima_red;//tab
@property (strong, nonatomic) IBOutlet UIImageView *Ima_blue;//tab
@property (strong, nonatomic) IBOutlet UIImageView *Ima_pink;//tab
@property (strong, nonatomic) IBOutlet UIImageView *Ima_color;//tab
@property (strong, nonatomic) IBOutlet UIImageView *Ima_main_color;//tab
@property (strong, nonatomic) IBOutlet UIImageView *Ima_pick;
@property (strong, nonatomic) IBOutlet UILabel *Lab_light;
@property (strong, nonatomic) IBOutlet UISlider *Sli_light;

//view5
- (IBAction)BA_close:(id)sender;
- (IBAction)BA_fun:(id)sender;
- (IBAction)BA_time:(id)sender;
- (IBAction)BA_light:(id)sender;
//view_add
@property (strong, nonatomic) IBOutlet UIView *View_add;
@property (strong, nonatomic) IBOutlet UIView *View_add_return;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c1;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c2;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c3;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c4;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c5;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c6;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c7;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c8;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c9;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c10;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c11;
@property (strong, nonatomic) IBOutlet UIImageView *Ima_add_c12;

@end
