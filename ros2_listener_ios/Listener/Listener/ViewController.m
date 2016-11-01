/* Copyright 2016 Esteve Fernandez <esteve@apache.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "rclobjc/ROSRCLObjC.h"
#import "ROS_std_msgs/msg/String.h"

#import "ViewController.h"

@interface ViewController ()

@property (atomic) BOOL rosLoopEnabled;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stopButton.enabled = false;
    self.rosLoopEnabled = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)handleStartButtonClick:(id)sender {

    self.startButton.enabled = false;
    self.stopButton.enabled = true;
    self.rosLoopEnabled = true;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        ROSNode * node = [ROSRCLObjC createNode:@"listener_ios"];

        ROSSubscription<ROS_std_msgs_msg_String *> * sub = [node createSubscriptionWithCallback
          :[ROS_std_msgs_msg_String class]
          :@"chatter"
          :^(ROS_std_msgs_msg_String *msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
              self.listenerTextField.text = [self.listenerTextField.text stringByAppendingFormat:@"%@\n", [msg data]];
            });
          }
        ];

        (void)sub;

        while ([ROSRCLObjC ok] && self.rosLoopEnabled) {
          [ROSRCLObjC spinOnce:node];
        }
    });
}

- (IBAction)handleStopButtonClick:(id)sender {
    self.rosLoopEnabled = false;
    self.stopButton.enabled = false;
    self.startButton.enabled = true;
}

@end
