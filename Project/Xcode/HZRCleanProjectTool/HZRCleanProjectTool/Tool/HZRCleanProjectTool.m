//
//  HZRCleanProjectTool.m
//  HZRCleanProjectTool
//
//  Created by yown on 2018/8/1.
//  Copyright © 2018年 yown. All rights reserved.
//

#import "HZRCleanProjectTool.h"

@interface HZRCleanProjectTool ()

@property (copy) NSString *fullPath;
@property (strong) NSMutableDictionary *allClassDictionary;
@property (strong) NSMutableDictionary *usedClassDictionary;
@property (strong) NSMutableDictionary *unusedClassDictionary;

@end

@implementation HZRCleanProjectTool

#pragma mark - Public Method

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.status = kHZRCleanProjectToolStatusUnsearch;
        self.allClassDictionary = [NSMutableDictionary dictionary];
        self.usedClassDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)searchWithPath:(NSString *)path completionBlock:(HZRCleanProjectToolSearchBlock)completionBlock {
    
//    1. 将状态设置为搜索中
    self.status = kHZRCleanProjectToolStatusSearching;
//    2. 拼接成需要读取文件的路径，实质上是个Property List文件
    self.fullPath = [path stringByAppendingPathComponent:@"project.pbxproj"];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        //    3. 读取文件内容
        NSDictionary *fullDictionary = [NSDictionary dictionaryWithContentsOfFile:self.fullPath];
        //    4. 获取objects字典
        NSDictionary *objectDictionary = fullDictionary[@"objects"];
        //    5. 获取project的key
        NSString *rootObjectKey = fullDictionary[@"rootObject"];
        //    6. 根据key从objects字典中获取project的字典
        NSDictionary *projectDictionary = objectDictionary[rootObjectKey];
        //    7. 获取mainGroup的key
        NSString *mainGroupKey = projectDictionary[@"mainGroup"];
        //    8. 根据key从objects字典中获取mainGroup的字典
        NSDictionary *mainGroupDictionary = objectDictionary[mainGroupKey];
        //    9. 获取children数组，实际就是主target最外层的所有文件夹和文件
        NSArray *floderArray = mainGroupDictionary[@"children"];
        //    10. 获取到项目的路径
        NSString *projectPath = [path stringByDeletingLastPathComponent];
        //    11. 清除数组中所有元素
        [self resetAllArray];
        //    12. 获取项目中所有的h/m/mm/xib文件
        [self searchAllClassWithArray:floderArray objectDictionary:objectDictionary path:projectPath];
        //    13. 获取使用的类
        [self searchUsedClass];
        //    14. 获取未使用的类
        [self searchUnusedClass];
        //    15. 回调block
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.status = kHZRCleanProjectToolStatusCompletion;
                completionBlock(self.unusedClassDictionary);
            });
        }
    });
}

- (void)deleteUnusedClassWithCompletionBlock:(HZRCleanProjectToolDeleteBlock)completionBlock {
    
    NSMutableDictionary *tempDeleteClassDictionary = [NSMutableDictionary dictionary];
    [self.unusedClassDictionary.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [tempDeleteClassDictionary addEntriesFromDictionary:obj];
    }];
    
    NSString *projectContent = [NSString stringWithContentsOfFile:self.fullPath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *projectContentArray = [NSMutableArray arrayWithArray:[projectContent componentsSeparatedByString:@"\n"]];
    
    [tempDeleteClassDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *uuid, NSString *path, BOOL * _Nonnull stop) {
        
//        物理文件上删除它
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//        引用上删除它
        [projectContentArray enumerateObjectsUsingBlock:^(NSString *code, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([code containsString:uuid]) {
                
                [projectContentArray removeObjectAtIndex:idx];
            }
        }];
    }];
    
    projectContent = [projectContentArray componentsJoinedByString:@"\n"];
    NSError* error = nil;
    [projectContent writeToFile:self.fullPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (completionBlock) {
        error ? completionBlock(NO) : completionBlock(YES);
    }
}

#pragma mark - Reset

- (void)resetAllArray {
    
    [self.allClassDictionary removeAllObjects];
    [self.usedClassDictionary removeAllObjects];
}

