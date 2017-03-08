//
//  RCTJMessageModule.m
//  RCTJMessage
//
//  Created by xsdlr on 2016/11/30.
//  Copyright © 2016年 xsdlr. All rights reserved.
//

#import "RCTJMessageModule.h"
#import <JMessage/JMSGTextContent.h>
#import <JMessage/JMSGImageContent.h>

@interface RCTJMessageModule () {
@private
    NSMutableDictionary *_sendMessageIdDic;
}
@end

@implementation RCTJMessageModule

RCT_EXPORT_MODULE()

- (instancetype)init
{
    self = [super init];
    _sendMessageIdDic = [@{} mutableCopy];
    if (self) {
        self.appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JiguangAppKey"];
        self.masterSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JiguangMasterSecret"];
        self.appChannel = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JiguangAppChannel"];
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[
             @"onReceiveMessage",
             @"onReceiveMessageDownloadFailed"
             ];
}

+ (void)setupJMessage:(NSDictionary *)launchOptions
     apsForProduction:(BOOL)isProduction
             category:(NSSet *)category {
    NSString *appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JiguangAppKey"];
    NSString *appChannel = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JiguangAppChannel"];
    [JMessage setupJMessage:launchOptions
                     appKey:appKey
                    channel:appChannel
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
        RCTPromiseResolveBlock resolve = [_sendMessageIdDic objectForKey:message.msgId];
        if (resolve) {
            resolve([self toDictoryWithMessage:message]);
            [_sendMessageIdDic removeObjectForKey:message.msgId];
        }
    }
}

- (void)onReceiveNotificationEvent:(JMSGNotificationEvent *)event {
    switch (event.eventType) {
        case kJMSGEventNotificationNoDisturbChange:
            NSLog(@"Current user info change Event ");
            break;
        case kJMSGEventNotificationReceiveFriendInvitation:
            NSLog(@"Receive Friend Invitation Event ");
            break;
        case kJMSGEventNotificationAcceptedFriendInvitation:
            NSLog(@"Accepted Friend Invitation Event ");
            break;
        case kJMSGEventNotificationDeclinedFriendInvitation:
            NSLog(@"Declined Friend Invitation Event ");
            break;
        case kJMSGEventNotificationDeletedFriend:
            NSLog(@"Deleted Friend Event ");
            break;
        case kJMSGEventNotificationReceiveServerFriendUpdate:
            NSLog(@"Receive Server Friend Update Event ");
            break;
        case kJMSGEventNotificationLoginKicked:
            NSLog(@"Login Kicked Event ");
            break;
        case kJMSGEventNotificationServerAlterPassword:
            NSLog(@"Server Alter Password Event ");
            break;
        case kJMSGEventNotificationUserLoginStatusUnexpected:
            NSLog(@"User login status unexpected Event ");
            break;
        default:
            NSLog(@"Other Notification Event ");
            break;
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
/**
 MARK: 是否已经登陆
 
 */
RCT_EXPORT_METHOD(isLoggedIn
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    resolve([[JMSGUser myInfo] username] ? @YES : @NO);
}
/**
 MARK: 登陆

 @param username 用户名
 @param password 密码
 */
RCT_EXPORT_METHOD(login:(NSString *)username
                  :(NSString *)password
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [JMSGUser loginWithUsername:username password:password completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            [self myInfo:resolve :reject];
        } else {
            reject([@(error.code) stringValue], error.localizedDescription, error);
        }
    }];
}
/**
 MARK: 注销
 
 */
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
/**
 MARK: 获得个人用户信息
 
*/
RCT_EXPORT_METHOD(myInfo
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    JMSGUser *user = [JMSGUser myInfo];
    if (!user.username) {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGRNErrorSDKUserNotLogin
                                                userInfo:@{NSLocalizedDescriptionKey: @"用户未登录"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
        return;
    }
    resolve(@{@"username": OPTION_NULL(user.username),
              @"nickname": OPTION_NULL(user.nickname),
              @"avatar": OPTION_NULL(user.avatar),
              @"gender": @(user.gender),
              @"genderDesc": [self toStringWithUserGender:user.gender],
              @"birthday": OPTION_NULL(user.birthday),
              @"region": OPTION_NULL(user.region),
              @"signature": OPTION_NULL(user.signature),
              @"noteName": OPTION_NULL(user.noteName),
              @"noteText": OPTION_NULL(user.noteText)
              });
}
/**
 MARK: 发送单聊消息

 @param username 用户名
 @param type     类型(目前只支持text,image)
 @param data     数据
 
 * data范例：
 * text为{text: ''}
 * image为{image: ''}
 */
RCT_EXPORT_METHOD(sendSingleMessage
                  :(NSString*)appkey
                  :(NSString*)username
                  :(NSString*)type
                  :(NSDictionary*)data
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if(!username || !type || !data) {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorRNMessageNotPrepared
                                                userInfo:@{NSLocalizedDescriptionKey: @"消息参数错误"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
        return;
    }
    [self sendMessageWithUserNameOrGID:appkey
                                  name:username
                              isSingle:YES
                           contentType:type
                                  data:data
                               timeout:0
                               resolve:resolve
                                reject:reject];
}
/**
 MARK: 发送群聊消息
 
 @param groupId  群id
 @param type     类型(目前只支持text,image)
 @param data     数据
 
 * data范例：
 * text为{text: ''}
 * image为{image: ''}
 */
RCT_EXPORT_METHOD(sendGroupMessage
                  :(NSString*)groupId
                  :(NSString*)type
                  :(NSDictionary*)data
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if(!groupId || !type || !data) {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorRNMessageNotPrepared
                                                userInfo:@{NSLocalizedDescriptionKey: @"消息参数错误"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
        return;
    }
    [self sendMessageWithUserNameOrGID:nil
                                  name:groupId
                              isSingle:NO
                           contentType:type
                                  data:data
                               timeout:0
                               resolve:resolve
                                reject:reject];
}
/**
 MARK: 根据会话id发送消息
 
 @param cid      会话id
 @param type     类型(目前只支持text,image)
 @param data     数据
 
 * data范例：
 * text为{text: ''}
 * image为{image: ''}
 */
RCT_EXPORT_METHOD(sendMessageByCID
                  :(NSString*)cid
                  :(NSString*)type
                  :(NSDictionary*)data
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if(!type || !data) {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorRNMessageNotPrepared
                                                userInfo:@{NSLocalizedDescriptionKey: @"消息参数错误"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
        return;
    }
    if(!cid) {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorRNParamConversationIdEmpty
                                                userInfo:@{NSLocalizedDescriptionKey: @"空会话id"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
        return;
    }
    [self detectConversationValidById:cid completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            reject([@(error.code) stringValue], error.localizedDescription, error);
            return;
        }
        JMSGConversation *conversation = resultObject;
        NSString *username;
        BOOL isSingle;
        switch (conversation.conversationType) {
            case kJMSGConversationTypeSingle:
                username = ((JMSGUser*) conversation.target).username;
                isSingle = YES;
                break;
            case kJMSGConversationTypeGroup:
                username = ((JMSGGroup*) conversation.target).gid;
                isSingle = NO;
                break;
        }
        [self sendMessageWithUserNameOrGID:nil
                                      name:username
                                  isSingle:isSingle
                               contentType:type
                                      data:data
                                   timeout:0
                                   resolve:resolve
                                    reject:reject];
    }];
}
/**
 MARK: 全部会话列表
 
 */
RCT_EXPORT_METHOD(allConversations
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [JMSGConversation allConversations:^(id resultObject, NSError *error) {
        if (error) {
            reject([@(error.code) stringValue], error.localizedDescription, error);
            return;
        }
        NSArray<JMSGConversation*> *conversations = resultObject;
        NSMutableArray *result = [NSMutableArray array];
        if (conversations.count == 0) {
            resolve(result);
            return;
        }
        for (JMSGConversation *conversation in conversations) {
            NSString *typeDesc = [self toStringWithConversationType:conversation.conversationType];
            [conversation avatarData:^(NSData *data, NSString *objectId, NSError *error) {
                if (!error) {
                    NSString *username, *groupId, *cid;
                    switch (conversation.conversationType) {
                        case kJMSGConversationTypeSingle:
                        {
                            JMSGUser *userInfo = conversation.target;
                            username = userInfo.username;
                            NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                                                                                     @"appkey": OPTION_NULL(conversation.targetAppKey),
                                                                                     @"type": @(conversation.conversationType),
                                                                                     @"id": username
                                                                                     }
                                                                           options:NSJSONWritingPrettyPrinted
                                                                             error:nil];
                            cid = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                        }
                            break;
                        case kJMSGConversationTypeGroup:
                        {
                            JMSGGroup *groupInfo = conversation.target;
                            groupId = groupInfo.gid;
                            NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                                                                                     @"appkey": OPTION_NULL(conversation.targetAppKey),
                                                                                     @"type": @(conversation.conversationType),
                                                                                     @"id": groupId
                                                                                     }
                                                                           options:NSJSONWritingPrettyPrinted
                                                                             error:nil];
                            cid = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                        }
                            break;
                        default:
                            break;
                    }
                    
                    [result addObject:@{@"id": OPTION_NULL(cid),
                                        @"type": @(conversation.conversationType),
                                        @"typeDesc": typeDesc,
                                        @"username": OPTION_NULL(username),
                                        @"groupId": OPTION_NULL(groupId),
                                        @"title": OPTION_NULL(conversation.title),
                                        @"laseMessage": OPTION_NULL(conversation.latestMessageContentText),
                                        @"unreadCount": OPTION_NULL(conversation.unreadCount),
                                        @"avatar": data ? [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] : [NSNull null],
                                        @"timestamp": conversation.latestMessage ? conversation.latestMessage.timestamp : [NSNull null]
                                        }];
                    if(result.count == conversations.count) {
                        resolve(result);
                        return;
                    }
                }
            }];
        }
    }];
}
/**
 MARK: 历史聊天消息
 
 @param cid      会话id
 @param offset   偏移量
 @param limit    数量
 
 * 参数举例：
 *
 * - offset = nil, limit = nil，表示获取全部。相当于 allMessages。
 * - offset = nil, limit = 100，表示从最新开始取 100 条记录。
 * - offset = 100, limit = nil，表示从最新第 100 条开始，获取余下所有记录。
 */
