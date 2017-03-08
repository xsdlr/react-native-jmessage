//
//  NSJSONSerialization+JSONString.m
//  RCTJMessage
//
//  Created by xsdlr on 2017/3/6.
//  Copyright © 2017年 xsdlr. All rights reserved.
//

#import "NSJSONSerialization+JSONString.h"

@implementation NSJSONSerialization (JSONString)
+ (NSString *)stringWithJSONObject:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError *__autoreleasing *)error {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:opt error:error];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
