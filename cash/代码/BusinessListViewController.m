//
//  BusinessListViewController.m
//  Manager
//
//  Created by 胡金友 on 15/8/14.
//  Copyright (c) 2015年 xywy. All rights reserved.
//

#import "BusinessListViewController.h"
#import "BusinessListTableViewCell.h"
#import "BusinessSummaryViewController.h"
#import "BusinessListModel.h"
#import "BusinessEditViewController.h"
#import "CSHPopView.h"
#import "PersonalInfoVC.h"
#import "ChangePasswordVC.h"
#import "AppDelegate.h"

@interface BusinessListViewController () <CSHPopViewDelegate>

@property (retain, nonatomic) NSMutableArray *p_businessArr;

@property (assign, nonatomic) NSInteger curPage;
@property (assign, nonatomic) NSInteger maxPice;
@property (retain, nonatomic) MXYCRequest *request;

@end

@implementation BusinessListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupRightBarButtonItems];
    // Do any additional setup after loading the view.
    
    [self setRefreshWithIsHaveHeader:YES
                        isHaveFooter:NO];
    self.request = [MXYCRequest requestInstance];
    self.curPage = 0;
    [self rightRefreshing];


    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 30);
    button.backgroundColor = [UIColor colorWithHex:BLOCK_GREEN];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addBusiness) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([Tools shareTool].needBusilistRefresh)
    {
        [self rightRefreshing];
        
        [Tools shareTool].needBusilistRefresh = NO;
    }
}

#pragma
- (void)setupRightBarButtonItems
{
    UIBarButtonItem *userInfoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_user_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(pressUserInfo)];

    UIBarButtonItem *findBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_search_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(pressFind)];


    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:userInfoBtn, nil]];
}

- (void)pressMore
{

}

- (void)pressUserInfo
{
    CSHPopView *popView = [CSHPopView popMenuViewFrame:CGRectMake(MANAGERWIDTH-80, 64, 80, 88) stringArray:@[@"我的账户", @"更改密码", @"退出登录"]];
    popView.delegate = self;
    [popView popShow];
}

- (void)pressFind
{

}
- (void)popViewPressMenu:(NSString *)string integer:(NSInteger)integer
{
    if (integer == 0) {
        PersonalInfoVC *infoVC = [[PersonalInfoVC alloc] init];
        [self.navigationController pushViewController:infoVC animated:YES];
    }
    if (integer == 1) {
        ChangePasswordVC *changepwVC = [[ChangePasswordVC alloc] init];
        [self.navigationController pushViewController:changepwVC animated:YES];
    }
    if (integer == 2) {
        [SHAREAPP unlogin];
    }
}


- (void)fetchRecords
{
    [self startProgress];
    
    NSDictionary *params = @{@"token" : kUSER.token,
                             @"page" : @(self.curPage + 1),
                             @"sid" : @(kUSER.sid),
                             @"action" : @"view"
                             };
    
    [self.request postStartRequestWithAPI:@"bizlist"
                     withParamDictionnary:params
               completionBlockWithSuccess:^(ZSRequest *request) {
                   
                   [self endRefreshing];
                   
                   [self stopProgress];
                   
                   NSDictionary *result = request.responseJSONObject;
                   
                   if ([result[@"result"] integerValue] == 1)
                   {
                       if (_curPage == 0)
                       {
                           [self.p_businessArr removeAllObjects];
                       }
                       
                       self.curPage = [result[@"page"] integerValue];
                       self.maxPice = [result[@"count"] integerValue];
                       
                       if (self.maxPice < 15)
                       {
                           self.needRefreshFooter = NO;
                       }
                       
                       [self.p_businessArr addObjectsFromArray:[BusinessListModel objectArrayWithKeyValuesArray:result[@"businesslist"]]];
                       [self.tableView  reloadData];
                   }
                   else
                   {
                       [self startProgressAutoHideWithText:result[@"message"]];
                   }
                   
                   [ZSRequestLog requestLogWith:request];
                   
                   
                   
               } failure:^(ZSRequest *request) {
                   [self endRefreshing];
                   [ZSRequestLog requestLogWith:request];
                   [self stopProgress];
                   
                   [self startProgressAutoHideWithText:@"请求失败"];
               }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.p_businessArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reUsefulIdentifier = @"reUsefulIdentifier";
    
    BusinessListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reUsefulIdentifier];
    
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BusinessListTableViewCell class]) owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.statusLabel.layer.masksToBounds = YES;
        cell.statusLabel.layer.cornerRadius = 5;
        [cell resetFont];
    }
    
    BusinessListModel *model = [self.p_businessArr objectAtIndex:indexPath.row];
    
    cell.statusLabel.text = model.status;
    cell.statusLabel.backgroundColor = [Tools getColor:model.statusvalue];
    cell.businessIDLabel.text = [NSString stringWithFormat:@"业务编号:%@", model.businessid];
    cell.contractIDLabel.text = [NSString stringWithFormat:@"合同编号:%@", model.contractid];
    cell.businessTitleLabel.text = model.title;
    cell.customerLabel.text = [NSString stringWithFormat:@"客户:%@", model.cusname];
    cell.confimDateLabel.text = [NSString stringWithFormat:@"签订日期:%@", [Tools tinyDateString:model.createdate]];
    
    cell.statusLabel.hidden = !(model.status && model.status.length > 0);
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108 * kScreenScale;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BusinessListModel *model = [self.p_businessArr objectAtIndex:indexPath.row];
    BusinessSummaryViewController *summaryVC = [[BusinessSummaryViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:summaryVC animated:YES];
}

- (void)loadNewData
{
    self.curPage = 0;
    
    [self fetchRecords];
}

- (void)loadMoreData
{
    [self fetchRecords];
}

- (NSMutableArray *)p_businessArr
{
    if (!_p_businessArr)
    {
        _p_businessArr = [[NSMutableArray alloc] init];
    }
    
    return _p_businessArr;
}

- (void)addBusiness
{
    BusinessEditViewController *editVC = [[BusinessEditViewController alloc] initWithType:BusinessTypeNew];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
