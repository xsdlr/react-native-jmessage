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
               appKey:(NSString *)appKey
              channel:(NSString *)channel
     apsForProduction:(BOOL)isProduction
             category:(NSSet *)category {
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

RCT_EXPORT_METHOD(login:(NSString *)username
                  :(NSString *)password
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [JMSGUser loginWithUsername:username password:password completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            resolve(resultObject);
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
             @"serverMessageId": message.serverMessageId,
             @"fromType": message.fromType,
             @"fromName": OPTION_NULL(message.fromName),
             @"timestamp": message.timestamp,
             @"targetType": [self toStringWithConversationType:message.targetType],
             @"contentType": [self toStringWithContentType:message.contentType],
             @"content": [self toDictoryWithJsonString:[message.content toJsonString]]
             };
}
@end
