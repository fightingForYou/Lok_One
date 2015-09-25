//
//  PersonalViewController.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/17.
//  Copyright © 2015年 lok. All rights reserved.
//

#import "PersonalViewController.h"
#import "AboutViewController.h"
#import "SettingsViewController.h"

#define DawnViewBGColor [UIColor colorWithRed:235 / 255.0 green:235 / 255.0 blue:235 / 255.0 alpha:1] // #EBEBEB
#define DawnCellBGColor [UIColor colorWithRed:249 / 255.0 green:249 / 255.0 blue:249 / 255.0 alpha:1] // #F9F9F9
#define NightCellBGColor [UIColor colorWithRed:50 / 255.0 green:50 / 255.0 blue:50 / 255.0 alpha:1] // #323232
#define NightCellTextColor [UIColor colorWithRed:111 / 255.0 green:111 / 255.0 blue:111 / 255.0 alpha:1] // #6F6F6F
#define NightCellHeaderTextColor [UIColor colorWithRed:75 / 255.0 green:75 / 255.0 blue:75 / 255.0 alpha:1] // #4B4B4B


@interface PersonalViewController () {
    
    UITableView *_tableView;
}
@end

@implementation PersonalViewController

#pragma mark - lifeCycle

- (void)dealloc {
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [_tableView removeFromSuperview];
    _tableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _createTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitch:) name:@"DKNightVersionNightFallingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitch:) name:@"DKNightVersionDawnComingNotification" object:nil];
}


#pragma mark - NSNotification

- (void)nightModeSwitch:(NSNotification *)notification {
    [_tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)_createTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)
                                              style:UITableViewStyleGrouped];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.nightBackgroundColor = NightBGViewColor;
    [_tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))]; //单元格的下划线占满屏幕的宽度
    _tableView.separatorColor = TableViewCellSeparatorDawnColor;
    _tableView.nightSeparatorColor = [UIColor blackColor];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"profileCell"];
    
}

#pragma  - mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    if (indexPath.row == 0) {
        //        cell.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        cell.imageView.image = [UIImage imageNamed:@"p_notLogin.png"];
        cell.textLabel.text = @"立即登录";
    } else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"setting.png"];
        cell.textLabel.text = @"设置";
    } else {
        cell.imageView.image = [UIImage imageNamed:@"copyright.png"];
        cell.textLabel.text = @"关于";
    }
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.nightTextColor = NightCellTextColor;
    cell.nightBackgroundColor = NightCellBGColor;
    return cell;
}


#pragma  mark  - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.001;
    }
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {// 点击进入个人中心
        
    } else if (indexPath.row == 1) {// 点击进入设置
        SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
        [self.navigationController pushViewController:settingsViewController animated:YES];
    } else if (indexPath.row == 2) {// 点击进入关于界面
        AboutViewController *aboutViewController = [[AboutViewController alloc] init];
        [self.navigationController pushViewController:aboutViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
