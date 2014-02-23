//
//  SHTestModal.m
//  SHModalObject
//
//  Created by SHAN UL HAQ on 23/2/14.
//  Copyright (c) 2014 grevolution. All rights reserved.
//

#import "SHTestModal.h"

@implementation SHTestModal

- (void)serializeValue:(id)value withKey:(id)key
{
    if([key isEqualToString:@"numberVALUE"]) {
        _numberValue = value;
        NSLog(@"did it for _numberValue : %@", _numberValue);
    } else {
        [super serializeValue:value withKey:key];
    }
}

@end