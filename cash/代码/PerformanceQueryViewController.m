//
//  PerformanceQueryViewController.m
//  Manager
//
//  Created by 胡金友 on 15/8/14.
//  Copyright (c) 2015年 xywy. All rights reserved.
//

#import "PerformanceQueryViewController.h"
#import "PerForm.h"
#import "CSHPopView.h"
#import "PersonalInfoVC.h"
#import "ChangePasswordVC.h"
#import "AppDelegate.h"
@interface PerformanceQueryViewController ()<CSHPopViewDelegate>

@property (retain, nonatomic) MXYCRequest *request;

@property (assign, nonatomic) NSInteger curpage;

@property (retain, nonatomic) NSMutableArray *gainList;

@end

@implementation PerformanceQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self setupRightBarButtonItems];
    // Do any additional setup after loading the view.
    
    self.gainList = [[NSMutableArray alloc] init];
    
    [self setRefreshWithIsHaveHeader:YES
                        isHaveFooter:NO];
    
    self.curpage = 0;
    
    self.request = [MXYCRequest requestInstance];
    
    [self rightRefreshing];

}
#pragma
- (void)setupRightBarButtonItems
{
    UIBarButtonItem *userInfoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_user_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(pressUserInfo)];

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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gainList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *reUsefulIdentifier = @"reUsef";
//    PerForm *cell = [tableView dequeueReusableCellWithIdentifier:reUsefulIdentifier];
//    if (cell == nil)
//    {
       PerForm * cell = [[PerForm alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }

    NSDictionary *dict = [self.gainList objectAtIndex:indexPath.row];

    [cell setupDataDic:dict];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (void)loadNewData
{
    self.curpage = 0;
    
    [self fetchRecords];
}

- (void)loadMoreData
{
    [self fetchRecords];
}

- (void)fetchRecords
{
    [self startProgress];
    
    [self.request postStartRequestWithAPI:@"gains"
                     withParamDictionnary:@{@"sid" : [Tools safeValue:@(kUSER.sid)],
                                            @"token" : [Tools safeValue:kUSER.token],
                                            @"page" : @(self.curpage + 1)}
               completionBlockWithSuccess:^(ZSRequest *request) {
                   [ZSRequestLog requestLogWith:request];
                   
                   [self stopProgress];
                   [self endRefreshing];
                   
                   NSDictionary *dict = request.responseJSONObject;
                   
                   if ([dict[@"result"] integerValue] == 1)
                   {
                       if (self.curpage == 0)
                       {
                           [self.gainList removeAllObjects];
                       }
                       
                       NSInteger count = [dict[@"count"] integerValue];
                       
                       self.needRefreshFooter = (count >= 15);
                       
                       self.curpage = [dict[@"page"] integerValue];
                       
                       [self.gainList addObjectsFromArray:dict[@"gainlist"]];
                       
                       [self.tableView reloadData];
                   }
                   else
                   {
                       [self startProgressAutoHideWithText:dict[@"message"]];
                   }
                   
                   
               } failure:^(ZSRequest *request) {
                   [ZSRequestLog requestLogWith:request];
                   
                   [self startProgressAutoHideWithText:@"请求失败，请稍后再试。"];
                   
                   [self stopProgress];
                   [self endRefreshing];
               }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
