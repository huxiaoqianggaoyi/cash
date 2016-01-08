//
//  CusomerBusinessListVCViewController.m
//  Manager
//
//  Created by junyong.hou on 15/9/2.
//  Copyright (c) 2015年 xywy. All rights reserved.
//

#import "CusomerBusinessListVCViewController.h"
#import "BusinessListTableViewCell.h"
#import "CusomerRecordCell.h"
#import "BusinessSummaryViewController.h"
#import "BusinessEditViewController.h"

@interface CusomerBusinessListVCViewController ()
{
    UIImageView  *iconImgView;
    UILabel      *nameLabel;
    UILabel      *phoneLabel;
    UILabel      *timeLabel;
    UIView       *topView;
    NSInteger    page;

    NSMutableArray *dataArray;
    MBProgressHUD *progressHUD;
    MXYCRequest *myRequest;

}
@end

@implementation CusomerBusinessListVCViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self rightRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [[NSMutableArray alloc] init];

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

    [self setTitle:@"业务记录"];
    [self setRefreshWithIsHaveHeader:YES isHaveFooter:NO];
    [self setupTopView];
    [self.tableView setViewHeight:self.tableView.viewHeight + 49];
}

- (void)addBusiness
{
    BusinessEditViewController *editVC = [[BusinessEditViewController alloc] initWithType:BusinessTypeNew];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[_userDic getStringForKey:@"displayname"] forKey:@"cusname"];
    [dic setObject:[_userDic getStringForKey:@"mobile"] forKey:@"cusmobile"];
    [editVC setBusinessDict:dic];

    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)requsest
{
    myRequest = [MXYCRequest requestInstance];
    [myRequest postStartRequestWithAPI:@"business" withParamDictionnary:@{@"sid":[NSNumber numberWithInteger:kUSER.sid], @"token":kUSER.token ? kUSER.token:@"",@"uid":[_userDic getStringForKey:@"uid"],@"action":@"view",@"page":[NSString stringWithFormat:@"%ld",page]} completionBlockWithSuccess:^(ZSRequest *request) {
        [ZSRequestLog requestLogWith:request];
        NSDictionary *dic = (NSDictionary *)(request.responseJSONObject);

        if (page == 1) {
            [dataArray removeAllObjects];
        }
        [dataArray addObjectsFromArray:[dic getArrayForKey:@"businesslist"]];

        [self.tableView reloadData];
        [progressHUD setHidden:YES];

        [self endRefreshing];
        
        if (dataArray.count > 0 && dataArray.count < [dic getIntegerForKey:@"count"]) {
            [self setRefreshWithIsHaveHeader:YES isHaveFooter:YES];
        } else {
            [self setRefreshWithIsHaveHeader:YES isHaveFooter:NO];
        }
    } failure:^(ZSRequest *request) {
        [progressHUD setHidden:YES];
        [self endRefreshing];
        [MBProgressHUD showHUDtext:@"请求数据失败数据" afterDelay:1];

    }];
}

- (void)setupTopView
{
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.viewWidth, 65)];
    [topView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setTableHeaderView:topView];

    iconImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [iconImgView setViewSize:CGSizeMake(40, 40)];
    [iconImgView setImage:[_userDic getBoolForKey:@"sex"] == YES ? [UIImage imageNamed:@"客户男"] :[UIImage imageNamed:@"客户男"]];
    [iconImgView setViewOrigin:CGPointMake(10, 12.5)];
    [topView addSubview:iconImgView];

    nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [nameLabel setTextColor:[UIColor blackColor]];
    [nameLabel setText:[_userDic getStringForKey:@"displayname"]];
    [nameLabel sizeToFit];
    [nameLabel setViewOrigin:CGPointMake(60, 12.5)];
    [topView addSubview:nameLabel];

    phoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [phoneLabel setFont:[UIFont systemFontOfSize:15]];
    [phoneLabel setTextColor:[UIColor colorWithHex:0xa0a0a0]];
    [phoneLabel setText:[_userDic getStringForKey:@"mobile"]];
    [phoneLabel sizeToFit];
    [phoneLabel setViewOrigin:CGPointMake(nameLabel.viewMaxX + 5, 12.5)];
    [topView addSubview:phoneLabel];


    timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [timeLabel setFont:[UIFont systemFontOfSize:13]];
    [timeLabel setTextColor:[UIColor colorWithHex:0xa0a0a0]];
    [timeLabel setText:[NSString stringWithFormat:@"注册时间： %@",[Tools tinyDateString:[_userDic getStringForKey:@"regdate"]]]];
    [timeLabel sizeToFit];
    [timeLabel setViewOrigin:CGPointMake(60, iconImgView.viewMaxY - timeLabel.viewHeight)];
    [topView addSubview:timeLabel];



    UIButton *assionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [assionBtn setBackgroundImage:[UIImage imageNamed:@"tab_chat_normal.png"] forState:UIControlStateNormal];
    [assionBtn setFrame:CGRectMake(self.view.viewWidth - 34, 20, 24, 24)];
    [topView addSubview:assionBtn];
    [assionBtn addTarget:self action:@selector(pressAssionBtn) forControlEvents:UIControlEventTouchUpInside];
    if ([[_userDic getStringForKey:@"imid"] length] < 1) {
        [assionBtn setHidden:YES];
    }

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.viewHeight - 0.5, MANAGERWIDTH, 0.5)];
    [lineView setBackgroundColor:[UIColor colorWithHex:0xd9d9d9]];
    [topView addSubview:lineView];

}

- (void)setupRightBarButtonItems
{
    [self.navigationItem setTitle:@""];
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pressAddVC)];
    [self.navigationItem setRightBarButtonItem:addBtn];
}

- (void)pressAddVC
{
   
}

- (void)pressAssionBtn
{
    ChatViewController *chatVC = [[ChatViewController alloc]initWithChatter:[_userDic getStringForKey:@"imid"] conversationType:eConversationTypeChat];
    chatVC.user_name = [_userDic getStringForKey:@"displayname"];
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - 刷新数据
- (void)loadNewData
{
    page = 1;
    [self requsest];
}

- (void)loadMoreData
{
    page ++;
    [self requsest];
}

#pragma mark - tableview的代理函数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reUsefulIdentifier = @"reUsefulIdentifier";

    CusomerRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:reUsefulIdentifier];

    if (!cell)
    {
        cell = [[CusomerRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reUsefulIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setupDataDic:[dataArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];

    BusinessListModel *model = [[BusinessListModel alloc] init];
    [model setSalename:[dic getStringForKey:@"salename"]];
    [model setUid:[dic getIntegerForKey:@"uid"]];
    [model setBusinessid:[dic getStringForKey:@"businessid"]];
    [model setStatusid:[dic getIntegerForKey:@"statusid"]];
    [model setContractid:[dic getStringForKey:@"contractid"]];
    [model setCreatedate:[dic getStringForKey:@"createdate"]];
    [model setCusname:[dic getStringForKey:@"cusname"]];
    [model setSid:[dic getIntegerForKey:@"sid"]];
    [model setBid:[dic getIntegerForKey:@"bid"]];
    [model setStatus:[dic getStringForKey:@"status"]];
    [model setStatusvalue:[dic getIntegerForKey:@"statusvalue"]];
    [model setTitle:[dic getStringForKey:@"title"]];

    BusinessSummaryViewController *summaryVC = [[BusinessSummaryViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:summaryVC animated:YES];
}

@end