RCT_EXPORT_METHOD(historyMessages
                  :(NSString*)cid
                  :(NSNumber*__nonnull)offset
                  :(NSNumber*__nonnull)limit
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    NSNumber* _limit = limit <= 0 ? nil : limit;
    if(!cid) {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorRNParamConversationIdEmpty
                                                userInfo:@{NSLocalizedDescriptionKey: @"空会话id"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
        return;
    }
    [self detectConversationValidById:cid completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            reject([@(error.code) stringValue], error.localizedDescription, error);
            return;
        }
        JMSGConversation *conversation = resultObject;
        NSMutableArray<NSDictionary*> *result = @[].mutableCopy;
        for (JMSGMessage *message in [conversation messageArrayFromNewestWithOffset:offset limit:_limit]) {
            [result addObject:[self toDictoryWithMessage:message]];
        }
        resolve(result);
    }];
}
/**
 MARK: 清除未读记录

 @param cid 会话id
 */
RCT_EXPORT_METHOD(clearUnreadCount
                  :(NSString*)cid
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if(!cid) {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorRNParamConversationIdEmpty
                                                userInfo:@{NSLocalizedDescriptionKey: @"空会话id"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
        return;
    }
    [self detectConversationValidById:cid completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            reject([@(error.code) stringValue], error.localizedDescription, error);
            return;
        }
        JMSGConversation *conversation = resultObject;
        NSNumber *unreadCount = conversation.unreadCount;
        [conversation clearUnreadCount];
        resolve(unreadCount);
    }];
}
/**
 MARK: 移除会话记录
 
 @param cid 会话id
 */
