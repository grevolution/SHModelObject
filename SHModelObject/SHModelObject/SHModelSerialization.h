// SHModalSerialization.h
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

/**
 *  The `SHModalSerialization` protocol is adopted by any class that will then implement how to serialize the key/value
 *  pair passed to the class.
 */
@protocol SHModelSerialization <NSObject>

/**
 *  This method will be implemented by the class that adopts this protocol and will define the logic for how to
 *  serialize the key/value pair passed to the method. the overridden method must call [super serializeValue: withKey:]
 *  to impelement the default logic for serialization for a specific key/value pair if it choose not to do any specific
 *  implementation.
 *
 *  @param value The value object from the NSDictionary object passed to the class
 *  @param key   The key object from the NSDictionary object passed to the class
 *
 */
- (void) serializeValue:(id)value withKey:(id)key;

@end
