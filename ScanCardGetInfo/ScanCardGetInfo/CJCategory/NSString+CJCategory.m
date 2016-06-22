//
//  NSString+CJCategory.m
//  UTOUU
//
//  Created by CJ-MacPro on 14-12-29.
//  Copyright (c) 2014年 chenjie. All rights reserved.
//

#import "NSString+CJCategory.h"

@implementation NSString (CJCategory)

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isEqualToStringLgnoreCase:(NSString *)string {
    return [[self lowercaseString] isEqualToString:[string lowercaseString]];
}

- (BOOL)isEmpty {
    return [self length] > 0 ? NO : YES;
}

@end
