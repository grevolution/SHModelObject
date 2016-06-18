// SHModelObject.m
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

#import "SHModelObject.h"
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
#define IS_VALID_STRING(val)                                                                                           \
    (val != nil) && [val length] != 0 && ([TRIM_STRING(val) length] != 0) && ![val isEqualToString:@"(null)"]

// pattern to strip from the dictionary key and ivarname for comparision
#define PATTERN_TO_STRIP @"-_ "

static NSDateFormatter *_simpleDateFormatter;
static NSDateFormatter *_timezoneDateFormatter;
static NSDateFormatter *_customFormatter;

@implementation SHModelObject {
    Ivar *_ivars;
    unsigned int _outCount;
    kDateConversionOption _converstionOption;
    kInputDateFormat _inputDateFormat;
    NSDictionary *_mappings;
    NSString *_customInputDateFormatString;
}

#pragma mark - Factory methods for object creation
//
+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    if (nil == dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    if ([dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [[[self class] alloc] initWithDictionary:dictionary];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary mappings:(NSDictionary *)mapping {
    if (nil == dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    if ([dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [self objectWithDictionary:dictionary
                 dateConversionOption:kDateConverstionFromNSStringToNSDateOption
                        inputDateType:kInputDateFormatJSON
                             mappings:mapping];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary
                dateConversionOption:(kDateConversionOption)option
                       inputDateType:(kInputDateFormat)inputDateType
                            mappings:(NSDictionary *)mapping {
    if (nil == dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    if ([dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [[[self class] alloc] initWithDictionary:dictionary
                               dateConversionOption:option
                                      inputDateType:inputDateType
                                           mappings:mapping];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary
                dateConversionOption:(kDateConversionOption)option
                     inputDateFormat:(NSString *)inputDateFormat
                            mappings:(NSDictionary *)mapping {
    if (nil == dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    if ([dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [[[self class] alloc] initWithDictionary:dictionary
                               dateConversionOption:option
                                    inputDateFormat:inputDateFormat
                                           mappings:mapping];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary
                dateConversionOption:(kDateConversionOption)option
                  inputDateFormatter:(NSDateFormatter *)inputDateFormatter
                            mappings:(NSDictionary *)mapping {
    if (nil == dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    if ([dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [[[self class] alloc] initWithDictionary:dictionary
                               dateConversionOption:option
                                 inputDateFormatter:inputDateFormatter
                                           mappings:mapping];
}

//
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
{
    if ((self = [super init])) {
        return [self updateWithDictionary:dictionary
                     dateConversionOption:kDateConverstionFromNSStringToNSStringOption
                            inputDateType:kInputDateFormatJSON
                                 mappings:nil];
    }
    return self;
}

//
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
              dateConversionOption:(kDateConversionOption)option
                     inputDateType:(kInputDateFormat)inputDateType
                          mappings:(NSDictionary *)mapping {
    if ((self = [super init])) {
        return [self updateWithDictionary:dictionary
                     dateConversionOption:option
                            inputDateType:inputDateType
                                 mappings:mapping];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
              dateConversionOption:(kDateConversionOption)option
                   inputDateFormat:(NSString *)inputDateFormat
                          mappings:(NSDictionary *)mapping {
    if ((self = [super init])) {
        return [self updateWithDictionary:dictionary
                     dateConversionOption:option
                          inputDateFormat:inputDateFormat
                                 mappings:mapping];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
              dateConversionOption:(kDateConversionOption)option
                inputDateFormatter:(NSDateFormatter *)inputDateFormatter
                          mappings:(NSDictionary *)mapping {
    if ((self = [super init])) {
        return [self updateWithDictionary:dictionary
                     dateConversionOption:option
                       inputDateFormatter:inputDateFormatter
                                 mappings:mapping];
    }
    return self;
}

// NSCoding
- (NSArray *)propertyNames {
    NSMutableArray *array = [NSMutableArray array];

    // List of ivars
    id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
    _ivars = class_copyIvarList(class, &_outCount);

    // If it match our ivar name, then set it
    for (unsigned int i = 0; i < _outCount; i++) {
        Ivar ivar = _ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        [array addObject:ivarName];
    }

    free(_ivars);
    _ivars = NULL;
    return array;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [self init])) {
        // Loop through the properties
        for (NSString *key in [self propertyNames]) {
            // Decode the property, and use the KVC setValueForKey: method to set it
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Loop through the properties
    for (NSString *key in [self propertyNames]) {
        // Use the KVC valueForKey: method to get the property and then encode it
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

//
- (instancetype)updateWithDictionary:(NSDictionary *)dictionary {
    // List of ivars
    id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
    _ivars = class_copyIvarList(class, &_outCount);

    // For each top-level property in the dictionary
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
- (instancetype)updateWithDictionary:(NSDictionary *)dictionary
                dateConversionOption:(kDateConversionOption)option
                       inputDateType:(kInputDateFormat)inputDateType
                            mappings:(NSDictionary *)mapping {
    _converstionOption = option;
    _inputDateFormat = inputDateType;
    _mappings = mapping;

    if (nil == _simpleDateFormatter) {
        _simpleDateFormatter = [[NSDateFormatter alloc] init];
        [_simpleDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }

    if (nil == _timezoneDateFormatter) {
        _timezoneDateFormatter = [[NSDateFormatter alloc] init];
        [_timezoneDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    }

    return [self updateWithDictionary:dictionary];
}

- (instancetype)updateWithDictionary:(NSDictionary *)dictionary
                dateConversionOption:(kDateConversionOption)option
                     inputDateFormat:(NSString *)inputDateFormat
                            mappings:(NSDictionary *)mapping {
    _converstionOption = option;
    _inputDateFormat = kInputDateFormatCustom;
    _customInputDateFormatString = inputDateFormat;
    if (_customInputDateFormatString && !_customFormatter) {
        _customFormatter = [[NSDateFormatter alloc] init];
        [_customFormatter setDateFormat:_customInputDateFormatString];
    }
    _mappings = mapping;

    return [self updateWithDictionary:dictionary];
}

- (instancetype)updateWithDictionary:(NSDictionary *)dictionary
                dateConversionOption:(kDateConversionOption)option
                  inputDateFormatter:(NSDateFormatter *)inputDateFormatter
                            mappings:(NSDictionary *)mapping {
    _converstionOption = option;
    _inputDateFormat = kInputDateFormatCustom;
    _customFormatter = inputDateFormatter;
    _mappings = mapping;

    return [self updateWithDictionary:dictionary];
}

#pragma mark - SHModalSerialization protocol methods

- (void)serializeValue:(id)value withKey:(id)key {
    // check for NSNull or nil for key
    if ([key isKindOfClass:[NSNull class]] || nil == key) {
        return;
    }

    // check for NSNull or nil for value
    if ([value isKindOfClass:[NSNull class]] || nil == value) {
        return;
    }

    // If it match our ivar name, then set it
    for (unsigned int i = 0; i < _outCount; i++) {
        Ivar ivar = _ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        NSString *ivarType = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];

        if ([self matchesPattern:key ivar:ivarName] == NO) {
            continue;
        }

        // it will be NSString, NSNumber, NSArray, NSDictionary or NSNull
        if ([value isKindOfClass:[NSString class]]) {

            /*
             converting the .NET JSON Date representation to either NSDate, NSTimeInterval or keeping it as
             NSString. if somebody wants a different conversion, please simplye override the method and parse the
             value and set for yourself and make sure you call [super serializeValue: key:] for all other values so
             that they are parsed correctly.
             */
            switch (_converstionOption) {
                case kDateConverstionFromNSStringToNSDateOption: {
                    if ([ivarType contains:@"NSDate"]) {
                        switch (_inputDateFormat) {
                            case kInputDateFormatJSON: {
                                value = (NSDate *)[self dateFromDotNetJSONString:value];
                            } break;
                            case kInputDateFormatDotNetSimple: {
                                value = (NSDate *)[_simpleDateFormatter dateFromString:value];
                            } break;
                            case kInputDateFormatDotNetWithTimeZone: {
                                value = (NSDate *)[_timezoneDateFormatter dateFromString:value];
                            } break;
                            case kInputDateFormatCustom: {
                                value = (NSDate *)[_customFormatter dateFromString:value];
                            } break;
                            default: { value = (NSDate *)[self dateFromDotNetJSONString:value]; } break;
                        }
                    }
                } break;
                case kDateConverstionFromNSStringToNSTimeIntervalOption: {
                    if (![ivarType contains:@"@"]) {
                        switch (_inputDateFormat) {
                            case kInputDateFormatJSON: {
                                value = @([[self dateFromDotNetJSONString:value] timeIntervalSince1970]);
                            } break;
                            case kInputDateFormatDotNetSimple: {
                                value = @([[_simpleDateFormatter dateFromString:value] timeIntervalSince1970]);
                            } break;
                            case kInputDateFormatDotNetWithTimeZone: {
                                value = @([[_timezoneDateFormatter dateFromString:value] timeIntervalSince1970]);
                            } break;
                            case kInputDateFormatCustom: {
                                value = @([[_customFormatter dateFromString:value] timeIntervalSince1970]);
                            } break;
                            default: {
                                value = @([[self dateFromDotNetJSONString:value] timeIntervalSince1970]);
                            } break;
                        }
                    }
                } break;
                case kDateConverstionFromNSStringToNSStringOption: {
                    if (![ivarType contains:NSStringFromClass([NSString class])]) {
                        NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSString");
                    }
                }
            }
        } else if ([value isKindOfClass:[NSNumber class]] && ![ivarType contains:@"NSNumber"]) {
            // special case, where NSNumber can be stored into the primitive types. just need to chceck that iVar is not
            // an object.
            if ([ivarType contains:@"@"]) {
                NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSNumber");
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            NSString *typeName = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
            typeName = [typeName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            Class objectClass = NSClassFromString(typeName);
            BOOL isSHModelObject = [self isSHModelObject:objectClass];
            if (isSHModelObject) {
                value = [objectClass objectWithDictionary:value];
            } else if (![ivarType contains:@"Dictionary"]) {
                NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSDictionary or NSMutableDictionary");
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            if (![ivarType contains:@"Array"]) {
                NSAssert(false, @"the types do not match : %@ vs %@", ivarType, @"NSArray or NSMutableArray");
            }

            id availableMappingClass = _mappings[key];
            if (availableMappingClass && [availableMappingClass isKindOfClass:[NSString class]]) {
                // mapping string available.
                Class objectClass = NSClassFromString(availableMappingClass);
                BOOL isSHModelObject = [self isSHModelObject:objectClass];
                if (isSHModelObject) {
                    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:[value count]];
                    for (id item in value) {
                        // item should be a dictionary
                        if ([item isKindOfClass:[NSDictionary class]]) {
                            id itemObject = [objectClass objectWithDictionary:item mappings:_mappings];
                            if (itemObject) {
                                [valueArray addObject:itemObject];
                            }
                        } else {
                            NSLog(@"object %@ is not a NSDictionary object, skipping.", [item description]);
                        }
                    }
                    value = valueArray;
                }
            }
        }

        [self setValue:value forKey:ivarName];
    }
}

- (BOOL)isSHModelObject:(Class) class {
    if (class == nil)
        return NO;
    if (class == [SHModelObject class]) {
        return YES;
    }
    return [self isSHModelObject:[class superclass]];
}

#pragma mark - NSObject overriden methods

    //
    -
    (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
}

#pragma mark - SHModalSerializer helper functions

- (BOOL)matchesPattern:(NSString *)key ivar:(NSString *)ivarName {
    if (nil == key || nil == ivarName) {
        return NO;
    }

    if ((!IS_VALID_STRING(key)) || (!IS_VALID_STRING(ivarName))) {
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
    if (!string) {
        return nil;
    }
    static NSRegularExpression *dateRegEx = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      dateRegEx = [[NSRegularExpression alloc] initWithPattern:@"^\\/date\\((-?\\d++)(?:([+-])(\\d{2})(\\d{2}))?\\)\\/$"
                                                       options:NSRegularExpressionCaseInsensitive
                                                         error:nil];
    });
    NSTextCheckingResult *regexResult =
        [dateRegEx firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];

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

- (BOOL)contains:(NSString *)needle;
{
    NSRange range = [self rangeOfString:needle options:NSCaseInsensitiveSearch];
    return (range.length == needle.length && range.location != NSNotFound);
}

@end
