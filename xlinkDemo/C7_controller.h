//
//  C7_controller.h
//  xlinkDemo
//
//  Created by kingcom on 16/5/13.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceEntity;

@interface C7_controller : UIViewController
-(void)setDevice:(DeviceEntity*)device;
-(void)setMatch:(BOOL)is;

//all_view
@property (strong, nonatomic) IBOutlet UIView *view_1;
@property (strong, nonatomic) IBOutlet UIView *view_2;

@property (strong, nonatomic) IBOutlet UIView *view_3;
@property (strong, nonatomic) IBOutlet UIView *view_4;

//view1
@property (strong, nonatomic) IBOutlet UIButton *B_left_arrow;
@property (strong, nonatomic) IBOutlet UIButton *B_right_arrow;

@property (strong, nonatomic) IBOutlet UILabel *L_name;
@property (strong, nonatomic) IBOutlet UIButton *B_power;

- (IBAction)BA_power:(id)sender;
- (IBAction)BA_right_arrow:(id)sender;
- (IBAction)BA_left_arrow:(id)sender;


//view2
@property (strong, nonatomic) IBOutlet UIImageView *P_ug;
@property (strong, nonatomic) IBOutlet UIImageView *P_filter;
@property (strong, nonatomic) IBOutlet UIImageView *P_b1;
@property (strong, nonatomic) IBOutlet UIImageView *P_b2;
@property (strong, nonatomic) IBOutlet UIImageView *P_b3;
@property (strong, nonatomic) IBOutlet UIImageView *P_pm;
@property (strong, nonatomic) IBOutlet UIImageView *P_wifi;
@property (strong, nonatomic) IBOutlet UILabel *L_filter;
@property (strong, nonatomic) IBOutlet UIImageView *P_filter_change;

@property (strong, nonatomic) IBOutlet UIImageView *P_fug;
@property (strong, nonatomic) IBOutlet UIButton *B_lock;
- (IBAction)BA_lock:(id)sender;

//view3
@property (strong, nonatomic) IBOutlet UIImageView *P_bar1;
@property (strong, nonatomic) IBOutlet UIImageView *P_bar2;
@property (strong, nonatomic) IBOutlet UIImageView *P_bar3;
@property (strong, nonatomic) IBOutlet UIImageView *P_mode4;
@property (strong, nonatomic) IBOutlet UIImageView *P_mode3;
@property (strong, nonatomic) IBOutlet UIImageView *P_mode2;
@property (strong, nonatomic) IBOutlet UIImageView *P_mode1;
@property (strong, nonatomic) IBOutlet UIImageView *P_fun3;
@property (strong, nonatomic) IBOutlet UIImageView *P_time3;
@property (strong, nonatomic) IBOutlet UIImageView *P_time4;
@property (strong, nonatomic) IBOutlet UIImageView *P_fun4;
@property (strong, nonatomic) IBOutlet UIImageView *P_fun2;
@property (strong, nonatomic) IBOutlet UIImageView *P_fun1;
@property (strong, nonatomic) IBOutlet UIImageView *P_time2;
@property (strong, nonatomic) IBOutlet UIImageView *P_time1;
@property (strong, nonatomic) IBOutlet UIImageView *P_light;

@property (strong, nonatomic) IBOutlet UIButton *B_mode;
@property (strong, nonatomic) IBOutlet UIButton *B_fun;
@property (strong, nonatomic) IBOutlet UIButton *B_time;
@property (strong, nonatomic) IBOutlet UIButton *B_light;
- (IBAction)BA_mode:(id)sender;
- (IBAction)BA_fun:(id)sender;
- (IBAction)BA_time:(id)sender;
- (IBAction)BA_light:(id)sender;

//view4
@property (strong, nonatomic) IBOutlet UIButton *B_open;
- (IBAction)BA_open:(id)sender;



@end
