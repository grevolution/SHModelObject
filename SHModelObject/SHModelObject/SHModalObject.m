// SHModalSerializer.m
//
// Copyright (c) 2014 Shan Ul Haq (http://grevolution.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "SHModalObject.h"
#import <objc/runtime.h>

/**
 *  trims a given NSString
 *
 *  @param val the NSString to be trimmed
 *
 *  @return trimmed NSString
 */
#define TRIM_STRING(val) [val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]


/**
 *  checks if a NSString is valid
 *
 *  @param val a NSString to be checked
 *
 *  @return `YES` or `NO` based on the validity of the NSString
 */
#define IS_VALID_STRING(val) (val != nil) && [val length] != 0 && ([TRIM_STRING(val) length] != 0) && ![val isEqualToString:@"(null)"]

// pattern to strip from the dictionary key and ivarname for comparision
#define PATTERN_TO_STRIP @"-_ "


@implementation SHModalObject
{
    Ivar *                  _ivars;
    unsigned int            _outCount;
    kDateConversionOption   _converstionOption;
}

#pragma mark - Factory methods for object creation
//
+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary
{
    if(nil == dictionary) {
        return nil;
    }
    return [[[self class] alloc] initWithDictionary:dictionary];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary dateConversionOption:(kDateConversionOption)option
{
    return [[[self class] alloc] initWithDictionary:dictionary dateConversionOption:option];
}


//
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
{
    if((self = [super init])) {
        return [self updateWithDictionary:dictionary dateConversionOption:kDateConverstionFromNSStringToNSStringOption];
    }
    return self;
}

//
- (instancetype)initWithDictionary:(NSDictionary *)dictionary dateConversionOption:(kDateConversionOption)option;
{
    if((self = [super init])) {
        return [self updateWithDictionary:dictionary dateConversionOption:option];
    }
    return self;
}

//
- (instancetype)updateWithDictionary:(NSDictionary *)dictionary;
{
    //List of ivars
    id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
    _ivars = class_copyIvarList(class, &_outCount);
    
    //For each top-level property in the dictionary
    NSEnumerator *enumerator = [dictionary keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        id value = [dictionary objectForKey:key];
        [self serializeValue:value withKey:key];
    }
    
    free(_ivars);
    _ivars = NULL;
    
    return self;
}

//
- (instancetype)updateWithDictionary:(NSDictionary *)dictionary dateConversionOption:(kDateConversionOption)option;
{
    _converstionOption = option;
    return [self updateWithDictionary:dictionary];
}

#pragma mark - SHModalSerialization protocol methods

- (void) serializeValue:(id)value withKey:(id)key;
{
    //check for NSNull or nil for key
    if ([key isKindOfClass:[NSNull class]] || nil == key) {
        return;
    }
    
    //check for NSNull or nil for value
    if ([value isKindOfClass:[NSNull class]] || nil == value) {
        return;
    }
    
    //If it match our ivar name, then set it
    for (unsigned int i = 0; i < _outCount; i++)
    {
        Ivar ivar = _ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        NSString *ivarType = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
        
        if([self matchesPattern:key ivar:ivarName] == NO) {
            continue;
        }
        
        //it will be NSString, NSNumber, NSArray, NSDictionary or NSNull
        if([value isKindOfClass:[NSString class]]) {
            
            //converting the .NET JSON Date representation to either NSDate, NSTimeInterval or keeping it as NSString.
            //if somebody wants a different conversion, please simplye override the method and parse the value and set
            //for yourself and make sure you call [super serializeValue: key:] for all other values so that they are
            //parsed correctly.
            
            switch (_converstionOption) {
                case kDateConverstionFromNSStringToNSDateOption: {
                    if([ivarType contains:@"NSDate"]) {
                        value = (NSDate *)[self dateFromDotNetJSONString:value];
                    } else {
                        NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSDate");
                    }
                } break;
                case kDateConverstionFromNSStringToNSTimeIntervalOption: {
                    if(![ivarType contains:@"@"]) {
                        value = @([[self dateFromDotNetJSONString:value] timeIntervalSince1970]);
                    } else {
                        NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSDate");
                    }
                } break;
                case kDateConverstionFromNSStringToNSStringOption:
                default: {
                    //do nothing
                } break;
            }
            
            if(![ivarType contains:NSStringFromClass([NSString class])]) {
                NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSString");
            }
        } else if([value isKindOfClass:[NSNumber class]] && ![ivarType contains:@"NSNumber"]) {
            //special case, where NSNumber can be stored into the primitive types. just need to chceck that iVar is not
            //an object.
            if([ivarType contains:@"@"]) {
                NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSNumber");
            }
        } else if([value isKindOfClass:[NSDictionary class]]) {
            if(![ivarType contains:@"Dictionary"]) {
                NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSDictionary or NSMutableDictionary");
            }
        } else if([value isKindOfClass:[NSArray class]]) {
            if(![ivarType contains:@"Array"]) {
                NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSArray or NSMutableArray");
            }
        }
        
        [self setValue:value forKey:ivarName];
    }
}

#pragma mark - NSObject overriden methods

//
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
}

