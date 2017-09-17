//
//  YYTest3VC.m
//  AdaptationiPhonX
//
//  Created by yangyang on 2017/9/17.
//  Copyright © 2017年 Yown( https://yownyang.github.io/ ). All rights reserved.
//

#import "YYTest3VC.h"

@interface YYTest3VC ()

@end

@implementation YYTest3VC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupSelf];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self addLabel];
}

- (void)setupSelf {
 
    self.title = @"使用代码布局";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)addLabel {
    
//    不能使用self.view.frame了
//    在安全区域内布局
    CGFloat y = CGRectGetMaxY(self.view.safeAreaLayoutGuide.layoutFrame) - 20;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 100, 20)];
    
    label.text = @"123456789";
    
    [self.view addSubview:label];
}

@end