RCT_EXPORT_METHOD(removeConversation
                  :(NSString*)cid
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if(!cid) {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorRNParamConversationIdEmpty
                                                userInfo:@{NSLocalizedDescriptionKey: @"空会话id"
                                                           }];
        reject([@(error.code) stringValue], error.localizedDescription, error);
        return;
    }
    [self detectConversationValidById:cid completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            reject([@(error.code) stringValue], error.localizedDescription, error);
            return;
        }
        JMSGConversation *conversation = resultObject;
        switch (conversation.conversationType) {
            case kJMSGConversationTypeSingle:
                {
                    JMSGUser *userInfo = conversation.target;
                    [JMSGConversation deleteSingleConversationWithUsername:userInfo.username];
                }
                break;
            case kJMSGConversationTypeGroup:
                {
                    JMSGGroup *groupInfo = conversation.target;
                    [JMSGConversation deleteGroupConversationWithGroupId:groupInfo.gid];
                }
                break;
            default:
                break;
        }
        resolve(nil);
    }];
}
//MARK: 私有方法
- (NSString *) toStringWithUserGender:(JMSGUserGender) gender {
    switch (gender) {
        case kJMSGUserGenderUnknown:
            return @"Unknown";
        case kJMSGUserGenderMale:
            return @"Male";
        case kJMSGUserGenderFemale:
            return @"Female";
        default:
            return [NSNull null];
    }
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
             @"serverMessageId": OPTION_NULL(message.serverMessageId),
             @"from": @{@"type": OPTION_NULL(message.fromType),
                        @"name":OPTION_NULL(message.fromUser.username),
                        @"nickname": OPTION_NULL(message.fromUser.nickname),
                        @"avatar": OPTION_NULL(message.fromUser.avatar),
                        },
             @"target": [self getTargetWithMessage:message],
             @"timestamp": message.timestamp,
             @"contentType": @(message.contentType),
             @"contentTypeDesc": [self toStringWithContentType:message.contentType],
             @"content": OPTION_NULL([message.content toJsonString])
             };
}

