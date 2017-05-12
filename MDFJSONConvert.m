//
//  MDFJSONConvert.m
//  Addd
//
//  Created by Bengang on 2017/5/12.
//  Copyright © 2017年 Bengang. All rights reserved.
//

#import "MDFJSONConvert.h"
#import <objc/runtime.h>

@implementation MDFJSONConvert

+ (NSArray *)allPropertyNamesForClass:(Class)aClass
{
    NSMutableArray *propertyNamesArr = [NSMutableArray array];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertyCount);
    for (unsigned int i = 0; i<propertyCount; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        [propertyNamesArr addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return propertyNamesArr;
}

+ (NSArray *)defultIgnoredKeyPaths
{
    return @[@"debugDescription", @"description", @"hash", @"superclass"];
}

+ (NSArray *)ignoredKeyPathForObject:(NSObject<MDFJSONConvertable> *)obj
{
    NSArray *ignoredKeyPaths = [self defultIgnoredKeyPaths];
    if ([obj respondsToSelector:@selector(ignoredKeyPaths)]) {
        NSArray *customIgnoredKeyPaths = [obj ignoredKeyPaths];
        if (customIgnoredKeyPaths.count) {
            ignoredKeyPaths = [ignoredKeyPaths arrayByAddingObjectsFromArray:customIgnoredKeyPaths];
        }
    }
    return ignoredKeyPaths;
}

+ (NSString *)JSONKeyWithPropertyName:(NSString *)propertyName ofObject:(NSObject<MDFJSONConvertable> *)obj
{
    if ([obj respondsToSelector:@selector(JSONKeyAndPropertyNameMapping)]) {
        NSString *JSONKey = [[obj JSONKeyAndPropertyNameMapping] objectForKey:propertyName];
        if (JSONKey.length) {
            return JSONKey;
        }
    }
    return propertyName;
}

+ (NSDictionary *)JSONDictionaryWithObject:(NSObject<MDFJSONConvertable> *)obj
{
    if (![obj conformsToProtocol:@protocol(MDFJSONConvertable)]) {
        return nil;
    }
    NSArray *propertyNames = [self allPropertyNamesForClass:[obj class]];
    NSMutableDictionary *JSONDic = [NSMutableDictionary dictionaryWithCapacity:propertyNames.count];
    NSArray *ignoredKeyPaths = [self ignoredKeyPathForObject:obj];
    for (NSString *propertyName in propertyNames) {
        if ([ignoredKeyPaths containsObject:propertyName]) {
            continue;
        }
        id value = [obj valueForKey:propertyName];
        if (!value) {
            continue;
        }
        NSString *JSONKey = [self JSONKeyWithPropertyName:propertyName ofObject:obj];
        value = [self JSONObjectWithObject:value];
        if (value) {
            [JSONDic setObject:value forKey:JSONKey];
        }
    }
    return [NSDictionary dictionaryWithDictionary:JSONDic];
}

+ (id)JSONObjectWithObject:(id)obj
{
    id JSONObject = obj;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        JSONObject = [self JSONDictionaryWithDictionary:obj];
    } else if ([obj isKindOfClass:[NSArray class]]) {
        JSONObject = [self JSONArrayWithArray:obj];
    } else if ([obj conformsToProtocol:@protocol(MDFJSONConvertable)]) {
        JSONObject = [self JSONDictionaryWithObject:obj];
    }
    return JSONObject;
}

+ (NSDictionary *)JSONDictionaryWithDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *absoluteDictionary = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id JSONObject = [self JSONObjectWithObject:obj];
        if (JSONObject) {
            [absoluteDictionary setObject:JSONObject forKey:key];
        }
    }];
    return [NSDictionary dictionaryWithDictionary:absoluteDictionary];
}

+ (NSArray *)JSONArrayWithArray:(NSArray *)array
{
    NSMutableArray *JSONArray = [NSMutableArray arrayWithCapacity:array.count];
    for (id obj in array) {
        id JSONObject = [self JSONObjectWithObject:obj];
        if (JSONObject) {
            [JSONArray addObject:JSONObject];
        }
    }
    return [NSArray arrayWithArray:JSONArray];
}

@end

