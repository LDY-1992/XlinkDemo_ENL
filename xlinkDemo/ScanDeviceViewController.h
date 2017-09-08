//
//  ScanDeviceViewController.h
//  xlinkDemo
//
//  Created by xtmac on 6/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ScanDeviceViewController : UIViewController


//@property (assign, nonatomic) BOOL isCloud;

-(void)initData;
@property (strong, nonatomic) IBOutlet UIView *View_wait;

@end
