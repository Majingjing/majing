//
//  loadViewController.m
//  MJChatApp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 麻静. All rights reserved.
//

#import "loadViewController.h"
#import "Manager.h"
#import "XMPPFramework.h"
@interface loadViewController ()<XMPPStreamDelegate>
//用户名
@property (weak, nonatomic) IBOutlet UITextField *userName;
//密码
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation loadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"登陆";
    //添加代理
    [[Manager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Do any additional setup after loading the view.
}

#pragma mark 验证成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//登陆按钮点击事件
- (IBAction)loadAction:(UIButton *)sender {
    NSString *name = self.userName.text;
    NSString *passWord = self.passWord.text;
    //执行登陆
    [[Manager shareInstance] loginWithUserName:name passWord:passWord];
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
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
