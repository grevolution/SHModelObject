SHModelObject
=============

`SHModelObject` is a utility model Base Class that uses objective-c runtime to assign the values to instance variables and properties of the model class from an `NSDictionary`, Which is a basic usecase when using webservices that return JSON response.

[![Build Status](https://img.shields.io/travis/grevolution/SHModelObject.svg?branch=master)](https://travis-ci.org/grevolution/SHModelObject) [![Pod Version](https://img.shields.io/cocoapods/v/SHModelObject.svg)](https://img.shields.io/cocoapods/v/SHModelObject.svg) [![License](https://img.shields.io/cocoapods/l/SHModelObject.svg)](https://img.shields.io/cocoapods/l/SHModelObject.svg)

Let say you have a WebService that serves you back the following Response:

```json
{
	"user_name" : "Shan Ul Haq",
	"user_id" : 34567,
	"user_role" : "Author",
	"user_x_values" : [
		"abcd", 777, "efgh" , true, false
	]
}
```

You parse this response using a JSON library and convert this response into a NSDictionary. Now another task is to populate following User model Object

```objective-c
@interface User : NSObject {
	NSString *_userName;
	NSInteger _userId;
	NSString *userRole;
}

@property(nonatomic, strong) NSArray *userXValues;

@end
```

To populate an Object of User, you will have to write some initializer that will take a NSDictionary and will populate the `ivars` and `properties` of your model class one by one. and you will have to do this 
for all the model classes that you have in your project. you will be adding something like below to your class and implement the method.

	- (User *)initWithDictionary:(NSDictionary *)responseDictionary;

Thats where `SHModelObject` comes in, its a Single class with basic purpose to reduce this effort and do the work for you. all you have to do is `subclass` your model class with `SHModelObject`, so the above class becomes:


```objective-c
@interface User : SHModelObject {
	NSString *_userName;
	NSInteger _userId;
	NSString *userRole;
}

@property(nonatomic, strong) NSArray *userXValues;

@end
```

and thats it. `SHModelObject` has a basic initializer that will take the NSDictionary and will populate all the `ivars` and `properties` for you. 

just initialize the model with provided initializers and off you go.

	User *u = [[User alloc] initWithDictionary:responseDictionary];

##How `SHModelObject` knows which value to assing to which instance variable?

SHModelObject compares the keys of NSDictionary with the `ivar` or `property` names in an efficient way. while comparing the names of keys with ivars it doesnt take `_`, `-` or ` ` into account (also the case doesnt matter). so

`user_name` OR `USER_NAME` OR `USERNAME` OR `UserName` will match with `_userName` OR `userName` OR `UserName`

you can override `- (void)serializeValue:(id)value withKey:(id)key` method if you want to a custom logic to parse a specific key/value pair. make sure to call [super serializeValue] for the values you want to parse by default.

```objective-c
- (void)serializeValue:(id)value withKey:(id)key
{
    if([key isEqualToString:@"numberVALUE"]) {
        _numberValue = value;
    } else {
        [super serializeValue:value withKey:key];
    }
}
```

##Parsing .NET JSON Dates to NSDate or NSTimeInterval

you can use `kDateConversionOption` to convert the .NET JSON Date Strings to either `NSDate` or `NSTimeInterval` or keep it as `NSString` and parse yourself and also you can define `kInputDateFormat` to specify your input date format (JSON format, .NET Simple or .NET with timezone)


##Parsing instance variables which are also a subclass of `SHModelObject` 

you dont have to do anything :). `SHModelObject` automatically handles it. checkout the sample code.

for example, following JSON

```json

{
	"name" : "Shan Ul Haq",
	"person_id" : 123,
	"image" : {
		"image_id" : 234,
		"image_url" : http://image_url,
		"orientation" : "portrait"
	}
}

```
will be automatically parsed into following object:

```objective-c
@interface Person : SHModelObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic) int personId;
@property(nonatomic, strong) Image *image;

@end
```
where Image object is also a `SHModelObject`

```objective-c
@interface Image : SHModelObject

@property(nonatomic) int imageId;
@property(nonatomic, strong) NSString *imageUrl;
@property(nonatomic, strong) NSString *orientation;

@end
```

###Parsing arrays of objects which are a subclass of `SHModelObject`

similar to parsing `SHModelObject` instance variables, arrays can be handled too. you need to specify the mapping which will define that the JSON array consist of which object type.

for example, if you have following JSON

```json
{ 
     "aKey" : "aValue",
     "arrayOfModels" : [
             {
                 "modelId" : 2,
                 "modelName" : "My Model 2",
                 "modelType" : "My Model Type 2"
                 },{
                 "modelId" : 3,
                 "modelName" : "My Model 3",
                 "modelType" : "My Model Type 3"
                 },{
                 "modelId" : 4,
                 "modelName" : "My Model 4",
                 "modelType" : "My Model Type 4"
                 }
             ]
     }
}

```
which translates to following objects.

```objective-c
@interface MyObject : SHModelObject

@property(nonatomic, strong) NSString *aKey;
@property(nonatomic, strong) NSArray *arrayOfModels;

@end

@interface AModel : SHModelObject

@property(nonatomic) int modelId;
@property(nonatomic, strong) NSString *modelName;
@property(nonatomic, strong) NSString *modelType;

@end


```

you can convert json like this:

```objective-c
// key is the variable name and value is the class name.
NSDictionary *mappingDictionary = @{@"arrayOfModels" : "AModel"}; 

MyObject *myObject = [MyObject objectWithDictionary:dictionary mapping:mappingDictionary];

```


##How to Use it.

1- Add the classes into your project

2- sublcass your models with `SHModelObject`

3- initialize using the povided initializers and pass the response NSDictionary ( initWithDictionary: and other variants )

4- override `serializeValue` if you want to parse a specific key/value your way.

5- thats it. off you go.

##Tasks Pending

- [X] adding to cocoapods.
- [X] adding support for custom instance variable types that are also subclasses of `SHModelObject`
- [X] implementing `NSCoding` for archiving/unarchiving the model objects.
- [X] adding support for handling arrays of custom `SHModelObject` objects.
- [ ] implementing a deserializer for converting the object to NSDictionary. 

##Contact Me

Shan Ul Haq (http://grevolution.me)

- g@grevolution.me

- http://twitter.com/gfg5tek

- http://sg.linkedin.com/in/grevolution/

##License

`SHModelObject` is available under the MIT license. See the LICENSE file for more info.
