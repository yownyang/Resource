//
//  HZRCleanProjectTool.h
//  HZRCleanProjectTool
//
//  Created by yown on 2018/8/1.
//  Copyright © 2018年 yown. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HZRCleanProjectToolStatus){
    
    kHZRCleanProjectToolStatusUnsearch = 0,
    kHZRCleanProjectToolStatusSearching,
    kHZRCleanProjectToolStatusCompletion
};

typedef void(^HZRCleanProjectToolSearchBlock)(NSDictionary *unusedClassDictionary);
typedef void(^HZRCleanProjectToolDeleteBlock)(BOOL isSucceed);

@interface HZRCleanProjectTool : NSObject

@property (nonatomic) HZRCleanProjectToolStatus status;

- (void)searchWithPath:(NSString *)path completionBlock:(HZRCleanProjectToolSearchBlock)completionBlock;
- (void)deleteUnusedClassWithCompletionBlock:(HZRCleanProjectToolDeleteBlock)completionBlock;

@end
