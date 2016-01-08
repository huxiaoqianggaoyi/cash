//
//  TrackingViewController.m
//  Manager
//
//  Created by 胡金友 on 15/9/7.
//  Copyright (c) 2015年 xywy. All rights reserved.
//

#import "TrackingViewController.h"
#import "BusinessTableViewCell.h"
#import "TrackingTableViewCell.h"
#import "BusinessEditViewController.h"
#import "AddTrackingViewController.h"

static NSString *tracklist = @"tracklist";

@interface TrackingViewController ()

@property (retain, nonatomic) NSDictionary *businessDict;

@property (retain, nonatomic) MXYCRequest *request;

@property (retain, nonatomic) NSDictionary *trackingDict;

@end

@implementation TrackingViewController

- (id)initWithBusinessDetail:(NSDictionary *)dict
{
    self = [super init];
    
    if (self)
    {
        self.businessDict = dict;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"记录列表"];

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

    // Do any additional setup after loading the view.
    
    [self setRefreshWithIsHaveHeader:YES isHaveFooter:NO];
    
    self.tableView.height += 49;
    
    [self fetchTracking];
}
- (void)addBusiness
{
    AddTrackingViewController *atv = [[AddTrackingViewController alloc] initWithID:self.businessDict[@"detail"][@"bid"]
                                                                        Completion:^(BOOL needRefresh) {
                                                                            if (needRefresh)
                                                                            {
                                                                                [self rightRefreshing];
                                                                            }
                                                                        }];
    [self.navigationController pushViewController:atv animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *trackingList = self.trackingDict[tracklist];
    
    if (trackingList && [trackingList isKindOfClass:[NSArray  class]])
    {
        return 1 + trackingList.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        static NSString *reUsefulIdentifier = @"reUsefulIdentifier";
        
        BusinessTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reUsefulIdentifier];
        
        if (!cell)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BusinessTableViewCell class]) owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString *status = self.trackingDict[@"status"];
        
        cell.businessTitleLabel.text = self.trackingDict[@"title"];
        cell.businessDateLabel.text = [Tools tinyDateString:self.trackingDict[@"createdate"]];
        cell.businessStatusLabel.text = status;
        cell.businessStatusLabel.backgroundColor = [Tools getColor:[self.trackingDict[@"statusvalue"] integerValue]];
        
        cell.businessStatusLabel.hidden = !(status && status.length > 0);
        
        return cell;
    }
    
    static NSString *reUsefulIdentifierTrack = @"reUsefulIdentifierTrack";
    
    TrackingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reUsefulIdentifierTrack];
    
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TrackingTableViewCell class]) owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *tempDict = [self.trackingDict[tracklist] objectAtIndex:indexPath.row - 1];
    
    cell.trackingTitleLabel.text = tempDict[@"salesdisplayname"];
    cell.trackingDateLabel.text = [Tools tinyDateString:tempDict[@"createdate"]];
    cell.trackingContentLabel.text = tempDict[@"text"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 60;
    }
    
    NSDictionary *tempDict = [self.trackingDict[tracklist] objectAtIndex:indexPath.row - 1];
    CGSize size = [tempDict[@"text"] boundingRectWithSize:CGSizeMake(MANAGERWIDTH - 16, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size;
    
    return 37 + 8 + size.height;
}

- (void)fetchTracking
{
    [self startProgress];
    
    [self.request postStartRequestWithAPI:[NSString stringWithFormat:@"track/%@", self.businessDict[@"detail"][@"bid"]]
                     withParamDictionnary:@{@"sid" : self.businessDict[@"saledetail"][@"sid"],
                                            @"token" : kUSER.token,
                                            @"tid" : @"0"}
               completionBlockWithSuccess:^(ZSRequest *request) {
                   [self endRefreshing];
                   [ZSRequestLog requestLogWith:request];
                   
                   self.trackingDict = request.responseJSONObject;
                   
                   [self.tableView reloadData];
                   
                   [self stopProgress];
    } failure:^(ZSRequest *request) {
        [ZSRequestLog requestLogWith:request];
        [self endRefreshing];
        [self stopProgress];
    }];
}

- (MXYCRequest *)request
{
    if (!_request)
    {
        _request = [MXYCRequest requestInstance];
    }
    
    return _request;
}

- (void)loadNewData
{
    [self fetchTracking];
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
