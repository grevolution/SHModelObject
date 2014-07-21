// SHModalSerializer.h
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

#import <Foundation/Foundation.h>
#import "SHModelSerialization.h"

/**
 *  Date option conversion enum to be passed to the serializer constructer
 */
typedef enum {
    kDateConverstionFromNSStringToNSStringOption        = 0,      //do not convert, keep NSString as it is.
    kDateConverstionFromNSStringToNSDateOption          = 1,      //convert NSString to NSDate
    kDateConverstionFromNSStringToNSTimeIntervalOption  = 2       //convert NSString to NSTimeInterval
} kDateConversionOption;

/**
 *  enum for identifying the input date type.
 */
typedef NS_ENUM(int, kInputDateFormat) {
    kInputDateFormatJSON                    =0,
    kInputDateFormatDotNetSimple            = 1,
    kInputDateFormatDotNetWithTimeZone      = 2
};

/**
 *  The `SHModalSerializer` is a base class that uses objective-c runtime to populate a modal class instance variables
 *  by passing a NSDictionary to it. The NSDictionary key is compared with the instance variable name and the value is 
 *  populated to the variable.
 */
@interface SHModelObject : NSObject <SHModelSerialization, NSCoding>

/**
 *  class initializer
 *
 *  @param dictionary dictionary containing key/value pairs for the object
 *
 *  @return object of type instancetype populated with the values from `dictionary`
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  class initializer
 *
 *  @param dictionary dictionary containing key/value pairs for the object
 *  @param option `kDateConverstionOption` to determine what to do when the value from dictionary is a DOT.NET Date type.
 *  @param inputDateType `kInputDateFormat` to determine what what is the input format of the date.
 *
 *  @return object of type instancetype populated with the values from `dictionary`
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary dateConversionOption:(kDateConversionOption)option
                     inputDateType:(kInputDateFormat)inputDateType
                          mappings:(NSDictionary *)dateValueMapping;

/**
 *  static variant of class initializer with nil check for the dictionary passed
 *
 *  @param dictionary dictionary containing key/value pairs for the object
 *
 *  @return object of type instancetype populated with the values from `dictionary`
 */
+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;

/**
 *  static variant of class initializer with nil check for the dictionary passed
 *
 *  @param dictionary dictionary containing key/value pairs for the object
 *  @param option `kDateConverstionOption` to determine what to do when the value from dictionary is a DOT.NET Date type.
 *  @param inputDateType `kInputDateFormat` to determine what what is the input format of the date.
 *
 *  @return object of type instancetype populated with the values from `dictionary`
 */
+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary dateConversionOption:(kDateConversionOption)option
                       inputDateType:(kInputDateFormat)inputDateType
                            mappings:(NSDictionary *)dateValueMapping;

/**
 *  update the instance with new dictionary values
 *
 *  @param dictionary dictionary containing key/value pairs for the object
 *
 *  @return object of type instancetype populated with the values from `dictionary`
 */
- (instancetype)updateWithDictionary:(NSDictionary *)dictionary;

/**
 *  update the instance with new dictionary values
 *
 *  @param dictionary dictionary containing key/value pairs for the object
 *  @param option `kDateConverstionOption` to determine what to do when the value from dictionary is a DOT.NET Date type.
 *  @param inputDateType `kInputDateFormat` to determine what what is the input format of the date.
 *
 *  @return object of type instancetype populated with the values from `dictionary`
 */
- (instancetype)updateWithDictionary:(NSDictionary *)dictionary dateConversionOption:(kDateConversionOption)option
                       inputDateType:(kInputDateFormat)inputDateType
                            mappings:(NSDictionary *)dateValueMapping;
@end


@interface NSString (Additions)

- (BOOL)contains:(NSString*)needle;

@end