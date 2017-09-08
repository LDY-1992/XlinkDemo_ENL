//
//  Z_controller.h
//  xlinkDemo
//
//  Created by kingcom on 2017/3/13.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "AppDelegate.h"
#import<MobileVLCKit/MobileVLCKit.h>

@interface Z_controller : UIViewController

@property (nonatomic, strong) GCDAsyncSocket    *socket;       // socket
@property (nonatomic, strong) GCDAsyncUdpSocket    *socketudp;       // socketudp
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot
@property (nonatomic, strong)VLCMediaPlayer *player;
- (IBAction)btn_play:(id)sender;
- (IBAction)btn_replay:(id)sender;
- (IBAction)btn_setting:(id)sender;


@end
