//
//  NSObject+KVC.m
//  RCTJMessage
//
//  Created by xsdlr on 2016/11/30.
//  Copyright © 2016年 xsdlr. All rights reserved.
//

#import "NSObject+KVC.h"
#import <objc/runtime.h>

@implementation NSObject (KVC)

+ (NSArray *)allKeys
{
    u_int count;
    
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        [propertyArray addObject:@(propertyName)];
    }
    
    free(properties);
    
    return [NSArray arrayWithArray:propertyArray];
}

- (id)propertyValueForKey:(NSString *)key
{
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    
    if (!property) {
        return [NSNull null];
    }
    
    const char *type = property_getAttributes(property);
    NSArray *attributes = [@(type) componentsSeparatedByString:@","];
    
    if (!attributes) {
        return [NSNull null];
    }
    
    NSString *typeAttribute = attributes[0];
    NSString *propertyType = [typeAttribute substringWithRange:NSMakeRange(1, 1)];
    
    if ([propertyType isEqualToString:@(@encode(BOOL))]) {
        BOOL boolValue = [[self valueForKey:key] boolValue];
        return [NSNumber numberWithBool:boolValue];
    } else {
        return [self valueForKey:key];
    }
}

- (NSDictionary *)dictionaryWithPropertyValuesForKeys:(NSArray *)keys
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    for (NSString *key in keys) {
        id value = [self propertyValueForKey:key];
        dictionary[key] = value;
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
