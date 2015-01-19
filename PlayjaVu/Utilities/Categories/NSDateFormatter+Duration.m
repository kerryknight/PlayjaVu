//
//  NSDateFormatter+Duration.h
//  
//
//  Created by Kerry Knight on 1/19/15.
//
//

#import "NSDateFormatter+Duration.h"

@implementation NSDateFormatter (Duration)

+ (NSString *)formattedDuration:(long)duration
{
    NSString *prefix = @"";
    if (duration < 0)
        prefix = @"-";
    
    duration = abs((int)duration);
    
    NSMutableArray *comps = [NSMutableArray new];
    
    while (duration > 59){
        [comps addObject:[NSString stringWithFormat:@"%ld", duration / 60]];
        duration = duration % 60;
    }
    
    // Minute indicator needs to be there at all times.
    if (comps.count == 0)
        [comps addObject:@"0"];
    
    [comps addObject:[NSString stringWithFormat:@"%02ld", duration]];
    
    return [prefix stringByAppendingString:[comps componentsJoinedByString:@":"]];
}

@end