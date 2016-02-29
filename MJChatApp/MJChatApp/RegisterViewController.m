//
//  RegisterViewController.m
//  MJChatApp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 麻静. All rights reserved.
//

#import "RegisterViewController.h"
#import "Manager.h"
#import "XMPPFramework.h"
@interface RegisterViewController ()<XMPPStreamDelegate>
//用户名
@property (weak, nonatomic) IBOutlet UITextField *userName;
//密码
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Manager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    
    
    // Do any additional setup after loading the view.
}

#pragma mark 注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender {
    //注册成功，自动登陆
    [[Manager shareInstance] loginWithUserName:self.userName.text passWord:self.passWord.text];
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  注册按钮响应事件

- (IBAction)registerAction:(UIButton *)sender {
    //获取用户名、密码
    NSString *name = self.userName.text;
    NSString *password = self.passWord.text;
    [[Manager shareInstance] registerWithUserName:name passWord:password];
    
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
