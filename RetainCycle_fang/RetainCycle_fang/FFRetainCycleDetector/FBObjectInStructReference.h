//
//  FBObjectInStructReference.h
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/23.
//  Copyright © 2019年 com.test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBObjectReference.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBObjectInStructReference : NSObject

- (nonnull instancetype)initWithIndex:(NSUInteger)index
                             namePath:(nullable NSArray<NSString *> *)namePath;

@end

NS_ASSUME_NONNULL_END
