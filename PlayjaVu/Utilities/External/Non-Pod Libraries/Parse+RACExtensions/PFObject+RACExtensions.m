//
//  PFObject+RACExtensions.m
//  Parse-RACExtensions
//
//  Created by Dave Lee on 2013-06-28.
//  Copyright (c) 2013 Dave Lee. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PFObject+RACExtensions.h"
#import "PFRACCallbacks.h"

@implementation PFObject (RACExtensions)

+ (RACSignal *)rac_saveAll:(NSArray *)objects {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self saveAllInBackground:objects block:PFRACBooleanCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"+rac_saveAll: %@", objects];
}

+ (RACSignal *)rac_fetchAll:(NSArray *)objects {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self fetchAllInBackground:objects block:PFRACObjectCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"+rac_fetchAll: %@", objects];
}

+ (RACSignal *)rac_fetchAllIfNeeded:(NSArray *)objects {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self fetchAllIfNeededInBackground:objects block:PFRACObjectCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"+rac_fetchAllIfNeeded: %@", objects];
}

+ (RACSignal *)rac_deleteAll:(NSArray *)objects {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self deleteAllInBackground:objects block:PFRACBooleanCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"+rac_deleteAll: %@", objects];
}

- (RACSignal *)rac_save {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self saveInBackgroundWithBlock:PFRACBooleanCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"%@ -rac_save", self];
}

- (RACSignal *)rac_saveEventually {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self saveEventually:PFRACBooleanCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"%@ -rac_saveEventually", self];
}

- (RACSignal *)rac_refresh {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self fetchInBackgroundWithBlock:PFRACObjectCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"%@ -rac_refresh", self];
}

- (RACSignal *)rac_fetch {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self fetchInBackgroundWithBlock:PFRACObjectCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"%@ -rac_fetch", self];
}

- (RACSignal *)rac_fetchIfNeeded {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self fetchIfNeededInBackgroundWithBlock:PFRACObjectCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"%@ -rac_fetchIfNeeded", self];
}

- (RACSignal *)rac_delete {
	return [[RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
		[self deleteInBackgroundWithBlock:PFRACBooleanCallback(subscriber)];
		return nil;
	}]
	setNameWithFormat:@"%@ -rac_delete", self];
}

@end
