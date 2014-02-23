//
//  SHTestModal.h
//  SHModalObject
//
//  Created by SHAN UL HAQ on 23/2/14.
//  Copyright (c) 2014 grevolution. All rights reserved.
//

#import "SHModalObject.h"

@interface SHTestModal : SHModalObject

{
    NSString *_anotherStringValue;
    NSNumber  *_intValue;
    NSInteger _integerValue;
    NSNumber *_numberValue;
    BOOL _remember;
    NSString *_doItMySelf;
    
    NSMutableArray *_myArray;
    NSMutableDictionary *_myDictionary;
}

@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic) int anotherIntValue;
@property (nonatomic) NSInteger anotherIntegerValue;
@property (nonatomic, strong) NSNumber *anotherNumberValue;

@end