#pragma mark - SHModalSerializer helper functions

- (BOOL)matchesPattern:(NSString *)key ivar:(NSString *)ivarName {
    if(nil == key || nil == ivarName) {
        return NO;
    }
    
    if((!IS_VALID_STRING(key)) || (!IS_VALID_STRING(ivarName))) {
        return NO;
    }

    NSMutableString *prettyKey = [NSMutableString stringWithCapacity:key.length];
    NSMutableString *prettyIvar = [NSMutableString stringWithCapacity:ivarName.length];

    NSScanner *scannerForKey = [NSScanner scannerWithString:key];
    NSScanner *scannerForIvar = [NSScanner scannerWithString:ivarName];
    
    scannerForKey.caseSensitive = NO;
    scannerForIvar.caseSensitive = NO;
    
    NSCharacterSet *stripChars = [[NSCharacterSet characterSetWithCharactersInString:PATTERN_TO_STRIP] invertedSet];
    while ([scannerForKey isAtEnd] == NO) {
        NSString *buffer;
        if ([scannerForKey scanCharactersFromSet:stripChars intoString:&buffer]) {
            [prettyKey appendString:buffer];
            
        } else {
            [scannerForKey setScanLocation:([scannerForKey scanLocation] + 1)];
        }
    }

    while ([scannerForIvar isAtEnd] == NO) {
        NSString *buffer;
        if ([scannerForIvar scanCharactersFromSet:stripChars intoString:&buffer]) {
            [prettyIvar appendString:buffer];
        } else {
            [scannerForIvar setScanLocation:([scannerForIvar scanLocation] + 1)];
        }
    }

    return ([[prettyKey lowercaseString] isEqualToString:[prettyIvar lowercaseString]]);
}

- (NSDate *)dateFromDotNetJSONString:(NSString *)string {
	if(!string) {
		return nil;
	}
    static NSRegularExpression *dateRegEx = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateRegEx = [[NSRegularExpression alloc] initWithPattern:@"^\\/date\\((-?\\d++)(?:([+-])(\\d{2})(\\d{2}))?\\)\\/$" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    NSTextCheckingResult *regexResult = [dateRegEx firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (regexResult) {
        // milliseconds
        NSTimeInterval seconds = [[string substringWithRange:[regexResult rangeAtIndex:1]] doubleValue] / 1000.0;
        // timezone offset
        if ([regexResult rangeAtIndex:2].location != NSNotFound) {
            NSString *sign = [string substringWithRange:[regexResult rangeAtIndex:2]];
            // hours
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:3]]] doubleValue] * 60.0 * 60.0;
            // minutes
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:4]]] doubleValue] * 60.0;
        }
        
        return [NSDate dateWithTimeIntervalSince1970:seconds];
    }
    return nil;
}

@end

#pragma mark - NSString+Additions

@implementation NSString (Additions)

- (BOOL)contains:(NSString*)needle;
{
    NSRange range = [self rangeOfString:needle options: NSCaseInsensitiveSearch];
    return (range.length == needle.length && range.location != NSNotFound);
}

@end
