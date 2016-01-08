//
//  CustomerEvalutelistVC.m
//  Manager
//
//  Created by junyong.hou on 15/8/30.
//  Copyright (c) 2015年 xywy. All rights reserved.
//

#import "CustomerEvalutelistVC.h"
#import "CustomerListCell.h"
#import "CustomerDetailVC.h"
#import "EvalutelistCell.h"
#import "CusomerAddEvaluteVC.h"

@interface CustomerEvalutelistVC ()
{
    UIImageView  *iconImgView;
    UILabel      *nameLabel;
    UILabel      *phoneLabel;
    UILabel      *timeLabel;
    UIView       *topView;
    NSArray *dataArray;
    MBProgressHUD *progressHUD;
    MXYCRequest *myRequest;
}


@end

@implementation CustomerEvalutelistVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requsest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"评价列表"];
    [self setRefreshWithIsHaveHeader:YES isHaveFooter:NO];
    [self setupTopView];
    [self.tableView setViewHeight:self.tableView.viewHeight + 49];
    [self rightRefreshing];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 30);
    button.backgroundColor = [UIColor colorWithHex:BLOCK_GREEN];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(AddEvalute) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)AddEvalute
{
    CusomerAddEvaluteVC *addVC = [[CusomerAddEvaluteVC alloc] init];
    [addVC setUserDic:_userDic];
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)requsest
{
//    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    myRequest = [MXYCRequest requestInstance];
    [myRequest postStartRequestWithAPI:[NSString stringWithFormat:@"review/%@",[_userDic getStringForKey:@"uid"]] withParamDictionnary:@{@"sid":[NSNumber numberWithInteger:kUSER.sid], @"token":kUSER.token ? kUSER.token:@"",@"action":@"view"} completionBlockWithSuccess:^(ZSRequest *request) {
        [ZSRequestLog requestLogWith:request];
        NSDictionary *dic = (NSDictionary *)(request.responseJSONObject);
        [self endRefreshing];
        [progressHUD setHidden:YES];
        if ([dic[@"reviewlist"] isKindOfClass:[NSArray class]] == YES) {
            dataArray = [dic getArrayForKey:@"reviewlist"];
            [self.tableView reloadData];

            if (dataArray == nil || dataArray.count == 0) {
                [MBProgressHUD showHUDtext:[dic getStringForKey:@"message"] afterDelay:1];
            }

        }
    } failure:^(ZSRequest *request) {
        [self endRefreshing];
        [progressHUD setHidden:YES];
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
    NSLog(@"%@",[_userDic getStringForKey:@"name"]);


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

    EvalutelistCell *cell = [[EvalutelistCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return [cell setupDataDic:[dataArray objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cellName";
    EvalutelistCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[EvalutelistCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    [cell setupDataDic:[dataArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
