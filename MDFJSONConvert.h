//
//  MDFJSONConvert.h
//  Addd
//
//  Created by Bengang on 2017/5/12.
//  Copyright © 2017年 Bengang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDFJSONConvertable <NSObject>

@optional
- (NSArray *)ignoredKeyPaths;

// key:property name  value:JSON key
- (NSDictionary *)JSONKeyAndPropertyNameMapping;

@end

@interface MDFJSONConvert : NSObject

+ (NSDictionary *)JSONDictionaryWithObject:(NSObject<MDFJSONConvertable> *)obj;

+ (NSDictionary *)JSONDictionaryWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)JSONArrayWithArray:(NSArray *)array;

@end
