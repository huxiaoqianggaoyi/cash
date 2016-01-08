//
//  BusinessEditViewController.m
//  Manager
//
//  Created by 胡金友 on 15/9/8.
//  Copyright (c) 2015年 xywy. All rights reserved.
//

#import "BusinessEditViewController.h"
#import "BusinessEditingTableViewCell.h"
#import "BusinessSelector.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSDictionary+IsExitKey.h"
#import "UITextField+Helper.h"
#import "UITextView+Helper.h"
#import "CustomTextView.h"

@interface BusinessEditViewController ()

@property (assign, nonatomic) BusinessType p_type;

@property (retain, nonatomic) AUUPopView *statusPop;

@property (retain, nonatomic) AUUPopView *comesPop;

@property (retain, nonatomic) NSArray *titlesArr;

@property (retain, nonatomic) NSMutableDictionary *p_businessDict;

@property (retain, nonatomic) NSArray *p_rekeys;

@property (retain, nonatomic) NSArray *statusArr;

@property (retain, nonatomic) NSArray *channelsArr;

@property (assign, nonatomic) NSInteger selStatusRow;

@property (assign, nonatomic) NSInteger selChannelsRow;

@end

@implementation BusinessEditViewController

- (id)initWithType:(BusinessType)type
{
    self = [super init];
    
    if (self)
    {
        self.uid = 0;
        self.p_type = type;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"业务"];
    // Do any additional setup after loading the view.
    
#if kNeedFrom
    self.titlesArr = @[@"客户姓名", @"客户手机", @"合同编号", @"合同标题", @"状态", @"推荐人手机", @"推荐人姓名", @"总金额", @"销售提成", @"推荐人提成", @"来源版块", @"合同内容"];
    self.p_rekeys = [NSArray arrayWithObjects:@"cusname", @"mobile", @"contractid", @"title", @"statusid", @"refereemobile", @"refereename", @"amount", @"saleamount", @"refereeamount", @"channelid", @"text", nil];
#else
                       /*   0        1              2          3        4           5            6            7           8             9            10*/
    self.titlesArr = @[@"客户姓名", @"客户手机", @"合同编号", @"合同标题", @"状态", /*@"推荐人手机", @"推荐人姓名", */@"总金额", @"业务员提成",/* @"推荐人提成", */@"合同内容"];
    self.p_rekeys = [NSArray arrayWithObjects:@"cusname", @"mobile", @"contractid", @"title", @"statusid",/* @"refereemobile", @"refereename", */@"amount", @"saleamount", /*@"refereeamount",*/ @"text", nil];
#endif
    
    self.selStatusRow = -1;
    self.selChannelsRow = -1;
    
    
    self.tableView.height += 49;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 64, 30);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitle:@"保存" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithHex:BLOCK_GREEN]];
    [button addTarget:self action:@selector(saveBusiness) forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self fetchItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyborardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#if kNeedFrom
    return 12;
#else
    return 8;
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if kNeedFrom
    if (indexPath.row == 11)
#else
    if (indexPath.row == 7)
#endif
    {
        static NSString *reUsefulIdentifier = @"reUsefulIdentifier_signale";
        
        BusinessEditingTableViewCell *ecell = [tableView dequeueReusableCellWithIdentifier:reUsefulIdentifier];
        
        if (!ecell)
        {
            ecell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BusinessEditingTableViewCell class])
                                                   owner:self options:nil] lastObject];
            CGRect rect = ecell.editedContentTF.frame;
            [ecell.editedContentTF removeFromSuperview];
            CustomTextView *textView = [[CustomTextView alloc] initWithFrame:rect];
            textView.frame = CGRectMake(rect.origin.x, 5,
                                        self.view.width - rect.origin.x - 10, 96 - 10);
            [ecell addSubview:textView];
            
            [textView textChanged:^(NSString *str, UITextView *textView) {
                if (str.length > 0)
                {
                    [self.p_businessDict setObject:str forKey:self.p_rekeys[indexPath.row]];
                }
            }];
            
            textView.text = [NSString stringWithFormat:@"%@", [Tools safeValue:[self.p_businessDict objectForKey:[self.p_rekeys objectAtIndex:indexPath.row]]]];
            
            ecell.summaryTitle.text = [self.titlesArr objectAtIndex:indexPath.row];
        }
        
        return ecell;
    }
    
    static NSString *reUsefulIdentifier = @"reUsefulIdentifier";
    
    BusinessEditingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reUsefulIdentifier];
    
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BusinessEditingTableViewCell class]) owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    BOOL selRow = (indexPath.row == 4);
    cell.arrowImageView.hidden = !selRow;
    cell.editedContentTF.enabled = !selRow;
    
    cell.summaryTitle.text = [self.titlesArr objectAtIndex:indexPath.row];
    
    if (indexPath.row == 1 || indexPath.row == 5 || indexPath.row == 6)
    {

        cell.editedContentTF.keyboardType = UIKeyboardTypeDecimalPad;
    }
    else
    {
        cell.editedContentTF.keyboardType = UIKeyboardTypeNamePhonePad;
    }
    
    if (!selRow)
    {
#if kNeedFrom
        if (indexPath.row != 11)
#else
        if (indexPath.row != 7)
#endif
        {
            cell.indexPath = indexPath;
            
            [cell.editedContentTF textChanged:^(NSString *str, UITextField *textField) {
                
                NSIndexPath *ind = [tableView indexPathForRowAtPoint:[textField convertRect:textField.frame toView:self.tableView].origin];
                
                void (^refreshMoney)() = ^(){
                    
                    if (ind.row == 5)
                    {
                        CGFloat rate = 0.18;
                        
                        if (kUSER.rate)
                        {
                            rate = kUSER.rate;
                        }
                        
                        CGFloat earnMoney = [str  floatValue] * rate;
                        NSString *earnString = [NSString stringWithFormat:@"%.2f",earnMoney];
                        [self.p_businessDict setObject:earnString forKey:self.p_rekeys[6]];
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                };
                
                if (str && str.length > 0)
                {
                    [self.p_businessDict setObject:str forKey:self.p_rekeys[ind.row]];
                }
                
                refreshMoney();
            }];
        }
    }
    else
    {
        cell.arrowImageView.hidden = NO;
        cell.arrowImageView.backgroundColor = [UIColor clearColor];
        cell.arrowImageView.image = [UIImage imageNamed:@"arrow_down"];
    }
    
    if (indexPath.row == 4)
    {
        if (self.selStatusRow != -1)
        {
            NSDictionary *dict = self.statusArr[self.selStatusRow];
            cell.editedContentTF.text = dict[@"status"];
        }
        else if (self.statusArr.count > 0)
        {
            for (NSDictionary *d in self.statusArr)
            {
                if ([d[@"statusid"] integerValue] == [self.p_businessDict[@"statusid"] integerValue])
                {
                    cell.editedContentTF.text = d[@"status"];
                    
                    break;
                }
            }
        }
    }
#if kNeedFrom
    else if (indexPath.row == 7)
    {
        if (self.selChannelsRow != -1)
        {
            NSDictionary *dict = self.channelsArr[self.selChannelsRow];
            cell.editedContentTF.text = dict[@"title"];
        }
        else if (self.channelsArr.count > 0)
        {
            for (NSDictionary *d in self.channelsArr)
            {
                if ([d[@"id"] integerValue] == [self.p_businessDict[@"channelid"] integerValue])
                {
                    cell.editedContentTF.text = d[@"title"];
                    
                    break;
                }
            }
        }
    }
#endif
    else
    {
        NSString *dkey = [self.p_rekeys objectAtIndex:indexPath.row];
        
        if (indexPath.row == 1)
        {
            NSString *realValue = [NSString stringWithFormat:@"%@", [Tools safeValue:[self.p_businessDict objectForKey:dkey]]];
            
            if ([realValue isEqualToString:@""])
            {
                realValue = [NSString stringWithFormat:@"%@", [Tools safeValue:[self.p_businessDict objectForKey:@"cusmobile"]]];
            }
            
            cell.editedContentTF.text = realValue;
            
            [self.p_businessDict setObject:realValue forKey:dkey];
        }
        else
        {
            cell.editedContentTF.text = [NSString stringWithFormat:@"%@", [Tools safeValue:[self.p_businessDict objectForKey:dkey]]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if kNeedFrom
    if (indexPath.row == 11)
#else
    if (indexPath.row == 7)
#endif
    {
        return 96;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4)
    {
        [self.view endEditing:YES];
        
        [self.statusPop show];
    }
#if kNeedFrom
    if (indexPath.row == 7)
    {
        [self.view endEditing:YES];
        
        [self.comesPop show];
    }
#endif
}

- (AUUPopView *)statusPop
{
    if (!_statusPop)
    {
        BusinessSelector *selector = [[BusinessSelector alloc] init];
        [selector setItemSource:self.statusArr];
        selector.selType = SelectorTypeStatus;
        _statusPop = [[AUUPopView alloc] initWithWidget:selector position:AUUPopViewPositionBottom];
        
        [selector itemSelected:^(NSInteger index) {
            
            if (index != -1)
            {
                self.selStatusRow = index;
                
                NSDictionary *dict = self.statusArr[index];
                [self.p_businessDict setObject:dict[@"statusid"] forKey:self.p_rekeys[4]];
                
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
            
            [_statusPop hide];
        }];
    }
    
    return _statusPop;
}

- (AUUPopView *)comesPop
{
    if (!_comesPop)
    {
        BusinessSelector *selector = [[BusinessSelector alloc] init];
        [selector setItemSource:self.channelsArr];
        selector.selType = SelectorTypeChannel;
        _comesPop = [[AUUPopView alloc] initWithWidget:selector position:AUUPopViewPositionBottom];
        
        [selector itemSelected:^(NSInteger index) {
            
            if (index != -1)
            {
                self.selChannelsRow = index;
                
                NSDictionary *dict = self.channelsArr[index];
                [self.p_businessDict setObject:dict[@"id"] forKey:self.p_rekeys[7]];
                
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:7 inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
            
            [_comesPop hide];
        }];
    }
    
    return _comesPop;
}

- (void)saveBusiness
{
#if kNeedFrom
    NSInteger keys  = 12;
#else
    NSInteger keys = 8;
#endif
    if (!self.p_businessDict[@"refereemobile"])
    {
#if kNeedFrom
        keys = 11;
#else
        keys = 7;
#endif
    }
    if (!self.p_businessDict[@"refereename"])
    {
#if kNeedFrom
        keys = 10;
#else
        keys = 6;
#endif
    }
    
    if ([self.p_businessDict allKeys].count < keys)
    {
        [self startProgressAutoHideWithText:@"请检查是否有未填入的数据。"];
        
        return;
    }
    
    for (NSString *key in self.p_rekeys)
    {
        if (!self.p_businessDict[key])
        {
            [self startProgressAutoHideWithText:@"提交失败，请检查是否有未填入的数据。"];
            
            return;
        }
    }
    [self.p_businessDict setObject:@"" forKey:@"refereemobile"];
    [self.p_businessDict setObject:@"" forKey:@"refereename"];
    [self.p_businessDict setObject:@"0" forKey:@"refereeamount"];

    [self startProgress];
    
    [self.view endEditing:YES];
    
    MXYCRequest *request = [MXYCRequest requestInstance];
    
    [self.p_businessDict setObject:[NSString stringWithFormat:@"%@", [Tools safeValue:kUSER.token]]
                            forKey:@"token"];
    [self.p_businessDict setObject:[NSString stringWithFormat:@"%zd", kUSER.sid]
                            forKey:@"sid"];
    [self.p_businessDict setObject:self.p_type == BusinessTypeNew ? @"insert" : @"update" forKey:@"action"];
    
    if (self.p_type != BusinessTypeNew)
    {
        [self.p_businessDict setObject:@(self.uid) forKey:@"uid"];
    }

    NSString *api = @"bizlist";
    
    if (self.p_type != BusinessTypeNew)
    {
        api = [api stringByAppendingFormat:@"/%@", self.businessDict[@"bid"]];
    }
    
    [request postStartRequestWithAPI:api
                withParamDictionnary:self.p_businessDict
          completionBlockWithSuccess:^(ZSRequest *request) {
              
        [ZSRequestLog requestLogWith:request];
        [self stopProgress];
        
        NSInteger statusCode = [request.responseJSONObject[@"result"] integerValue];
        
        if (statusCode == 1)
        {
            [Tools shareTool].needBusilistRefresh = YES;
            
            [self startProgressAutoHideWithText:self.p_type == BusinessTypeNew ? @"添加成功" : @"修改成功"];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self startProgressAutoHideWithText:request.responseJSONObject[@"message"]];
        }
        
    } failure:^(ZSRequest *request) {
        [ZSRequestLog requestLogWith:request];
        [self stopProgress];
        
        [self startProgressAutoHideWithText:self.p_type == BusinessTypeNew ? @"添加失败" : @"修改失败"];
    }];
}

- (void)setBusinessDict:(NSDictionary *)businessDict
{
    if (businessDict)
    {
        _businessDict = businessDict;
        
        [self.p_businessDict removeAllObjects];
        
        for (NSString *key in [businessDict allKeys])
        {
            [self.p_businessDict setObject:[businessDict objectForKey:key] forKey:key];
        }
        
        [self.tableView reloadData];
    }
}

- (NSMutableDictionary *)p_businessDict
{
    if (!_p_businessDict)
    {
        _p_businessDict = [[NSMutableDictionary alloc] init];
    }
    
    return _p_businessDict;
}

- (void)fetchItems
{
    [self startProgress];
    
    MXYCRequest *request = [MXYCRequest requestInstance];
    
    [request getStartRequestWithAPI:@"status" withParamDictionnary:nil completionBlockWithSuccess:^(ZSRequest *request) {
        [ZSRequestLog requestLogWith:request];
#if kNeedFrom
        [self fetchChannels];
#else
        [self  stopProgress];
#endif
        if ([request.responseJSONObject isKindOfClass:[NSArray class]])
        {
            self.statusArr = request.responseJSONObject;
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        
    } failure:^(ZSRequest *request) {
        [self stopProgress];
    }];
}
#if kNeedFrom
- (void)fetchChannels
{
    MXYCRequest *request = [MXYCRequest requestInstance];
    
    [request getStartRequestWithAPI:@"channels" withParamDictionnary:nil completionBlockWithSuccess:^(ZSRequest *request) {
        [ZSRequestLog requestLogWith:request];
        
        if ([request.responseJSONObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = request.responseJSONObject;

            self.channelsArr = [dic getArrayForKey:@"channellist"];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:10 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        
        [self stopProgress];
    } failure:^(ZSRequest *request) {
        [ZSRequestLog requestLogWith:request];
        
        [self stopProgress];
    }];
}
#endif
- (id)getFirstResponderInView:(UIView *)contentView
{
    for (id view in contentView.subviews)
    {
        if ([view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UITextField class]])
        {
            if ((BOOL)[view isFirstResponder])
            {
                return view;
            }
        }
        else if ([[view subviews] count] > 0)
        {
            id v = [self getFirstResponderInView:view];
            
            if (v)
            {
                return v;
            }
        }
    }
    
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillShowNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillHideNotification];
}

- (void)keyborardWillShow:(NSNotification *)notification
{
    NSDictionary *obj = [notification userInfo];
    NSValue *value = [obj objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [value CGRectValue];
    NSLog(@"%@ , %@", NSStringFromCGRect(rect), notification);
    self.tableView.height = self.baseTableViewHeight - rect.size.height + 49;
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tableView.height = self.baseTableViewHeight + 49;
}

@end