- (NSDictionary*) getTargetWithMessage:(JMSGMessage *)message {
    NSString *typeDesc = [self toStringWithConversationType:message.targetType];
    if (message.targetType == kJMSGConversationTypeSingle) {
        JMSGUser *target = message.target;
        return @{@"type": @(message.targetType),
                 @"typeDesc": typeDesc,
                 @"name": OPTION_NULL(target.username),
                 @"nickname": OPTION_NULL(target.nickname),
                 @"avatar": OPTION_NULL(target.avatar),
                 };
    } else if(message.targetType == kJMSGConversationTypeGroup) {
        JMSGGroup *target = message.target;
        return @{@"type": @(message.targetType),
                 @"typeDesc": typeDesc,
                 @"name": OPTION_NULL(target.name),
                 @"displayName": OPTION_NULL(target.displayName)
                 };
    } else {
        return @{};
    }
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
- (void) sendMessageWithUserNameOrGID:(NSString*)appkey
                                 name:(NSString*)name
                             isSingle:(BOOL)isSingle
                          contentType:(NSString*)type
                                 data:(NSDictionary*)data
                              timeout:(NSTimeInterval)timeout
                              resolve:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject {
    if ([type caseInsensitiveCompare:@"Text"] == NSOrderedSame) {
        NSString *text = [data valueForKey:@"text"];
        if (!text) {
            NSError *error = [[NSError alloc] initWithDomain:@""
                                                        code:kJMSGRNErrorParamMessageNil
                                                    userInfo:@{NSLocalizedDescriptionKey: @"空消息内容"
                                                               }];
            reject([@(error.code) stringValue], error.localizedDescription, error);
            return;
        }
        [self createConversationWithAppKey:appkey
                                isSingle:isSingle
                               nameOrGID:name
                       completionHandler:^(id resultObject, NSError *error) {
            if (!error) {
                JMSGConversation *conversation = resultObject;
                JMSGMessage *message = [conversation createMessageWithContent:[[JMSGTextContent alloc] initWithText:text]];
                [self nativeSendMessageWithConversation:conversation
                                                message:message
                                                timeout:timeout
                                                resolve:resolve
                                                 reject:reject];
            } else {
                reject([@(error.code) stringValue], error.localizedDescription, error);
            }
        }];
    } else if ([type caseInsensitiveCompare:@"Image"] == NSOrderedSame) {
        NSString *imageURL = [data valueForKey:@"image"];
        NSData *imageData = [NSData dataWithContentsOfFile:imageURL];
        if (!imageData) {
            NSError *error = [[NSError alloc] initWithDomain:@""
                                                        code:kJMSGRNErrorParamMessageNil
                                                    userInfo:@{NSLocalizedDescriptionKey: @"图片地址错误"
                                                               }];
            reject([@(error.code) stringValue], error.localizedDescription, error);
            return;
        }
        [self createConversationWithAppKey:appkey
                                isSingle:isSingle
                               nameOrGID:name
                       completionHandler:^(id resultObject, NSError *error) {
            if (!error) {
                JMSGConversation *conversation = resultObject;
                [conversation createMessageAsyncWithImageContent:[[JMSGImageContent alloc] initWithImageData:imageData]
                                               completionHandler:^(id resultObject, NSError *error) {
                    JMSGMessage *message = resultObject;
                    [self nativeSendMessageWithConversation:conversation
                                                    message:message
                                                    timeout:timeout
                                                    resolve:resolve
                                                     reject:reject];
                }];
            } else {
                reject([@(error.code) stringValue], error.localizedDescription, error);
            }
        }];
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@""
                                                    code:kJMSGErrorRNMessageProtocolContentTypeNotSupport
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
- (void) createConversationWithAppKey:(NSString*)appkey
                           isSingle:(BOOL)isSingle
                          nameOrGID:(NSString*)name
                  completionHandler:(JMSGCompletionHandler JMSG_NULLABLE)handler {
    if (isSingle) {
        if(appkey) {
            [JMSGConversation createSingleConversationWithUsername:name appKey:appkey completionHandler:handler];
        } else {
            [JMSGConversation createSingleConversationWithUsername:name completionHandler:handler];
        }
    } else {
        [JMSGConversation createGroupConversationWithGroupId:name completionHandler:handler];
    }
}

/**
 native发送消息

 @param conversation 会话
 @param message 消息
 @param timeout 发送超时时间
 @param resolve 成功回调
 @param reject 失败回调
 */
- (void) nativeSendMessageWithConversation:(JMSGConversation*)conversation
                                   message:(JMSGMessage*)message
                                   timeout:(NSTimeInterval)timeout
                              resolve:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject {
    NSString *msgId = message.msgId;
    [_sendMessageIdDic setValue:resolve forKey:msgId];
    [conversation sendMessage:message];
    if (timeout <= 0) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        if ([_sendMessageIdDic valueForKey:msgId]) {
            [_sendMessageIdDic removeObjectForKey:msgId];
            NSError *error = [[NSError alloc] initWithDomain:@""
                                                        code:kJMSGRNErrorMessageTimeout
                                                    userInfo:@{NSLocalizedDescriptionKey: @"发送消息超时"
                                                               }];
            reject([@(error.code) stringValue], error.localizedDescription, error);
        }
    });
}

/**
 检测会话有效性

 @param cid 会话id
 @param completionHandler 回调
 */
- (void) detectConversationValidById:(NSString*)cid
                        completionHandler:(JMSGCompletionHandler JMSG_NULLABLE)handler {
    NSError *conversationInvalidError = [[NSError alloc] initWithDomain:@""
                                                code:kJMSGErrorRNParamConversationInvalid
                                            userInfo:@{NSLocalizedDescriptionKey: @"会话无效"
                                                       }];
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:cid options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSString *appkey = [dataDic valueForKey:@"appkey"];
    NSNumber *type = [dataDic valueForKey:@"type"];
    NSString *nameOrGID = [dataDic valueForKey:@"id"];
    
    if (!nameOrGID) {
        handler(nil, conversationInvalidError);
        return;
    }
    BOOL isSingle;
    switch ([type integerValue]) {
        case kJMSGConversationTypeSingle:
            isSingle = YES;
            break;
        case kJMSGConversationTypeGroup:
            isSingle = NO;
            break;
        default:
            handler(nil, conversationInvalidError);
            return;
    }
    [self createConversationWithAppKey:appkey
                            isSingle:isSingle
                           nameOrGID:nameOrGID
                   completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            JMSGConversation *conversation = resultObject;
            handler(conversation, nil);
        } else {
            handler(nil, conversationInvalidError);
        }
    }];
}
@end
