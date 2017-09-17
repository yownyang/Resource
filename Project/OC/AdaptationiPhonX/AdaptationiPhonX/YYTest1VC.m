//
//  YYTest1VC.m
//  AdaptationiPhonX
//
//  Created by yangyang on 2017/9/17.
//  Copyright © 2017年 Yown( https://yownyang.github.io/ ). All rights reserved.
//

#import "YYTest1VC.h"

static NSString *const kYYTest1TableViewReuseIdentifier = @"kYYTest1TableViewReuseIdentifier";
static NSString *const kText = @"text";
static NSString *const kClass = @"class";

@interface YYTest1VC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *data;

@end

@implementation YYTest1VC

- (void)viewDidLoad {

    [super viewDidLoad];

    self.data = [NSArray arrayWithObjects:
  @{kText : @"代码布局", kClass : @"YYTest3VC"},
  @{kText : @"Xib布局", kClass : @"YYTest4VC"}, nil];
    
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
    
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = [self.data objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kYYTest1TableViewReuseIdentifier];
    cell.textLabel.text = dic[kText];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = [self.data objectAtIndex:indexPath.row];
    
    UIViewController *vc = [NSClassFromString(dic[kClass]) new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
