//
//  YYTest1VC.m
//  AdaptationiPhonX
//
//  Created by yangyang on 2017/9/17.
//  Copyright © 2017年 Yown( https://yownyang.github.io/ ). All rights reserved.
//

#import "YYTest1VC.h"

static NSString *const kYYTest1TableViewReuseIdentifier = @"kYYTest1TableViewReuseIdentifier";

@interface YYTest1VC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation YYTest1VC

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setupTableView];
}

#pragma mark - Setup

- (void)setupTableView {
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kYYTest1TableViewReuseIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kYYTest1TableViewReuseIdentifier];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
    
    return cell;
}

@end
