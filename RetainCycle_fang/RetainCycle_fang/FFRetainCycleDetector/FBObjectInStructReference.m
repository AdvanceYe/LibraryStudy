//
//  FBObjectInStructReference.m
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/23.
//  Copyright © 2019年 com.test. All rights reserved.
//

#import "FBObjectInStructReference.h"

@implementation FBObjectInStructReference
{
    NSUInteger _index;
    NSArray<NSString *> *_namePath;
}

- (nonnull instancetype)initWithIndex:(NSUInteger)index
                             namePath:(nullable NSArray<NSString *> *)namePath {
    if (self = [super init]) {
        _index = index;
        _namePath = namePath;
    }
    return self;
}

@end
