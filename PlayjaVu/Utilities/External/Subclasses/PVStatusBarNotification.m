//
//  PVStatusBarNotification.m
//  PlayjaVu
//
//  Created by Kerry Knight on 2/9/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVStatusBarNotification.h"

@implementation PVStatusBarNotification

NSString *const PVStatusBarSuccess = @"PVStatusBarSuccess";
NSString *const PVStatusBarError = @"PVStatusBarError";

#pragma mark - Life Cyle and Private Customization
+ (PVStatusBarNotification *)sharedInstance {
    static dispatch_once_t once;
    static PVStatusBarNotification *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[PVStatusBarNotification alloc] init];
        [self addCustomStyles];
    });
    return sharedInstance;
}

+ (void)addCustomStyles {
    //custom success style
    [JDStatusBarNotification addStyleNamed:PVStatusBarSuccess
                                   prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
                                       style.barColor = kLtGreen;
                                       style.textColor = [UIColor whiteColor];
                                       return style;
                                   }];
    
    //custom error style
    [JDStatusBarNotification addStyleNamed:PVStatusBarError
                                   prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
                                       style.barColor = kErrorRed;
                                       style.textColor = [UIColor whiteColor];
                                       return style;
                                   }];
}

#pragma mark - Public Methods
+ (void)showWithStatus:(NSString *)status customStyleName:(NSString *)styleName {
    return [[self sharedInstance] sharedInstanceShowWithStatus:status customStyleName:styleName];
}

+ (void)showWithStatus:(NSString *)status dismissAfter:(NSTimeInterval)timeInterval customStyleName:(NSString *)styleName {
    return [[self sharedInstance] sharedInstanceShowWithStatus:status dismissAfter:timeInterval customStyleName:styleName];
}

#pragma mark - Private Methods
- (void)sharedInstanceShowWithStatus:(NSString *)status customStyleName:(NSString *)styleName {
    [JDStatusBarNotification showWithStatus:status styleName:styleName];
}

- (void)sharedInstanceShowWithStatus:(NSString *)status dismissAfter:(NSTimeInterval)timeInterval customStyleName:(NSString *)styleName {
    [JDStatusBarNotification showWithStatus:status dismissAfter:timeInterval styleName:styleName];
}

@end
