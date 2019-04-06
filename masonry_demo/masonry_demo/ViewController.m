//
//  ViewController.m
//  masonry_demo
//
//  Created by tataball on 2019/3/26.
//  Copyright © 2019 copyCat_yy. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

//    [self autoLayout];
    
    [self frameLayout];
}

- (void)autoLayout {
    UILabel *view1 = [UILabel new];
    view1.backgroundColor = [UIColor orangeColor];
    view1.text = @"啊啊啊啊啊";
    [self.view addSubview:view1];
    
    //self.translatesAutoresizingMaskIntoConstraints = NO;决定了是否显示
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self.view).offset(50);
    }];
}

- (void)frameLayout {
    UILabel *view1 = [UILabel new];
    view1.backgroundColor = [UIColor orangeColor];
    view1.text = @"啊啊啊啊啊";
    [view1 sizeToFit];
    [self.view addSubview:view1];
}


@end
