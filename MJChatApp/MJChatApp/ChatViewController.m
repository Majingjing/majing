//
//  ChatViewController.m
//  MJChatApp
//
//  Created by lanou3g on 16/2/26.
//  Copyright © 2016年 麻静. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sendMessageField;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
//存放聊天信息的
@property (nonatomic, strong)NSMutableArray *messageArray;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.messageArray = [NSMutableArray array];
    NSLog(@"friendjid = %@", self.friendJid);
    //添加代理
    [[Manager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Do any additional setup after loading the view.
}
#pragma mark XMPPStreamDelegate
#pragma mark 接收到消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"接收到消息");
    [self searchMessage];
}
#pragma mark 消息发送失败
-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    NSLog(@"消息发送失败");
}
#pragma mark 消息发送成功
-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"消息发送成功");
    [self searchMessage];
}




#pragma mark  查询聊天信息
- (void)searchMessage {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:[Manager shareInstance].context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@", [Manager shareInstance].xmppStream.myJID.bare, self.friendJid.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[Manager shareInstance].context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"查询失败：%@", error);
    }
    //先清空数组
    [self.messageArray removeAllObjects];
    
    //然后添加数据
    [self.messageArray addObjectsFromArray:fetchedObjects];
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
    
    
    [self.chatTableView reloadData];

    //自动滑动到最后一行
    [self.chatTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mai" forIndexPath:indexPath];
    if (cell) {
        XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];
        if (message.isOutgoing) {
            //发出的消息
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.detailTextLabel.hidden = YES;
            cell.textLabel.hidden = NO;
            cell.textLabel.text = message.body;
        } else {
            cell.textLabel.hidden = YES;
            cell.detailTextLabel.hidden = NO;
            cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
            cell.detailTextLabel.text = message.body;
        }
    }
  
    return cell;
}
//发送按钮
- (IBAction)sendAction:(UIButton *)sender {
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    //设置消息内容
    [message addBody:self.sendMessageField.text];
    //通过通信管道将消息传递出去
    [[Manager shareInstance].xmppStream sendElement:message];
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
