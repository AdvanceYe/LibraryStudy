//
//  TestViewController.m
//  retainCycle_demo
//
//  Created by star gazer on 2018/6/15.
//  Copyright © 2018年 star gazer. All rights reserved.
//

#import "TestViewController.h"
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>

@interface TestViewController ()

@property(nonatomic, strong) NSArray *dataArray;

@property(nonatomic, copy) void(^hahaBlock)(void);

@end

@implementation TestViewController
{
    NSArray *_array;
    BOOL _flag;
}

- (void)dealloc {
    NSLog(@"---dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}



//高级编程
- (void)test {
    __block BOOL flag2 = NO;
    
    _array = self.dataArray = @[@"jaja"];
    __weak typeof(self) weakSelf = self;
    __block typeof(_flag) blockFlag = _flag;
    self.hahaBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"___hahablock");
        strongSelf->_flag = YES;
        //        blockFlag = YES;
        flag2 = YES;
    };
    self.hahaBlock();
    NSLog(@"__flag = %d", _flag);
    NSLog(@"__flag2 = %d", flag2);
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
