//
//  PFFile+RACExtensions.m
//  PlayjaVu
//
//  Created by Kerry Knight on 2/16/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PFRACCallbacks.h"
#import "PFFile+RACExtensions.h"

@implementation PFFile (RACExtensions)

- (RACSignal *)rac_save {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self saveInBackgroundWithBlock:PFRACBooleanCallback(subscriber)];
		return nil;
	}]
            setNameWithFormat:@"%@ -rac_save", self];
}

@end
