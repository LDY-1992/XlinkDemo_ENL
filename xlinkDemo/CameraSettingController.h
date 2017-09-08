//
//  CameraSettingController.h
//  xlinkDemo
//
//  Created by kingcom on 2017/3/16.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface CameraSettingController : UIViewController

@property (strong, nonatomic) IBOutlet UISwitch *Switch_resolution;
@property (strong, nonatomic) IBOutlet UISwitch *Switch_Audio;
@property (strong, nonatomic) IBOutlet UISlider *Slider_Audio;

- (IBAction)Action_Switch_Resolution:(id)sender;
- (IBAction)Action_Switch_Audio:(id)sender;
- (IBAction)Action_Btn_Buffer:(id)sender;
- (IBAction)Action_Btn_Clean_Buffer:(id)sender;

@end
