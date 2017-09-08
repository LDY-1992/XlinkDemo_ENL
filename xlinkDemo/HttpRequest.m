//
//  HttpRequest.m
//  xlinkDemo
//
//  Created by xtmac on 12/3/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "HttpRequest.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>


#define url_register_str @"http://app.xlink.cn/v1/user/register"
#define url_login_str    @"http://app.xlink.cn/v1/user/login"
#define url_set_str      @"http://app.xlink.cn/v1/user/reset"

#define url_put_str      @"http://app.xlink.cn/v1/bucket/put"
#define url_get_str      @"http://app.xlink.cn/v1/bucket/get"
//访问accessID，权限
//#define accesskeyId @"c53eb8609824490e857428c3b2d95fb6"
#define accesskeyId @"02a3dfea31ba47c2a7e5ca4b7b26c499"
//secretKey
//#define secretKey @"2a5315aabc2e4a0ba5e2641abaad59fd"
#define secretKey @"64734934c1484f93aeafd268c8b9846e"


static HttpRequest *_httpRequest = nil;

@interface HttpRequest ()<NSURLConnectionDataDelegate>

@end

@implementation HttpRequest{
    NSMutableData *_httpReceiveData;
}

+(HttpRequest*)share{
    if (!_httpRequest) {
        _httpRequest = [[HttpRequest alloc] init];
    }
    return _httpRequest;
}

-(id)init{
    if (self = [super init]) {
        _httpReceiveData = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)httpRequestWithURL:(NSString *)urlStr withBodyStr:(NSString *)bodyStr{

    NSURL *url = [NSURL URLWithString:urlStr];

    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];


    //访问的accessID
    NSString *accessID = [NSString stringWithFormat:@"%@",accesskeyId];

    //X-ContentMD5

    NSString *md5Body= [[[HttpRequest share] md5:bodyStr] uppercaseString];

    //X-Sign
    NSString *xsign=[NSString stringWithFormat:@"%@%@",secretKey,md5Body];
    NSString *md5Xsin = [[[HttpRequest share] md5:xsign] uppercaseString];

#pragma mark 注意要设置的属性
    //3.设置自定义字段
    [request addValue:md5Body forHTTPHeaderField:@"X-ContentMD5"];
    [request addValue:accessID forHTTPHeaderField:@"X-AccessId"];
    [request addValue:md5Xsin forHTTPHeaderField:@"X-Sign"];

    NSLog(@"field dict %@",[request allHTTPHeaderFields]);
    
    [request setHTTPMethod:@"POST"];
    
    //bodyBytes
    NSData *bodyBytes = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyBytes];
    [request setValue:@"text/plain" forHTTPHeaderField:@"content-type"];
    
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
//    [connection release];
//    [request release];
}

+(void)registerWithUID:(NSString *)uid withName:(NSString *)name withPWD:(NSString *)pwd withDelegate:(id)delegate{
    if (!uid.length ) {
        return;
    }
    [HttpRequest share].delegate = delegate;
    NSString * bodyStr = [[NSString alloc]initWithFormat:@"{\"uid\":\"%@\",\"pwd\":\"%@\"}",uid,pwd];
    [[HttpRequest share] httpRequestWithURL:url_register_str withBodyStr:bodyStr];

}

+(void)loginWithUID:(NSString *)uid withPWd:(NSString *)pwd withDelegate:(id)delegate{
    if (!uid.length ) {
        return;
    }
    [HttpRequest share].delegate = delegate;
    NSString * bodyStr = [[NSString alloc]initWithFormat:@"{\"uid\":\"%@\",\"pwd\":\"%@\"}",uid,pwd];
    [[HttpRequest share] httpRequestWithURL:url_login_str withBodyStr:bodyStr];

}

+(void)resetWithUID:(NSString *)uid withPWD:(NSString *)pwd withName:(NSString *)name withDelegate:(id)delegate{
    if (!uid.length) {
        return;
    }
    [HttpRequest share].delegate = delegate;
    NSString *bodyStr = [NSString stringWithFormat:@"{\"uid\":\"%@\",\"pwd\":\"%@\",\"name\":\"%@\"}",uid,pwd,name];
    [[HttpRequest share] httpRequestWithURL:url_set_str withBodyStr:bodyStr];
    
}

