//
//  RCTJMessageModule.m
//  RCTJMessage
//
//  Created by xsdlr on 2016/11/30.
//  Copyright © 2016年 xsdlr. All rights reserved.
//

#import "RCTJMessageModule.h"

@implementation RCTJMessageModule

RCT_EXPORT_MODULE()

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JiguangAppKey"];
        self.masterSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JiguangMasterSecret"];
    }
    return self;
}


- (NSArray<NSString *> *)supportedEvents {
    return @[
             @"onSendMessage",
             @"onReceiveMessage",
             @"onReceiveMessageDownloadFailed"
             ];
}

+ (void)setupJMessage:(NSDictionary *)launchOptions
              channel:(NSString *)channel
     apsForProduction:(BOOL)isProduction
             category:(NSSet *)category {
    NSString *appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JiguangAppKey"];
    [JMessage setupJMessage:launchOptions
                     appKey:appKey
                    channel:channel
           apsForProduction:isProduction
                   category:category];
}

- (void)startObserving {
    [JMessage addDelegate:self withConversation:nil];
}

- (void)stopObserving {
    [JMessage removeDelegate:self withConversation:nil];
}

- (NSDictionary<NSString *,id> *)constantsToExport {
    return @{@"AppKey": self.appKey,
             @"MasterSecret": self.masterSecret
             };
}
//MARK: 通知相关
- (void)onSendMessageResponse:(JMSGMessage *)message error:(NSError *)error {
    if (!error) {
        [self sendEventWithName:@"onSendMessage"
                           body:[self toDictoryWithMessage:message]];
    }
}

- (void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error {
    if (!error) {
        [self sendEventWithName:@"onReceiveMessage"
                           body:[self toDictoryWithMessage:message]];
    }
}

- (void)onReceiveMessageDownloadFailed:(JMSGMessage *)message {
    [self sendEventWithName:@"onReceiveMessageDownloadFailed"
                       body: [self toDictoryWithMessage:message]];
}
//MARK: 公开方法
RCT_EXPORT_METHOD(register:(NSString *)username
                  :(NSString *)password
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [JMSGUser registerWithUsername:username password:password completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            resolve(resultObject);
        } else {
            reject([@(error.code) stringValue], error.localizedDescription, error);
        }
    }];
}

RCT_EXPORT_METHOD(login:(NSString *)username
                  :(NSString *)password
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [JMSGUser loginWithUsername:username password:password completionHandler:^(id resultObject, NSError *error) {
        if (!error || error.code == kJMSGErrorSDKUserInvalidState) {
            JMSGUser *user = [JMSGUser myInfo];
            resolve(@{@"username": OPTION_NULL(user.username),
                      @"nickname": OPTION_NULL(user.nickname),
                      @"avatar": OPTION_NULL(user.avatar),
                      @"gender": @(user.gender),
                      @"birthday": OPTION_NULL(user.birthday),
                      @"region": OPTION_NULL(user.region),
                      @"signature": OPTION_NULL(user.signature),
                      @"noteName": OPTION_NULL(user.noteName),
                      @"noteText": OPTION_NULL(user.noteText)
                      });
        } else {
            reject([@(error.code) stringValue], error.localizedDescription, error);
        }
    }];
}

RCT_EXPORT_METHOD(logout
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [JMSGUser logout:^(id resultObject, NSError *error) {
        if (!error) {
            resolve(resultObject);
        } else {
            reject([@(error.code) stringValue], error.localizedDescription, error);
        }
    }];
}

