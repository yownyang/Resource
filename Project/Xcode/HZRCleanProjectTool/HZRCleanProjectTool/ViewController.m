//
//  ViewController.m
//  HZRCleanProjectTool
//
//  Created by yown on 2018/8/1.
//  Copyright © 2018年 yown. All rights reserved.
//

#import "ViewController.h"
#import "HZRCleanProjectTool.h"

#define weakify autoreleasepool{} __weak typeof(self) weakSelf = self;
#define strongify try{} @finally{} typeof(weakSelf) self = weakSelf;

@interface ViewController ()

@property (weak) IBOutlet NSTextField *pathTextField;
@property (weak) IBOutlet NSButton *searchButton;
@property (weak) IBOutlet NSTextView *unusedClassNameTextView;
@property (weak) IBOutlet NSTextView *unusedClassPathTextView;
@property (weak) IBOutlet NSButton *deleteButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (strong) HZRCleanProjectTool *cleanProjectTool;

@end

@implementation ViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];
    [self setupProjectTool];
    [self setupSubView];
}

#pragma mark - Setup

- (void)setupProjectTool {
    
    self.cleanProjectTool = [HZRCleanProjectTool new];
}

- (void)setupSubView {
    
    self.progressIndicator.hidden = YES;
    self.pathTextField.placeholderString = @"请将.xcodeproj文件拖入这里";
    self.searchButton.title = @"搜索";
    self.deleteButton.title = @"删除";
}

#pragma mark - Action

- (IBAction)searchAction:(NSButton *)sender {
    
    NSString *path = self.pathTextField.stringValue;
    if ([self isIllegalPath:path]) {
        
        [self showAlertWithString:@"路径有误，请输入正确路径"];
    } else {
        
        if (self.cleanProjectTool.status == kHZRCleanProjectToolStatusSearching) {
            
            [self showAlertWithString:@"搜索中，请勿重复搜索"];
        } else {
            
            @weakify;
            [self showLoading];
            [self.cleanProjectTool searchWithPath:path completionBlock:^(NSDictionary *unusedClassDictionary) {
                
                @strongify;
                [self hiddenLoading];
                self.unusedClassNameTextView.string = [unusedClassDictionary.allKeys componentsJoinedByString:@"\n"];
                
                NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionary];
                [unusedClassDictionary.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [tempDictionary addEntriesFromDictionary:obj];
                }];
                self.unusedClassPathTextView.string = [tempDictionary.allValues componentsJoinedByString:@"\n"];
            }];
        }
    }
}

- (IBAction)deleteAction:(NSButton *)sender {
    
    [self.cleanProjectTool deleteUnusedClassWithCompletionBlock:^(BOOL isSucceed) {
        
        if (isSucceed) {
            
            [self showAlertWithString:@"清除成功"];
        } else {
            
            [self showAlertWithString:@"清除失败"];
        }
    }];
}

#pragma mark - Helper

- (BOOL)isIllegalPath:(NSString *)path {
    
    NSString *extension = path.pathExtension;
    if (!extension || ![extension isEqualToString:@"xcodeproj"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)showAlertWithString:(NSString *)message {
    
    NSAlert *alert = [NSAlert new];
    alert.messageText = message;
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}

- (void)showLoading {
    
    self.progressIndicator.hidden = NO;
    [self.progressIndicator startAnimation:nil];
}

- (void)hiddenLoading {
    
    self.progressIndicator.hidden = YES;
    [self.progressIndicator stopAnimation:nil];
}

@end
