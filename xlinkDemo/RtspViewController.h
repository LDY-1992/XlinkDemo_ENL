//
//  RtspViewController.h
//  xlinkDemo
//
//  Created by kingcom on 2017/3/31.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import<MobileVLCKit/MobileVLCKit.h>

@interface RtspViewController : UIViewController

@property (nonatomic, strong)VLCMediaPlayer *player;
@property (strong, nonatomic) IBOutlet UIView *ShowView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *Indicator;

@end
