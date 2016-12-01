//
//  NSObject+KVC.h
//  RCTJMessage
//
//  Created by xsdlr on 2016/11/30.
//  Copyright © 2016年 xsdlr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KVC)

+ (NSArray *)allKeys;

- (id)propertyValueForKey:(NSString *)key;

- (NSDictionary *)dictionaryWithPropertyValuesForKeys:(NSArray *)keys;

@end
