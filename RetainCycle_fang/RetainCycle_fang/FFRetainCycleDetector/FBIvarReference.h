//
//  FBIvarReference.h
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/23.
//  Copyright © 2019年 com.test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "FBObjectReference.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FBType) {
    FBObjectType,
    FBBlockType,
    FBStructType,
    FBUnknownType,
};

@interface FBIvarReference : NSObject <FBObjectReference>

@property (nonatomic, readonly, nullable) NSString *name;
@property (nonatomic, readonly) FBType type;
@property (nonatomic, readonly) ptrdiff_t offset;
@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, readonly, nonnull) Ivar ivar;

- (nonnull instancetype)initWithIvar:(nonnull Ivar)ivar;

@end

NS_ASSUME_NONNULL_END
