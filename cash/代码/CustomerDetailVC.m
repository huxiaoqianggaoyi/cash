//
//  CustomerDetailVC.m
//  Manager
//
//  Created by junyong.hou on 15/8/14.
//  Copyright (c) 2015年 xywy. All rights reserved.
//

#import "CustomerDetailVC.h"
#import "CustomerEvalutelistVC.h"
#import "CusomerAskListVC.h"
#import "CusomerBusinessListVCViewController.h"

@interface CustomerDetailVC ()
{
    UIImageView  *iconImgView;
    UILabel      *nameLabel;
    UILabel      *phoneLabel;
    UILabel      *timeLabel;
    UIView       *topView;

    NSArray *dataArray;
    NSDictionary *dataDic;
    NSDictionary *userDic;
    MBProgressHUD *progressHUD;
    MXYCRequest *myRequest;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation CustomerDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"客户详情"];

    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [_scrollView setViewHeight:_scrollView.viewHeight - 44];
    [self.view addSubview:_scrollView];

    [self requestData];
}


- (void)requestData
{
    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    myRequest = [MXYCRequest requestInstance];
    [myRequest postStartRequestWithAPI:[NSString stringWithFormat:@"customers/%@", self.customerID] withParamDictionnary:@{@"sid":[NSNumber numberWithInteger:kUSER.sid], @"token":kUSER.token ? kUSER.token:@""} completionBlockWithSuccess:^(ZSRequest *request) {
        [progressHUD setHidden:YES];
        [ZSRequestLog requestLogWith:request];

        dataDic = request.responseJSONObject;
        userDic = [dataDic getDictionaryForKey:@"userdetail"];
        [self setupRootView];
        [self setupTopView];

        if (dataDic == nil) {
            [MBProgressHUD showHUDtext:@"暂无数据" afterDelay:1];
        }
    } failure:^(ZSRequest *request) {
        [progressHUD setHidden:YES];
        [MBProgressHUD showHUDtext:@"请求数据失败数据" afterDelay:1];
        [ZSRequestLog requestLogWith:request];

    }];
}

- (void)setupRootView
{
    CGFloat viewY = 65;
    [self getupCell:@"所在地" content:[userDic getStringForKey:@"location"] isHaveArraw:NO viewY:viewY];
    viewY = viewY + 50;

    NSString *sex = @"女";
    if ([[userDic getStringForKey:@"sex"] integerValue] == 0) {
        sex = @"男";
    }
    [self getupCell:@"性别" content:sex isHaveArraw:NO viewY:viewY];
    viewY = viewY + 50;

    [self getupCell:@"注册时间" content:[Tools tinyDateString:[userDic getStringForKey:@"regdate"]] isHaveArraw:NO viewY:viewY];
    viewY = viewY + 50;

    UIButton *btn =  [self getupCell:@"当前业务编号" content:[dataDic getStringForKey:@"businessid"] isHaveArraw:NO viewY:viewY];
    viewY = viewY + 50;

    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [statusLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [statusLabel setBackgroundColor:[Tools getColor:[dataDic getIntegerForKey:@"statusvalue"]]];
    [statusLabel setTextColor:[UIColor whiteColor]];
    [statusLabel setText:[dataDic getStringForKey:@"status"]];

    [statusLabel sizeToFit];
    [statusLabel setFrame:CGRectMake(btn.viewWidth - 18 - statusLabel.viewWidth, (btn.viewHeight - statusLabel.viewHeight - 4) / 2.0, statusLabel.viewWidth + 8, statusLabel.viewHeight + 4)];
    [statusLabel setTextAlignment:NSTextAlignmentCenter];
    [btn addSubview:statusLabel];

    [self getupCell:@"推荐人" content:[userDic getStringForKey:@"refereename"] isHaveArraw:NO viewY:viewY];
    viewY = viewY + 50;

    btn = [self getupCell:@"客户评价" content:@"" isHaveArraw:YES viewY:viewY];
    viewY = viewY + 50;
    [btn addTarget:self action:@selector(pressCusCommentListVC) forControlEvents:UIControlEventTouchUpInside];

    btn = [self getupCell:@"咨询历史" content:@"" isHaveArraw:YES viewY:viewY];
    viewY = viewY + 50;
    [btn addTarget:self action:@selector(pressAskHostoryListVC) forControlEvents:UIControlEventTouchUpInside];

    btn = [self getupCell:@"业务记录" content:@"" isHaveArraw:YES viewY:viewY];
    viewY = viewY + 50;
    [btn addTarget:self action:@selector(pressRecordListVC) forControlEvents:UIControlEventTouchUpInside];

    [self.scrollView setContentSize:CGSizeMake(self.view.viewWidth, viewY)];
}

- (void)setupTopView
{
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.viewWidth, 65)];
    [self.scrollView addSubview:topView];

    iconImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [iconImgView setViewSize:CGSizeMake(40, 40)];
    [iconImgView setImage:[userDic getBoolForKey:@"sex"] == YES ? [UIImage imageNamed:@"客户男"] :[UIImage imageNamed:@"客户男"]];
    [iconImgView setViewOrigin:CGPointMake(10, 12.5)];
    [topView addSubview:iconImgView];

    nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [nameLabel setTextColor:[UIColor blackColor]];
    [nameLabel setText:[userDic getStringForKey:@"displayname"]];
    [nameLabel sizeToFit];
    [nameLabel setViewOrigin:CGPointMake(60, 12.5)];
    [topView addSubview:nameLabel];

    phoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [phoneLabel setFont:[UIFont systemFontOfSize:15]];
    [phoneLabel setTextColor:[UIColor colorWithHex:0xa0a0a0]];
    [phoneLabel setText:[userDic getStringForKey:@"mobile"]];
    [phoneLabel sizeToFit];
    [phoneLabel setViewOrigin:CGPointMake(nameLabel.viewMaxX + 5, 12.5)];
    [topView addSubview:phoneLabel];


    timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [timeLabel setFont:[UIFont systemFontOfSize:13]];
    [timeLabel setTextColor:[UIColor colorWithHex:0xa0a0a0]];
    [timeLabel setText:[NSString stringWithFormat:@"注册时间： %@",[Tools tinyDateString:[userDic getStringForKey:@"regdate"]]]];
    [timeLabel sizeToFit];
    [timeLabel setViewOrigin:CGPointMake(60, iconImgView.viewMaxY - timeLabel.viewHeight)];
    [topView addSubview:timeLabel];
    NSLog(@"%@",[userDic getStringForKey:@"name"]);


    UIButton *assionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [assionBtn setBackgroundImage:[UIImage imageNamed:@"tab_chat_normal.png"] forState:UIControlStateNormal];
    [assionBtn setFrame:CGRectMake(self.view.viewWidth - 34, 20, 24, 24)];
    [topView addSubview:assionBtn];
    [assionBtn addTarget:self action:@selector(pressAssionBtn) forControlEvents:UIControlEventTouchUpInside];
    if ([[userDic getStringForKey:@"imid"] length] < 1) {
        [assionBtn setHidden:YES];
    }

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.viewHeight - 0.5, MANAGERWIDTH, 0.5)];
    [lineView setBackgroundColor:[UIColor colorWithHex:0xd9d9d9]];
    [topView addSubview:lineView];

}


