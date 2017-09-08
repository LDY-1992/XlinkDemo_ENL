//
//  HttpRequest.h
//  xlinkDemo
//
//  Created by xtmac on 12/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpRequestDelegate <NSObject>

-(void)didFinishLoadingData:(NSDictionary *)dic;

@end

@interface HttpRequest : NSObject

@property (assign, nonatomic) id<HttpRequestDelegate> delegate;
+(void)registerWithUID:(NSString *)uid withName:(NSString *)name withPWD:(NSString *)pwd withDelegate:(id)delegate;
+(void)loginWithUID:(NSString *)uid withPWd:(NSString *)pwd withDelegate:(id)delegate;
+(void)resetWithUID:(NSString *)uid withPWD:(NSString *)pwd withName:(NSString *)name withDelegate:(id)delegate;
+(void)putWithUID:(NSString *)uid withUname:(NSString *)uname withUcity:(NSString *)ucity withDelegate:(id)delegate;
+(void)put_deviceWithID:(NSString *)ID withDevice:(NSDictionary *)dic withName:(NSString *)name withDelegate:(id)delegate;
+(void)getWithTable:(NSString *)table withID:(NSString *)id withDelegate:(id)delegate;
@end
