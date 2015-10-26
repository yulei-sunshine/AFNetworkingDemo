//
//  NSString+Expand.h
//  AFNetworkingDemo
//  功能描述 - NSString扩展
//  Created by yulei on 15/4/27.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Expand)

//计算字体size
- (CGSize)sizeWithFont:(UIFont *)font WithMaxSize:(CGSize)maxSize ByLineBreakMode:(NSLineBreakMode)lineBreakMode;

//判断字符串是否相等
+ (BOOL)isEqualWithFromString:(NSString *)fromString
                 WithToString:(NSString *)toString;

//md5
- (NSString *)MD5Hash;

@end
