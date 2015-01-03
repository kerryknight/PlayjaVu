//
//  JVFloatLabeledTextField+LabelText.m
//  PlayjaVu
//
//  Created by Kerry Knight on 2/8/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "JVFloatLabeledTextField+LabelText.h"

@implementation JVFloatLabeledTextField (LabelText)

- (void)pv_setFloatingLabelText:(NSString *)text {
    if (![self.floatingLabel respondsToSelector:@selector(setText:)]) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:@"HACK OVERWRITTEN: You've overwritten the JVFloatLabeledTextField pod; manually reset the floatingLabel property to readwrite to get this working again."
                                     userInfo:nil];
    }
    
    self.floatingLabel.text = text;
    [self.floatingLabel sizeToFit];
}

@end
