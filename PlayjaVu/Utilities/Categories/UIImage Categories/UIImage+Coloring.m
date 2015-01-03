//
//  UIImage+Coloring.m
//  PlayjaVu
//
//  Created by Kerry Knight on 3/4/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "UIImage+Coloring.h"

@implementation UIImage (Coloring)


+ (UIImage *)imageWithColor:(UIColor *)color {
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
