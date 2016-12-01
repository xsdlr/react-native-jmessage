//
//  RCTJPushModule.h
//  RCTJMessage
//
//  Created by xsdlr on 2016/11/30.
//  Copyright © 2016年 xsdlr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import <JMessage/JPUSHService.h>

#define kJPFDidReceiveRemoteNotification  @"kJPFDidReceiveRemoteNotification"


@interface RCTJPushModule : NSObject <RCTBridgeModule>
@property(strong,nonatomic)RCTResponseSenderBlock asyCallback;

- (void)didRegistRemoteNotification:(NSString *)token;
@end
