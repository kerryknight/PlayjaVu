//
//  PVUtility.m
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "PVUtility.h"
#import "PFRACErrors.h"

@interface PVUtility ()
@end

@implementation PVUtility

#pragma mark - Public Methods
+ (PVUtility *)sharedUtility {
    static PVUtility * _sharedUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUtility = [[PVUtility alloc] init];
    });
    
    return _sharedUtility;
}

- (void)configureParseWithLaunchOptions:(NSDictionary *)options
{
    // START 3RD PARTY INSTANTIATIONS ********************************************************
    
    // do everything we possibly can in the background like a good citizen
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Parse stuff that can be done on background queue
        
        // NOT SURE IF I SHOULD KEEP THESE ON OR NOT AS THEY
        // MAY ONLY WORK IF USING A CUSTOM PARSE UI VIEW/VC
        [Parse errorMessagesEnabled:YES];
        [Parse offlineMessagesEnabled:YES];
        
        // enable logging
        [Parse setLogLevel:PFLogLevelDebug];
        
//#warning BE SURE TO TURN THE RUN SCRIPT BACK ON TOO FOR SYMBOL UPLOAD
//        // Enable crash reporting on Parse
//        [ParseCrashReporting enable];
//        
//        // enable Parse local sqlite data store
//        [Parse enableLocalDatastore];
        
        // initialize everything
        [Parse setApplicationId:kParseApplicationID clientKey:kParseApplicationClientKey];
        [PFFacebookUtils initializeFacebook];
        
        //Configure Parse default setup
        PFACL *defaultACL = [PFACL ACL];
        // If you would like all objects to be private by default, remove this line.
        [defaultACL setPublicReadAccess:YES];
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
        
        // analytics
        [PFAnalytics trackAppOpenedWithLaunchOptionsInBackground:options block:nil];
    });
    
    // END 3RD PARTY
    // INSTANTIATIONS **********************************************************
}

# pragma mark Date Manipulation
- (NSDate *)dateFromJSONString:(NSString *)dateString
{
    return [[self dateFormatter] dateFromString:dateString];
}

#pragma mark Error Handling
- (NSError *)normalizeRACError:(NSError *)error
{
    if (error == nil)
        return [NSError errorWithDomain:PFRACErrorDomain code:PFRACUnknownError userInfo:nil];
    
    if (error.userInfo[@"error"] == nil)
        return error;
    
    NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
    userInfo[NSLocalizedDescriptionKey] = userInfo[@"error"];
    
    return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
}

#pragma mark - Private Methods
# pragma mark Date Manipulation
- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"]; // facebook's format 
    }
    return formatter;
}

@end