RCT_EXPORT_METHOD(sendSingleMessage
                  :(NSString*)username
                  :(NSString*)type
                  :(NSDictionary*)data
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if(!username || !type || !data) {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorSDKMessageNotPrepared
                                                userInfo:@{NSLocalizedDescriptionKey: @"消息参数错误"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
        return;
    }
    [self sendMessageWithUserNameOrGID:username
                              isSingle:@YES
                           contentType:type
                                  data:data
                               resolve:resolve
                                reject:reject];
}


//MARK: 私有方法
- (NSString *) toStringWithConversationType:(JMSGConversationType) type {
    switch (type) {
        case kJMSGConversationTypeSingle:
            return @"Single";
        case kJMSGConversationTypeGroup:
            return @"Group";
        default:
            return [NSNull null];
    }
}

- (NSString *) toStringWithContentType:(JMSGContentType) type {
    switch (type) {
        case kJMSGContentTypeUnknown:
            return @"Unknown";
        case kJMSGContentTypeText:
            return @"Text";
        case kJMSGContentTypeImage:
            return @"Image";
        case kJMSGContentTypeVoice:
            return @"Voice";
        case kJMSGContentTypeCustom:
            return @"Custom";
        case kJMSGContentTypeEventNotification:
            return @"Event";
        case kJMSGContentTypeFile:
            return @"File";
        case kJMSGContentTypeLocation:
            return @"Location";
        default:
            return [NSNull null];
    }
}

- (NSDictionary *)toDictoryWithJsonString:(NSString *)json {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (NSDictionary *)toDictoryWithMessage:(JMSGMessage *)message {
    return @{@"msgId": message.msgId,
             @"serverMessageId": OPTION_NULL(message.serverMessageId),
             @"fromType": OPTION_NULL(message.fromType),
             @"fromName": OPTION_NULL(message.fromName),
             @"timestamp": message.timestamp,
             @"targetType": [self toStringWithConversationType:message.targetType],
             @"contentType": [self toStringWithContentType:message.contentType],
             @"content": [self toDictoryWithJsonString:[message.content toJsonString]]
             };
}

/**
 发送聊天消息

 @param name 对方用户名（群号）
 @param isSingle 是否为单聊
 @param contentType 内容类型
 @param data 消息数据
 @param resolve 成功回调
 @param reject 失败回调
 */
- (void) sendMessageWithUserNameOrGID:(NSString *)name
                             isSingle:(BOOL)isSingle
                          contentType:(NSString*)type
                                 data:(NSDictionary*)data
                              resolve:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject {
    if ([type caseInsensitiveCompare:@"Text"] == NSOrderedSame) {
        NSString *content = [data valueForKey:@"text"];
        if (!content) {
            NSError *error = [[NSError alloc] initWithDomain:@""
                                                        code:kJMSGErrorSDKParamMessageNil
                                                    userInfo:@{NSLocalizedDescriptionKey: @"空消息内容"
                                                               }];
            reject([@(error.code) stringValue], error.localizedDescription, error);
            return;
        }
        [self createConversationIsSingle:isSingle nameOrGID:name completionHandler:^(id resultObject, NSError *error) {
            if (!error) {
                JMSGConversation *conversation = resultObject;
                [conversation sendTextMessage:content];
                resolve(nil);
            } else {
                reject([@(error.code) stringValue], error.localizedDescription, error);
            }
        }];
    } else if ([type caseInsensitiveCompare:@"Image"] == NSOrderedSame) {
        NSString *imageURL = [data valueForKey:@"image"];
        NSLog(@"%@", imageURL);
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorSDKMessageProtocolContentTypeNotSupport
                                                userInfo:@{NSLocalizedDescriptionKey: @"暂时不支持文字与图片之外的消息类型"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
    }
}

/**
 创建聊天会话

 @param isSingle 是否为单聊
 @param name 对方用户名（群号）
 @param handler 回调
 */
- (void) createConversationIsSingle:(BOOL)isSingle
                          nameOrGID:(NSString*)name
                  completionHandler:(JMSGCompletionHandler JMSG_NULLABLE)handler {
    if (isSingle) {
        [JMSGConversation createSingleConversationWithUsername:name completionHandler:handler];
    } else {
        [JMSGConversation createGroupConversationWithGroupId:name completionHandler:handler];
    }
}
@end
