//
//  SHConstants.h
//  SHModelObject
//
//  Created by SHAN UL HAQ on 4/4/15.
//  Copyright (c) 2015 grevolution. All rights reserved.
//

#ifndef SHModelObject_SHConstants_h
#define SHModelObject_SHConstants_h

/**
 *  Date option conversion enum to be passed to the serializer constructer
 */
typedef enum {
    kDateConverstionFromNSStringToNSStringOption = 0,      // do not convert, keep NSString as it is.
    kDateConverstionFromNSStringToNSDateOption = 1,        // convert NSString to NSDate
    kDateConverstionFromNSStringToNSTimeIntervalOption = 2 // convert NSString to NSTimeInterval
} kDateConversionOption;

/**
 *  enum for identifying the input date type.
 */
typedef NS_ENUM(int, kInputDateFormat) {
    kInputDateFormatJSON = 1,
    kInputDateFormatDotNetSimple = 2,
    kInputDateFormatDotNetWithTimeZone = 3,
    kInputDateFormatCustom = -1,
};

#endif
