//
//  UIColor+CJCategory.h
//  UTOUU
//
//  Created by CJ-MacPro on 15-1-27.
//  Copyright (c) 2015年 chenjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CJCategory)

+ (UIColor *)fromHexValue:(NSUInteger)hex;
+ (UIColor *)fromHexValue:(NSUInteger)hex alpha:(CGFloat)alpha;

+ (UIColor *)fromShortHexValue:(NSUInteger)hex;
+ (UIColor *)fromShortHexValue:(NSUInteger)hex alpha:(CGFloat)alpha;

+ (UIColor *)colorWithString:(NSString *)string;

@end
