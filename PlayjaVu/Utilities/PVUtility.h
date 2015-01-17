//
//  PVUtility.h
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

@interface PVUtility : NSObject

+ (PVUtility *)sharedUtility;

// configures Parse and Parse-related services at app launch
- (void)configureParseWithLaunchOptions:(NSDictionary *)options;

// Date Manipulation
- (NSDate *)dateFromJSONString:(NSString *)dateString;

// Error Handling
- (NSError *)normalizeRACError:(NSError *)error;
@end
