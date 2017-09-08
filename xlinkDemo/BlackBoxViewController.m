//
//  BlackBoxViewController.m
//  xlinkDemo
//
//  Created by kingcom on 2017/7/17.
//  Copyright © 2017年 xtmac. All rights reserved.
//

#import "BlackBoxViewController.h"
#import "Z_controller.h"

@interface BlackBoxViewController ()

@end

@implementation BlackBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushZViewController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    Z_controller *Z_c = [storyBoard instantiateViewControllerWithIdentifier:@"Z_controller"];
    [self.navigationController pushViewController:Z_c animated:YES];
}

/*
 *UI更新操作
 *
*/

//更新定时
-(void)UIUpdateTime:(NSInteger )n{
    switch (n) {
        case 0:
            [_btn_time setBackgroundImage:[UIImage imageNamed:@"s9_add_time.png"] forState:UIControlStateNormal];
            break;
        case 1:
            [_btn_time setBackgroundImage:[UIImage imageNamed:@"s9_add_time1.png"] forState:UIControlStateNormal];
            break;
        case 2:
            [_btn_time setBackgroundImage:[UIImage imageNamed:@"s9_add_time2.png"] forState:UIControlStateNormal];
            break;
        case 3:
            [_btn_time setBackgroundImage:[UIImage imageNamed:@"s9_add_time4.png"] forState:UIControlStateNormal];
            break;
        case 4:
            [_btn_time setBackgroundImage:[UIImage imageNamed:@"s9_add_time8.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

//更新童锁
-(void)UIUpdateLock:(NSInteger )n{
    if(n==1){
        [_btn_lock setBackgroundImage:[UIImage imageNamed:@"s9_add_lockon.png"] forState:UIControlStateNormal];
    }else{
        [_btn_lock setBackgroundImage:[UIImage imageNamed:@"s9_add_lockoff.png"] forState:UIControlStateNormal];
    }
}

//更新WIFI
-(void)UIUpdateWifi:(NSInteger )n{
    if(n==1){
        [_btn_wifi setBackgroundImage:[UIImage imageNamed:@"s9_add_wifion.png"] forState:UIControlStateNormal];
    }else{
        [_btn_wifi setBackgroundImage:[UIImage imageNamed:@"s9_add_wifioff.png"] forState:UIControlStateNormal];
    }
}

//更新pm2.5值
-(void)UIUpdatePm:(NSInteger )n{
    if(n>=0 && n<=9){
        [self UIUpdatePm1:0];
        [self UIUpdatePm2:0];
        [self UIUpdatePm3:n];
    }else if (n>=10 && n<=99){
        NSInteger n2=n/10;
        NSInteger n3=n%10;
        [self UIUpdatePm1:0];
        [self UIUpdatePm2:n2];
        [self UIUpdatePm3:n3];
    }else if (n>=100 && n<=999){
        NSInteger n1=n/100;
        NSInteger n2=(n-n1*100)/10;
        NSInteger n3=n-n1*100-n2*10;
        [self UIUpdatePm1:n1];
        [self UIUpdatePm2:n2];
        [self UIUpdatePm3:n3];
    }
}

-(void)UIUpdatePm1:(NSInteger )n{
    switch (n) {
        case 0:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num0.png"]];
            break;
        case 1:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num1.png"]];
            break;
        case 2:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num2.png"]];
            break;
        case 3:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num3.png"]];
            break;
        case 4:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num4.png"]];
            break;
        case 5:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num5.png"]];
            break;
        case 6:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num6.png"]];
            break;
        case 7:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num7.png"]];
            break;
        case 8:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num8.png"]];
            break;
        case 9:
            [_image_pm1 setImage:[UIImage imageNamed:@"bb_num9.png"]];
            break;
        default:
            break;
    }
}

-(void)UIUpdatePm2:(NSInteger )n{
    switch (n) {
        case 0:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num0.png"]];
            break;
        case 1:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num1.png"]];
            break;
        case 2:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num2.png"]];
            break;
        case 3:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num3.png"]];
            break;
        case 4:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num4.png"]];
            break;
        case 5:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num5.png"]];
            break;
        case 6:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num6.png"]];
            break;
        case 7:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num7.png"]];
            break;
        case 8:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num8.png"]];
            break;
        case 9:
            [_image_pm2 setImage:[UIImage imageNamed:@"bb_num9.png"]];
            break;
        default:
            break;
    }
}

-(void)UIUpdatePm3:(NSInteger )n{
    switch (n) {
        case 0:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num0.png"]];
            break;
        case 1:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num1.png"]];
            break;
        case 2:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num2.png"]];
            break;
        case 3:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num3.png"]];
            break;
        case 4:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num4.png"]];
            break;
        case 5:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num5.png"]];
            break;
        case 6:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num6.png"]];
            break;
        case 7:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num7.png"]];
            break;
        case 8:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num8.png"]];
            break;
        case 9:
            [_image_pm3 setImage:[UIImage imageNamed:@"bb_num9.png"]];
            break;
        default:
            break;
    }
}

//更新co2值
-(void)UIUpdateCo:(NSInteger)n{
    if(n>=0 && n<=9){
        [self UIUpdateCo1:0];
        [self UIUpdateCo2:0];
        [self UIUpdateCo3:0];
        [self UIUpdateCo4:n];
    }else if (n>=10 && n<=99){
        NSInteger n1=n/10;
        NSInteger n2=n%10;
        [self UIUpdateCo1:0];
        [self UIUpdateCo2:0];
        [self UIUpdateCo3:n1];
        [self UIUpdateCo4:n2];
    }else if (n>=100 && n<=999){
        NSInteger n1=n/100;
        NSInteger n2=(n-n1*100)/10;
        NSInteger n3=n-n1*100-n2*10;
        [self UIUpdateCo1:0];
        [self UIUpdateCo2:n1];
        [self UIUpdateCo3:n2];
        [self UIUpdateCo4:n3];
    }else if (n>=1000 && n<=9999){
        NSInteger n1=n/1000;
        NSInteger n2=(n-n1*1000)/100;
        NSInteger n3=(n-n1*1000-n2*100)/10;
        NSInteger n4=n-n1*1000-n2*100-n3*10;
        [self UIUpdateCo1:n1];
        [self UIUpdateCo2:n2];
        [self UIUpdateCo3:n3];
        [self UIUpdateCo4:n4];
    }
}

-(void)UIUpdateCo1:(NSInteger)n{
    switch (n) {
        case 0:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num0.png"]];
            break;
        case 1:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num1.png"]];
            break;
        case 2:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num2.png"]];
            break;
        case 3:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num3.png"]];
            break;
        case 4:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num4.png"]];
            break;
        case 5:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num5.png"]];
            break;
        case 6:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num6.png"]];
            break;
        case 7:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num7.png"]];
            break;
        case 8:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num8.png"]];
            break;
        case 9:
            [_image_co1 setImage:[UIImage imageNamed:@"bb_num9.png"]];
            break;
        default:
            break;
    }
}

-(void)UIUpdateCo2:(NSInteger)n{
    switch (n) {
        case 0:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num0.png"]];
            break;
        case 1:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num1.png"]];
            break;
        case 2:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num2.png"]];
            break;
        case 3:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num3.png"]];
            break;
        case 4:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num4.png"]];
            break;
        case 5:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num5.png"]];
            break;
        case 6:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num6.png"]];
            break;
        case 7:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num7.png"]];
            break;
        case 8:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num8.png"]];
            break;
        case 9:
            [_image_co2 setImage:[UIImage imageNamed:@"bb_num9.png"]];
            break;
        default:
            break;
    }
}

-(void)UIUpdateCo3:(NSInteger)n{
    switch (n) {
        case 0:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num0.png"]];
            break;
        case 1:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num1.png"]];
            break;
        case 2:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num2.png"]];
            break;
        case 3:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num3.png"]];
            break;
        case 4:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num4.png"]];
            break;
        case 5:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num5.png"]];
            break;
        case 6:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num6.png"]];
            break;
        case 7:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num7.png"]];
            break;
        case 8:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num8.png"]];
            break;
        case 9:
            [_image_co3 setImage:[UIImage imageNamed:@"bb_num9.png"]];
            break;
        default:
            break;
    }
}

-(void)UIUpdateCo4:(NSInteger)n{
    switch (n) {
        case 0:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num0.png"]];
            break;
        case 1:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num1.png"]];
            break;
        case 2:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num2.png"]];
            break;
        case 3:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num3.png"]];
            break;
        case 4:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num4.png"]];
            break;
        case 5:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num5.png"]];
            break;
        case 6:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num6.png"]];
            break;
        case 7:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num7.png"]];
            break;
        case 8:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num8.png"]];
            break;
        case 9:
            [_image_co4 setImage:[UIImage imageNamed:@"bb_num9.png"]];
            break;
        default:
            break;
    }
}

- (IBAction)BA_home:(id)sender {
}

- (IBAction)BA_time:(id)sender {
}

- (IBAction)BA_lock:(id)sender {
}

- (IBAction)BA_menu:(id)sender {
}
- (IBAction)BA_close:(id)sender {
}

- (IBAction)BA_fun:(id)sender {
}

- (IBAction)BA_rtsp:(id)sender {
    [self pushZViewController];
}

- (IBAction)BA_sd:(id)sender {
}
@end
