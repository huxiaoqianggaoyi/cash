//
//  AddTrackingViewController.m
//  Manager
//
//  Created by 胡金友 on 10/19/15.
//  Copyright © 2015 xywy. All rights reserved.
//

#import "AddTrackingViewController.h"

@interface AddTrackingViewController ()

@property (retain, nonatomic) UITextView *textView;

@property (copy, nonatomic) void (^completion)(BOOL needRefresh);

@property (retain, nonatomic) NSString *tid;

@end

@implementation AddTrackingViewController

- (id)initWithID:(NSString *)tid Completion:(void (^)(BOOL))completion
{
    self = [super init];
    if (self) {
        self.completion = completion;
        self.tid = tid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 20, 120)];
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = [UIColor colorWithHex:STYLE_COLOR].CGColor;
    self.textView.layer.cornerRadius = 5;
    [self.view addSubview:self.textView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 30);
    button.backgroundColor = [UIColor colorWithHex:BLOCK_GREEN];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addTracking:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.textView becomeFirstResponder];
}

- (void)addTracking:(UIButton *)btn
{

    if (self.textView.text.length > 0)
    {
        [btn setEnabled:NO];
        [self startProgress];
        MXYCRequest *addRequest = [MXYCRequest requestInstance];
        NSString *api = [NSString stringWithFormat:@"track/%@", self.tid];
        [addRequest postStartRequestWithAPI:api
                       withParamDictionnary:@{
                                              @"sid" : @(kUSER.sid),
                                              @"token" : kUSER.token,
                                              @"action" : @"insert",
                                              @"tid" : @"0",
                                              @"text" : self.textView.text
                                              }
                 completionBlockWithSuccess:^(ZSRequest *request) {
                     
                     [self stopProgress];

                     
                     if (self.completion)
                     {
                         NSDictionary *res = request.responseJSONObject;
                         
                         if (res[@"result"] && [res[@"result"] integerValue] == 1)
                         {
                             [self startProgressAutoHideWithText:@"添加成功"];
                             
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                                 [btn setEnabled:YES];
                                 [self.navigationController popViewControllerAnimated:YES];
                                 self.completion(YES);
                             });
                         }
                         else
                         {
                             [btn setEnabled:YES];
                             [self startProgressAutoHideWithText:res[@"message"]];
                             self.completion(NO);
                         }
                     }
                     
                 } failure:^(ZSRequest *request) {
                     [btn setEnabled:YES];
                     [self stopProgress];
                     [ZSRequestLog requestLogWith:request];
                     if (self.completion)
                     {
                         self.completion(NO);
                     }
                 }];
    }
    else
    {
        [self startProgressAutoHideWithText:@"请输入内容"];
    }
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