- (UIButton *)getupCell:(NSString *)title  content:(NSString *)content isHaveArraw:(BOOL)isHaveArraw viewY:(CGFloat)viewY
{

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sdfgfg"];
    [cell setFrame:CGRectMake(0, viewY, self.view.viewWidth, 50)];

    UIButton *btn = [[UIButton alloc] initWithFrame:cell.bounds];
    [cell.contentView addSubview:btn];

    if (isHaveArraw == YES) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(self.view.viewWidth - 70, 10, 60, 30);
        button.backgroundColor = [UIColor colorWithHex:BLOCK_GREEN];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 5;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"查看" forState:UIControlStateNormal];
        [cell addSubview:button];
        [cell addSubview:btn];
    }

    [self.scrollView addSubview:cell];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setText:title];
    [titleLabel sizeToFit];
    [titleLabel setViewOrigin:CGPointMake(10, (50 - titleLabel.viewHeight) / 2.0)];
    [cell addSubview:titleLabel];

    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [contentLabel setFont:[UIFont systemFontOfSize:15]];
    [contentLabel setTextColor:[UIColor colorWithHex:0x7c7c7c]];
    [contentLabel setText:content];
    [contentLabel sizeToFit];
    [contentLabel setViewOrigin:CGPointMake(110, (50 - contentLabel.viewHeight) / 2.0)];
    [cell addSubview:contentLabel];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, cell.viewHeight - 0.5, MANAGERWIDTH - 10, 0.5)];
    [lineView setBackgroundColor:[UIColor colorWithHex:0xd9d9d9]];
    [cell addSubview:lineView];

    return btn;
}

#pragma 按钮的点击事件
- (void)pressCusCommentListVC
{
    CustomerEvalutelistVC *customerEvalutelistVC = [[CustomerEvalutelistVC  alloc] init];
    [customerEvalutelistVC setUserDic:userDic];
    [self.navigationController pushViewController:customerEvalutelistVC animated:YES];
}

- (void)pressRecordListVC
{
    CusomerBusinessListVCViewController *vc = [[CusomerBusinessListVCViewController alloc] init];
    [vc setUserDic:userDic];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pressAskHostoryListVC
{
    ChatViewController *chatVC = [[ChatViewController alloc]initWithChatter:[userDic getStringForKey:@"imid"] conversationType:eConversationTypeChat];
    chatVC.user_name = [userDic getStringForKey:@"displayname"];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)pressAssionBtn
{
    ChatViewController *chatVC = [[ChatViewController alloc]initWithChatter:[userDic getStringForKey:@"imid"] conversationType:eConversationTypeChat];
    chatVC.user_name = [userDic getStringForKey:@"displayname"];
    [self.navigationController pushViewController:chatVC animated:YES];
}
@end
