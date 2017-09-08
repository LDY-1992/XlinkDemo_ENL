//
//  CameraReplayController.h
//  xlinkDemo
//
//  Created by kingcom on 2017/3/16.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GCDAsyncSocket.h"

@interface CameraReplayController : UIViewController<GCDAsyncSocketDelegate>
@property (strong, nonatomic)GCDAsyncSocket * clientSocket;
- (IBAction)BtnRefresh:(id)sender;
- (IBAction)BtnReplay:(id)sender;
- (IBAction)BtnTime:(id)sender;

@end

