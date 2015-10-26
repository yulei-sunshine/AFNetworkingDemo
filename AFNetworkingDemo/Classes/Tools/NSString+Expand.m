//
//  NSString+Expand.m
//  AFNetworkingDemo
//
//  Created by yulei on 15/4/27.
//  Copyright (c) 2015年 yulei. All rights reserved.
//

#import "NSString+Expand.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Expand)

//计算字体size
- (CGSize)sizeWithFont:(UIFont *)font WithMaxSize:(CGSize)maxSize ByLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize size = CGSizeZero;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    NSMutableParagraphStyle *paragraphStype = [[NSMutableParagraphStyle alloc] init];
    [paragraphStype setLineBreakMode:lineBreakMode];
    
    NSDictionary *contentDict = @{NSFontAttributeName : font,
                                  NSParagraphStyleAttributeName : paragraphStype};
    size = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:contentDict context:nil].size;
#else
    size = [self sizeWithFont:font constrainedToSize:maxSize lineBreakMode:lineBreakMode];
#endif
    
    return size;
}

//判断字符串是否相等
+ (BOOL)isEqualWithFromString:(NSString *)fromString
                 WithToString:(NSString *)toString
{
    if(fromString == nil && toString == nil) {
        return YES;
    }
    
    if(fromString == NULL && toString == NULL) {
        return YES;
    }
    
    if([fromString isKindOfClass:[NSNull class]] && [toString isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    return [fromString isEqualToString:toString];
}

//md5
- (NSString *)MD5Hash
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *mStr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++)
    {
        [mStr appendFormat:@"%02X",result[i]];
    }
    return mStr;
}

@end
