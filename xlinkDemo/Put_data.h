//
//  NSObject+Put_data.h
//  xlinkDemo
//
//  Created by kingcom on 15/12/25.
//  Copyright © 2015年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpRequestDelegate_put <NSObject>

-(void)didFinishLoadingData_put:(NSDictionary *)dic;

@end

@interface HttpRequest_put : NSObject

@property (assign, nonatomic) id<HttpRequestDelegate_put> delegate;
+(void)putWithUID:(NSString *)uid withID:(NSString *)ID withUname:(NSString *)uname withUcity:(NSString *)ucity withDelegate:(id)delegate;
+(void)put_deviceWithID:(NSString *)ID withDevice:(NSDictionary *)dic withName:(NSString *)name withDelegate:(id)delegate;
@end
