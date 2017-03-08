//
//  RCTJMessageModule.h
//  RCTJMessage
//
//  Created by xsdlr on 2016/11/30.
//  Copyright © 2016年 xsdlr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JMessage/JMessage.h>
#import <JMessage/JMessageDelegate.h>
#import "NSJSONSerialization+JSONString.h"

#if __has_include("RCTEventEmitter.h")
#import "RCTEventEmitter.h"
#elif __has_include(<React/RCTEventEmitter.h>)  // back compatibility for RN version < 0.40
#import <React/RCTEventEmitter.h>
#else
#import "React/RCTEventEmitter.h"               // Required when used as a Pod in a Swift project
#endif

#define OPTION_NULL(value) value ? value : [NSNull null]

@interface RCTJMessageModule : RCTEventEmitter <RCTBridgeModule, JMessageDelegate>

typedef NS_ENUM(NSInteger, JMSGRNErrorCode) {
    // ------------------------ Message (1863xxx)
    /// 用户未登录
    kJMSGRNErrorSDKUserNotLogin = 1863004,
    // ------------------------ Message (1865xxx)
    /// 无效的消息内容
    kJMSGRNErrorParamContentInvalid = 1865001,
    /// 空消息
    kJMSGRNErrorParamMessageNil = 1865002,
    /// 消息不符合发送的基本条件检查
    kJMSGErrorRNMessageNotPrepared = 1865003,
    /// 收到不支持消息内容类型(目前只支持文本和图片)
    kJMSGErrorRNMessageProtocolContentTypeNotSupport = 1865100,
    /// 发送消息超时
    kJMSGRNErrorMessageTimeout = 1865101,
    // ------------------------ Conversation (1866xxx)
    /// 空会话id
    kJMSGErrorRNParamConversationIdEmpty = 1866001,
    /// 会话无效
    kJMSGErrorRNParamConversationInvalid
};

@property NSString* appKey;
@property NSString* appChannel;
@property NSString* masterSecret;

+ (void)setupJMessage:(NSDictionary *)launchOptions
     apsForProduction:(BOOL)isProduction
             category:(NSSet *)category;

@end