#pragma mark - Private Method

- (void)searchAllClassWithArray:(NSArray *)keyArray objectDictionary:(NSDictionary *)objectDictionary path:(NSString *)path {
    
    [keyArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        
        @autoreleasepool {
            
            NSDictionary *floderOrFileDictionary = objectDictionary[key];
            NSString *type = floderOrFileDictionary[@"isa"];
            NSString *onePath = floderOrFileDictionary[@"path"];
            NSString *floderOrFilePath = [path stringByAppendingPathComponent:onePath];
            if ([type isEqualToString:@"PBXFileReference"]) {
                
                //                如果是非实体文件夹中的文件，会带有非实体文件夹的路径，所以要取最后一段
                NSString *className = onePath.lastPathComponent;
                NSString *classExtension = className.pathExtension;
                if ([classExtension isEqualToString:@"h"] ||
                    [classExtension isEqualToString:@"m"] ||
                    [classExtension isEqualToString:@"xib"] ||
                    [classExtension isEqualToString:@"mm"]) {
                    
                    NSString *classNameWithoutExtension = className.stringByDeletingPathExtension;
                    NSMutableDictionary *tempClassDictionary = [self.allClassDictionary objectForKey:classNameWithoutExtension];
                    if (tempClassDictionary) {
                        
                        [tempClassDictionary setObject:floderOrFilePath forKey:key];
                    } else {
                        
                        tempClassDictionary = [NSMutableDictionary dictionary];
                        [tempClassDictionary setObject:floderOrFilePath forKey:key];
                        [self.allClassDictionary setObject:tempClassDictionary forKey:classNameWithoutExtension];
                    }
                }
            } else if ([type isEqualToString:@"PBXGroup"]) {
                
                NSArray *floderArray = floderOrFileDictionary[@"children"];
                [self searchAllClassWithArray:floderArray objectDictionary:objectDictionary path:floderOrFilePath];
            }
        }
    }];
}

- (void)searchUsedClass {
    
    NSMutableDictionary *tempAllClassDictionary = [NSMutableDictionary dictionary];
    [self.allClassDictionary.allValues enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        @autoreleasepool {

            [tempAllClassDictionary addEntriesFromDictionary:obj];
        }
    }];
    
    [tempAllClassDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *classUUID, NSString *classPath1, BOOL * _Nonnull stop) {
        
        @autoreleasepool {
            
            NSString *classExtension = classPath1.pathExtension;
            if ([classExtension isEqualToString:@"h"]) {
                
                NSString *className1 = classPath1.lastPathComponent;
                NSString *classNameWithoutExtension1 = className1.stringByDeletingPathExtension;
                [tempAllClassDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *classUUID, NSString *classPath2, BOOL * _Nonnull stop) {
                   
                    @autoreleasepool {
                        
                        //  不能从自己的类中匹配
                        NSString *className2 = classPath2.lastPathComponent;
                        NSString *classNameWithoutExtension2 = className2.stringByDeletingPathExtension;
                        if (![classNameWithoutExtension1 isEqualToString:classNameWithoutExtension2]) {
                            
                            NSString *searchTypeOne = [NSString stringWithFormat:@"#import \"%@\"", className1];
                            NSString *searchTypeTwo = [NSString stringWithFormat:@"\"%@\"", classNameWithoutExtension1];
                            NSString *contents = [NSString stringWithContentsOfFile:classPath2 encoding:NSUTF8StringEncoding error:nil];
                            BOOL isContainTypeOne = [contents containsString:searchTypeOne];
                            BOOL isContainTypeTwo = [contents containsString:searchTypeTwo];
                            if (isContainTypeOne || isContainTypeTwo) {
                                
                                [self.usedClassDictionary setObject:classPath1 forKey:classNameWithoutExtension1];
                            }
                        }
                    }
                }];
            }
        }
    }];
}

- (void)searchUnusedClass {
    
    self.unusedClassDictionary = [NSMutableDictionary dictionaryWithDictionary:self.allClassDictionary];
    [self.unusedClassDictionary removeObjectsForKeys:self.usedClassDictionary.allKeys];
    [self.unusedClassDictionary removeObjectForKey:@"main"];
}

@end
