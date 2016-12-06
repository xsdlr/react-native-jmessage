//
//  RCTJMessageModule.h
//  RCTJMessage
//
//  Created by xsdlr on 2016/11/30.
//  Copyright © 2016年 xsdlr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#import <JMessage/JMessage.h>
#import <JMessage/JMessageDelegate.h>

#define OPTION_NULL(value) value ? value : [NSNull null]

@interface RCTJMessageModule : RCTEventEmitter <RCTBridgeModule, JMessageDelegate>

@property NSString* appKey;
@property NSString* masterSecret;

+ (void)setupJMessage:(NSDictionary *)launchOptions
              channel:(NSString *)channel
     apsForProduction:(BOOL)isProduction
             category:(NSSet *)category;

@end