+(void)putWithUID:(NSString *)uid withUname:(NSString *)uname withUcity:(NSString *)ucity withDelegate:(id)delegate{
    if (!uid.length) {
        return;
    }
    [HttpRequest share].delegate = delegate;
    NSString *bodyStr = [NSString stringWithFormat:@"{\"table\":\"uaer_message\", \"overwrite\":true,\"id\":\"%@\",\"data\":{\"uid\":\"%@\",\"uname\":\"%@\",\"ucity\":\"%@\"}}",uid,uid,uname,ucity];
    //NSLog(@"data=%@",bodyStr);
    [[HttpRequest share] httpRequestWithURL:url_put_str withBodyStr:bodyStr];
}
+(void)put_deviceWithID:(NSString *)ID withDevice:(NSDictionary *)dic withName:(NSString *)name withDelegate:(id)delegate{
    if (!dic) {
        return;
    }
    
    [HttpRequest share].delegate = delegate;
    NSString *bodyStr = [NSString stringWithFormat:@"{\"table\":\"dev_list\", \"overwrite\":true,\"id\":\"%@\",\"data\":%@",ID,dic];
    NSLog(@"bodyStr=%@",bodyStr);
    [[HttpRequest share] httpRequestWithURL:url_put_str withBodyStr:bodyStr];
}
+(void)getWithTable:(NSString *)table withID:(NSString *)id withDelegate:(id)delegate{
    if (!table.length) {
        return;
    }
    [HttpRequest share].delegate = delegate;
    NSString *bodyStr = [NSString stringWithFormat:@"{\"table\":\"%@\",\"id\":\"%@\"}",table,id];
    NSLog(@"data=%@",bodyStr);
    [[HttpRequest share] httpRequestWithURL:url_get_str withBodyStr:bodyStr];
}

//md5运算
-(NSString *) md5:(NSString *) input
{
    
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
    
}

-(void)printByteData:(NSData *)data{
    
    char temp[data.length];
    [data getBytes:temp range:NSMakeRange(0, data.length)];
    
    /*
    for (int i=0; i<data.length; i++) {
        NSLog(@"%d ->%02x",i,temp[i]);
    }
     */
}

-(void)showWarningAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];

}

#pragma mark
#pragma mark NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _httpReceiveData.length = 0;;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    if (_httpReceiveData ) {
        [_httpReceiveData appendData:data];
    }
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    
    if (_httpReceiveData.length) {
        [self printByteData:_httpReceiveData];
        // NSString * str = [NSString stringWithUTF8String:_httpReceiveData.bytes];
        
        NSError *err = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_httpReceiveData options:NSJSONReadingMutableLeaves error:&err];
        
        NSLog(@"length ==%lu",(unsigned long)_httpReceiveData.length);
        if (!err) {
            if (dic) {
                if ([_delegate respondsToSelector:@selector(didFinishLoadingData:)]) {
                    [_delegate didFinishLoadingData:dic];
                }
                //[[dic objectForKey:@"status"]intValue];
//                switch ([[dic objectForKey:@"status"]intValue]) {
//                    case 200:
//                    {
//                        NSLog(@"获取成功");
//                        
//                    }
//                        break;
//                        
//                    case 400:
//                    {
//                        NSLog(@"请求参数或者格式不对");
//                    }
//                        break;
//                    case 401:
//                    {
//                        NSLog(@"没有相关权限");
//                    }
//                        break;
//                    case 500:
//                    {
//                        NSLog(@"内部数据出现成错误");
//                    }
//                        break;
//                    case 201:{
//                        NSLog(@"201");
//                        NSLog(@"用户已经存");
//                    }
//                        break;
//                    case 403:
//                    {
//                        NSLog(@"被禁止");
//                    }
//                        break;
//                    default:
//                        break;
//                }
                
                
            }
        }else{
            NSLog(@"%@",[err localizedDescription]);
        }
        
    }
    
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"error happened = %@",[error localizedDescription]);
    
}

@end
