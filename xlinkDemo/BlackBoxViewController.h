//
//  BlackBoxViewController.h
//  xlinkDemo
//
//  Created by kingcom on 2017/7/17.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlackBoxViewController : UIViewController

//UI
@property (strong, nonatomic) IBOutlet UIButton *btn_time;
@property (strong, nonatomic) IBOutlet UIButton *btn_lock;
@property (strong, nonatomic) IBOutlet UIButton *btn_wifi;


- (IBAction)BA_home:(id)sender;
- (IBAction)BA_time:(id)sender;
- (IBAction)BA_lock:(id)sender;
- (IBAction)BA_menu:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *image_pm1;
@property (strong, nonatomic) IBOutlet UIImageView *image_pm2;
@property (strong, nonatomic) IBOutlet UIImageView *image_pm3;

@property (strong, nonatomic) IBOutlet UIImageView *image_co1;
@property (strong, nonatomic) IBOutlet UIImageView *image_co2;
@property (strong, nonatomic) IBOutlet UIImageView *image_co3;
@property (strong, nonatomic) IBOutlet UIImageView *image_co4;

@property (strong, nonatomic) IBOutlet UIImageView *image_fun;
@property (strong, nonatomic) IBOutlet UIImageView *image_filter;

- (IBAction)BA_close:(id)sender;
- (IBAction)BA_fun:(id)sender;
- (IBAction)BA_rtsp:(id)sender;
- (IBAction)BA_sd:(id)sender;

@end
