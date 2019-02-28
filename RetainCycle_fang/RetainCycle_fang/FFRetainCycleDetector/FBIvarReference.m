//
//  FBIvarReference.m
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/23.
//  Copyright © 2019年 com.test. All rights reserved.
//

#import "FBIvarReference.h"

@implementation FBIvarReference

- (nonnull instancetype)initWithIvar:(nonnull Ivar)ivar {
    if (self = [super init]) {
        _name = @(ivar_getName(ivar));
        _type = [self _convertEncodingToType:ivar_getTypeEncoding(ivar)];
        _offset = ivar_getOffset(ivar);
        _index = _offset / sizeof(void *);
        _ivar = ivar;
    }
    return self;
}

- (FBType)_convertEncodingToType:(const char *)typeEncoding {
    if (typeEncoding[0] == '{') {
        return FBStructType;
    }
    
    if (typeEncoding[0] == '@') {
        if (strncmp(typeEncoding, "@?", 2) == 0) {
            return FBBlockType;
        }
        return FBObjectType;
    }
    return FBUnknownType;
}

@end
