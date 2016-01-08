//
//  BusinessSummaryViewController.m
//  Manager
//
//  Created by 胡金友 on 15/8/14.
//  Copyright (c) 2015年 xywy. All rights reserved.
//

#import "BusinessSummaryViewController.h"
#import "BusinessTableViewCell.h"
#import "BusinessDetailTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TrackingViewController.h"
#import "BusinessEditViewController.h"
#import "BussinessContentViewController.h"

@interface BusinessSummaryViewController ()

@property (retain, nonatomic) NSArray *p_typesArr;
@property (retain, nonatomic) NSDictionary *p_summaryDict;

@end

@implementation BusinessSummaryViewController

@synthesize p_typesArr = _p_typesArr;

@synthesize model = _model;

- (id)initWithModel:(BusinessListModel *)model
{
    self = [super init];
    
    if (self)
    {
        self.model = model;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"业务详情"];
    // Do any additional setup after loading the view.
    
    [self setRefreshWithIsHaveHeader:YES
                        isHaveFooter:NO];
    
    CGRect rect = self.tableView.frame;
    rect.size.height += 49;
    self.tableView.frame = rect;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 30);
    button.backgroundColor = [UIColor colorWithHex:BLOCK_GREEN];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"修改" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(editBusiness) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self rightRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#if kNeedFrom
    return section == 0 ? (self.p_summaryDict ? 1 : 0) : (self.p_summaryDict ? 11 : 0);
#else
    return section == 0 ? (self.p_summaryDict ? 1 : 0) : (self.p_summaryDict ? 10 : 0);
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *reUsefulIdentifier = @"reUsefulIdentifier-first";
        BusinessTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reUsefulIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BusinessTableViewCell class]) owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString *status = self.p_summaryDict[@"detail"][@"status"];
        
        cell.businessDateLabel.text = [Tools tinyDateString:self.p_summaryDict[@"detail"][@"createdate"]];
        cell.businessTitleLabel.text = self.p_summaryDict[@"detail"][@"title"];
        cell.businessStatusLabel.text = status;
        cell.businessStatusLabel.backgroundColor = [Tools getColor:[self.p_summaryDict[@"detail"][@"statusvalue"] integerValue]];
        
        
        cell.businessStatusLabel.hidden = !(status && status.length > 0);
        
        return cell;
    }
    
    static NSString *reUsefulIdentify = @"reUsefulIdentifier-second";
    BusinessDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reUsefulIdentify];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BusinessDetailTableViewCell class]) owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailIcon.hidden = YES;
    }
    
    NSDictionary *tempDict = [self.p_typesArr objectAtIndex:indexPath.row];
    
#if kNeedFrom
    if (indexPath.row > 8)
#else
    if (indexPath.row > 7)
#endif
    {
       

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(self.view.viewWidth - 70, 10, 60, 30);
        button.backgroundColor = [UIColor colorWithHex:BLOCK_GREEN];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 5;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"查看" forState:UIControlStateNormal];
        [cell addSubview:button];

        cell.detailContent.hidden = YES;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.detailClass.text = [[tempDict allValues] firstObject];
    
#if kNeedFrom
    if (indexPath.row <= 8)
#else
    if (indexPath.row <= 7)
#endif
    {
        NSString *ct = [NSString stringWithFormat:@"%@", self.p_summaryDict[@"detail"][[tempDict.allKeys firstObject]]];
#if kNeedFrom
        if (indexPath.row == 4)
#else
        if (indexPath.row == 3)
#endif
        {
            ct = [Tools tinyDateString:ct];
        }
#if kNeedFrom
        if (indexPath.row >= 6 && indexPath.row <= 8)
#else
        if (indexPath.row >= 5 && indexPath.row <= 7)
#endif
        {
            ct = [NSString stringWithFormat:@"%.2f", [ct floatValue]];
        }
        
        cell.detailContent.text = ct;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? 60 : 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#if kNeedFrom
    if (indexPath.row == 9)
#else
    if (indexPath.row == 8)
#endif
    {
        BussinessContentViewController *contentVC = [[BussinessContentViewController alloc] init];
        contentVC.content = self.p_summaryDict[@"detail"][@"text"];
        [self.navigationController pushViewController:contentVC animated:YES];
    }
#if kNeedFrom
    else if (indexPath.row == 10)
#else
    else if (indexPath.row == 9)
#endif
    {
        TrackingViewController *tvc = [[TrackingViewController alloc] initWithBusinessDetail:self.p_summaryDict];
        [self.navigationController pushViewController:tvc animated:YES];
    }
}

- (void)setModel:(BusinessListModel *)model
{
    if (model)
    {
        _model = model;
    }
}

- (void)fetchRecord
{
    [self startProgress];
    
    NSDictionary *params = @{@"uid" : @(_model.uid),
                             @"token" : kUSER.token,
                             @"action" : @"view",
                             @"sid" : @(_model.sid)
                             };
    MXYCRequest *request = [MXYCRequest requestInstance];
    [request postStartRequestWithAPI:[NSString stringWithFormat:@"business/%zd",_model.bid]
                withParamDictionnary:params
          completionBlockWithSuccess:^(ZSRequest *request) {
              
              [self endRefreshing];
              [self stopProgress];
              
              NSDictionary *result = request.responseJSONObject;
              
              if ([result[@"result"] integerValue] == 1)
              {
                  self.p_summaryDict = result;
                  
                  [self.tableView reloadData];
              }
              else
              {
                  [self startProgressAutoHideWithText:result[@"message"]];
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [self.navigationController popViewControllerAnimated:YES];
                  });
              }
              
              [ZSRequestLog requestLogWith:request];
              
              
          } failure:^(ZSRequest *request) {
              [self endRefreshing];
              [ZSRequestLog requestLogWith:request];
              
              [self startProgressAutoHideWithText:@"请求数据失败，请稍后再试。"];
              
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  [self.navigationController popViewControllerAnimated:YES];
              });
              
              [self stopProgress];
          }];
}

- (NSArray *)p_typesArr
{
    if (!_p_typesArr)
    {
        _p_typesArr = @[@{@"cusname" : @"客户姓名"},
                        @{@"businessid" : @"业务编号"},
                        @{@"contractid" : @"合同编号"},
#if kNeedFrom
                        @{@"channelname" : @"来源"},
#endif
                        @{@"createdate" : @"签订时间"},
                        @{@"refereename" : @"推荐人"},
                        @{@"amount" : @"总金额"},
                        @{@"saleamount" : @"业务员提成"},
                        @{@"refereeamount" : @"推荐人提成"},
                        @{@"text" : @"合同内容"},
                        @{@"saledetail" : @"跟踪记录"}];
    }
    
    return _p_typesArr;
}

- (void)loadNewData
{
    [self fetchRecord];
}

- (void)editBusiness
{
    BusinessEditViewController *editVC = [[BusinessEditViewController alloc] initWithType:BusinessTypeEdit];
    
    editVC.businessDict = self.p_summaryDict[@"detail"];
    editVC.uid = [self.p_summaryDict[@"detail"][@"uid"] integerValue];
    
    [self.navigationController pushViewController:editVC animated:YES];
}

- (NSString *)safeValue:(id)value
{
    if (value)
    {
        if ([value isKindOfClass:[NSString class]])
        {
            NSString *str = (NSString *)value;
            
            if (str.length > 0)
            {
                return str;
            }
        }
        
        if ([value isKindOfClass:[NSNumber class]])
        {
            return value;
        }
    }
    
    return @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
