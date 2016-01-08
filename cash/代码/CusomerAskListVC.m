//
//  CusomerAskListVC.m
//  Manager
//
//  Created by junyong.hou on 15/8/30.
//  Copyright (c) 2015年 xywy. All rights reserved.
//

#import "CusomerAskListVC.h"
#import "CustomerListCell.h"
#import "CustomerDetailVC.h"
#import "AskCell.h"

@interface CusomerAskListVC ()
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

@implementation CusomerAskListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"咨询历史"];
    [self setRefreshWithIsHaveHeader:YES isHaveFooter:NO];
    [self setupTopView];
    [self.tableView setViewHeight:self.tableView.viewHeight + 49];
    [self rightRefreshing];
}


- (void)requsest
{
//    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    myRequest = [MXYCRequest requestInstance];
    [myRequest postStartRequestWithAPI:[NSString stringWithFormat:@"review/%@",@"3"] withParamDictionnary:@{@"sid":[NSNumber numberWithInteger:kUSER.sid], @"token":kUSER.token ? kUSER.token:@"",@"action":@"view"} completionBlockWithSuccess:^(ZSRequest *request) {
        [ZSRequestLog requestLogWith:request];
        [self endRefreshing];
        NSDictionary *dic = (NSDictionary *)(request.responseJSONObject);
        dataArray = [dic getArrayForKey:@"reviewlist"];
        [self.tableView reloadData];
        [progressHUD setHidden:YES];
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
    [iconImgView setImage:[UIImage imageNamed:@"chat_famle"]];
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
    [self requsest];
}

- (void)loadMoreData
{
    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:2];
}

#pragma mark - tableview的代理函数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;//dataArray.count;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cellName";
    AskCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[AskCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    //{
    //    "rid":220,
    //    "cusid":120,
    //    "createdate":"2015-07-22",
    //    "salesid":10,
    //    "salesdisplayname":"美国移民业务办理1001",
    //    "text":"评价1"
    //}，

    [cell setupDataDic:@{@"salesdisplayname":@"美国移民业务办理1001", @"createdate":@"2015-07-22", @"text":@"美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办美国移民业务办",}];

    //    [cell setupDataDic:[dataArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    CustomerDetailVC *businessDetaiLVC = [[CustomerDetailVC alloc] init];
//    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
//    [businessDetaiLVC setCustomerID:[dic getStringForKey:@"uid"]];
//    [self.navigationController pushViewController:businessDetaiLVC animated:YES];
}

@end
