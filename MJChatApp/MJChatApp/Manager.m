//
//  Manager.m
//  MJChatApp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 麻静. All rights reserved.
//

#import "Manager.h"

typedef enum: NSUInteger {
    ConnectPurposeRegister,
    ConnectPurposeLogin,
    c,
}ConnectPurpose;







@interface Manager ()<XMPPStreamDelegate, XMPPRosterDelegate, XMPPMessageArchivingStorage>
@property (nonatomic, copy)NSString *registerPassWord;
@property (nonatomic, copy)NSString *loginPassWord;
//用来记录链接服务器的目的
@property (nonatomic)ConnectPurpose connectPurpose;

@end





static Manager *manager = nil;
@implementation Manager

+(instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[Manager alloc] init];
    });
    return manager;
}

//再写属性的话，不能在shareInstance里写，需要重写init
//初始化相关属性
-(instancetype)init {
    self = [super init];
    if (self) {
        //对通信管道进行初始化
        self.xmppStream = [[XMPPStream alloc] init];
        //设置相关参数
        _xmppStream.hostName = kHostName;
        _xmppStream.hostPort = kHostPort;
        //添加代理
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        //对花名册进行初始化 并进行相关设置
        
        //花名册数据管理助手
        self.coreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        
        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.coreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活通信管道
        [self.xmppRoster activate:self.xmppStream];
        //添加代理
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        //初始化聊天消息类并设置相关参数
        XMPPMessageArchivingCoreDataStorage *messagecoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messagecoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        
        [self.messageArchiving activate:self.xmppStream];
        [self.messageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        self.context = messagecoreDataStorage.mainThreadManagedObjectContext;
    }
    return self;
}



#pragma mark 连接服务器

- (void)connectTosrver {
    if ([self.xmppStream isConnected]) {
        //如果当前已经有链接，先断开当前链接，再建立新的链接
        
        //设置用户状态为下线
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable" to:self.xmppStream.myJID];
        [self.xmppStream sendElement:presence];
        
        [self.xmppStream disconnect];
        
    }
    NSError *error = nil;
    //链接服务器
   BOOL result = [self.xmppStream connectWithTimeout:20.f error:&error];
    if (!result) {
        //链接有错
        NSLog(@"错误信息：%@", error);
    }
}


#pragma mark 注册
-(void)registerWithUserName:(NSString *)name passWord:(NSString *)passWord {
    //链接服务器的目的是注册
    self.connectPurpose = ConnectPurposeRegister;
    //创建一个账号
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
    NSLog(@"%@", jid);
    
    self.xmppStream.myJID = jid;
    
    //保存注册密码
    self.registerPassWord = passWord;
    
    //向服务器发起链接请求
    [self connectTosrver];
    
}

#pragma mark 登陆
-(void)loginWithUserName:(NSString *)name passWord:(NSString *)passWord {
    
    //链接服务器的目的是登陆
    self.connectPurpose = ConnectPurposeLogin;
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
    self.xmppStream.myJID = jid;
    self.loginPassWord = passWord;
    [self connectTosrver];
}


#pragma mark XMPPStreamDelegate

#pragma mark 链接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"链接成功");
    //判断是注册还是登陆
    switch (self.connectPurpose) {
        case ConnectPurposeRegister: {
            //注册
            NSError *error = nil;
            //验证
            [self.xmppStream registerWithPassword:self.registerPassWord error:&error];
            if (error) {
                NSLog(@"注册验证error：%@", error);
            }
            break;
        }
        case ConnectPurposeLogin: {
            //登陆
            NSError *error = nil;
            //验证
            [self.xmppStream authenticateWithPassword:self.loginPassWord error:&error];
            if (error) {
                NSLog(@"登陆验证error：%@", error);
            }

            break;
        }
            
        default:
            break;
    }
}

#pragma mark 链接超时
-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    NSLog(@"链接超时");
}

#pragma mark 链接丢失
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"断开连接");
}

#pragma mark 注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"注册成功");
}
#pragma mark 验证成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"验证成功");
    //设置用户当前状态为上线（上线available， 下线unavailable）
//    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available" to:self.xmppStream.myJID];
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:presence];
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    NSLog(@"注册失败");
}
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"登陆失败");
}

#pragma mark  接收到好友请求
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    NSLog(@"接收到好友请求");
}

@end
