//
//  PVMacros.h
//
//  Created by Kerry Knight on 1/23/14.
//

#define PVAD ((PVAppDelegate *)[UIApplication sharedApplication].delegate)

// Device detection
#define IS_IPAD             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA           ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH        ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT       ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH   (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH   (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5         (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6         (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P        (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

// IOS version detection
#define IOS_VERSION_EQUAL_TO(v)					([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_VERSION_GREATER_THAN(v)				([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_VERSION_LESS_THAN(v)				([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


// Latitude & Longitude to miles (approximation)
#define LAT_TO_MILES(l)	(l / 69.1f)
#define LON_TO_MILES(l)	(l / 53.0f)

// colors
#define kLtGray     [UIColor colorWithRed:51/255.0f green:63/255.0f blue:77/255.0f alpha:1.0]
#define kMedGray    [UIColor colorWithRed:45/255.0f green:57/255.0f blue:69/255.0f alpha:1.0]
#define kDrkGray    [UIColor colorWithRed:31/255.0f green:44/255.0f blue:53/255.0f alpha:1.0]
#define kLtWhite    [UIColor colorWithRed:243/255.0f green:246/255.0f blue:253/255.0f alpha:1.0]
#define kMedWhite   [UIColor colorWithRed:231/255.0f green:234/255.0f blue:243/255.0f alpha:1.0]
#define kLtGreen    [UIColor colorWithRed:116/255.0f green:192/255.0f blue:166/255.0f alpha:1.0]
#define kMedGreen   [UIColor colorWithRed:73/255.0f green:156/255.0f blue:128/255.0f alpha:1.0]
#define kDrkGreen   [UIColor colorWithRed:34/255.0f green:101/255.0f blue:78/255.0f alpha:1.0]
#define kFBBlue     [UIColor colorWithRed:61/255.0f green:94/255.0f blue:150/255.0f alpha:1.0]
#define kErrorRed   [UIColor colorWithRed:186/255.0f green:42/255.0f blue:42/255.0f alpha:1.000]

//font
#define kHelveticaLight      @"HelveticaNeue-Light"
#define kHelveticaMedium     @"HelveticaNeue-Medium"
#define kHelveticaBold       @"HelveticaNeue-Bold"

//welcome/login/signup/forgot password view formatting
#define kWelcomButtonHeight         50
#define kWelcomeButtonWidth         270
#define kWelcomeTextFieldMargin     15

// Facebook permissions
#define kFacebookPermissionsList @[@"user_about_me", @"email"]


// xcodecolors xcode plugin logger
#ifdef DEBUG
#ifdef XCODE_COLORS
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//colors require XcodeColors plugin installed on local machine //https://github.com/robbiehanson/XcodeColors
#define XCODE_COLORS_ESCAPE @"\033["
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

#define DLogBlue(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg23,148,205; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogGreen(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,255,0; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogRed(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg255,0,0; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogOrange(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg255,127,0; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogPurple(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg123,48,105; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogYellow(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg255,255,0; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogCyan(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,255,255; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define DLogError(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg255,0,0; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogWarning(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg255,127,0; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogSuccess(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,255,0; %s [Line %d] " frmt XCODE_COLORS_RESET), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogBlue(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogGreen(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogRed(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogOrange(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogPurple(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogYellow(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogCyan(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogError(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogWarning(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLogSuccess(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif
#else
#define DLog(...);
#define DLogBlue(...);
#define DLogGreen(...);
#define DLogRed(...);
#define DLogOrange(...);
#define DLogPurple(...);
#define DLogYellow(...);
#define DLogCyan(...);
#define DLogError(...);
#define DLogWarning(...);
#define DLogSuccess(...);
#endif
