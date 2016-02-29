//
//  ChatViewController.h
//  MJChatApp
//
//  Created by lanou3g on 16/2/26.
//  Copyright © 2016年 麻静. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Manager.h"
@interface ChatViewController : UIViewController
//聊天好友的jid
@property (nonatomic, strong)XMPPJID *friendJid;
@end
