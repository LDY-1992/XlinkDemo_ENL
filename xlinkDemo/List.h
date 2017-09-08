//
//  ScanDeviceViewController.h
//  xlinkDemo
//
//  Created by xtmac on 6/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface List : UIViewController

-(void)initData;
-(void)isHex:(BOOL)is;
@property (strong, nonatomic) IBOutlet UITableView *table_view;
@property (strong, nonatomic) IBOutlet UIView *Con_view;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *Indi;

@end
