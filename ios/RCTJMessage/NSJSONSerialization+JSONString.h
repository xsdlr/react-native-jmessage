//
//  NSJSONSerialization+JSONString.h
//  RCTJMessage
//
//  Created by xsdlr on 2017/3/6.
//  Copyright © 2017年 xsdlr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (JSONString)
+ (NSString*) stringWithJSONObject:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **) error;
@end
