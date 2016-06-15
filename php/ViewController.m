//
//  ViewController.m
//  php
//
//  Created by jglz on 16/6/15.
//  Copyright © 2016年 yxb. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#define url @"http://www.njhouse.com.cn/realcardnotice.php?DOCID=2016267966"
@interface ViewController (){

    NSInteger i ;
}

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    i = 0;
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

    dispatch_queue_t queue = dispatch_get_main_queue();

    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);

    dispatch_source_set_event_handler(self.timer, ^{
        [self getInfoFromAppStore];
        NSLog(@"123000");
        [self.webview reload];
        i ++;
        
    });

    dispatch_resume(self.timer);
    [self getInfoFromAppStore];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)getInfoFromAppStore {
    
    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data.length <= 6901) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                //Update UI in UI thread here
                self.msgLabel.text = [NSString stringWithFormat:@"一切正常%ld，共%lu",(long)i,data.length];

            });
            
            NSLog(@"正常");
        }else{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            NSLog(@"新消息");
            dispatch_sync(dispatch_get_main_queue(), ^{

                self.msgLabel.text = [NSString stringWithFormat:@"有新消息%lu",data.length];

                
                
            });
            
        }
        
        
        
    }];
    
    [dataTask resume];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
