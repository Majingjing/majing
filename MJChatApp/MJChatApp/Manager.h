//
//  Manager.h
//  MJChatApp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 麻静. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@interface Manager : NSObject



//通信管道
@property (nonatomic, strong)XMPPStream *xmppStream;
//好友花名册
@property (nonatomic, strong)XMPPRoster *xmppRoster;
@property (nonatomic, strong)XMPPRosterCoreDataStorage *coreDataStorage;

//聊天消息类
@property (nonatomic, strong)XMPPMessageArchiving *messageArchiving;

//被管理对象上下文
@property (nonatomic, strong)NSManagedObjectContext *context;

/**
 * 单例
 **/
+ (instancetype)shareInstance;


/**
 *@param name 用户名
 *@param passWord 密码
 *注册
 **/

- (void)registerWithUserName:(NSString *)name
                    passWord:(NSString *)passWord;
/*
 *登陆
 *@param name 用户名
 *@param passWord 密码
 **/

- (void)loginWithUserName:(NSString *)name
                 passWord:(NSString *)passWord;


@end
