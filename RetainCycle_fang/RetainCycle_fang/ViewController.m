//
//  ViewController.m
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/21.
//  Copyright © 2019年 com.test. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

NSArray* test_FBGetClassReferences(Class aCls) {
    unsigned int count;
    UIViewController *obj = [UIViewController new];
    Ivar *ivars = class_copyIvarList(object_getClass(obj), &count);
    for (unsigned int i = 0; i < count; ++i) {
        Ivar ivar = ivars[i];
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSLog(@">>> name = %@", name);
    }
    return nil;
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    test_FBGetClassReferences(object_getClass(self));

    
    
    Class selfClass = [self class];
    Class selfClass2 = [[self class] class];
    NSLog(@"selfClass = %p", selfClass);
    NSLog(@"selfClass2 = %p", selfClass2);
    
    Class selfClass3 = object_getClass(self);
    Class selfClass4 = object_getClass(selfClass3);
    NSLog(@"selfClass3 = %p", selfClass3);
    NSLog(@"selfClass4 = %p", selfClass4);
    
    /*
     class 1 = 0x10b7f7d80, name = ViewController
     class 2 = 0x10b7f7da8, name = ViewController
     class 3 = 0x10c890ee8, name = NSObject
     */
    Class currentClass = object_getClass(self);
    Class lastClass = nil;
    int i = 0;
    //TODO: 没break的情况下，CPU只占了40%，为啥？？？？
    while (currentClass) {
        i++;
        NSString *className = NSStringFromClass(currentClass);
        NSLog(@"class %d = %p, name = %@", i, currentClass, className);
        lastClass = currentClass;
        currentClass = object_getClass(currentClass);
        if (lastClass == currentClass) {
            break;
        }
    }
    NSLog(@"完毕");
}


@end
