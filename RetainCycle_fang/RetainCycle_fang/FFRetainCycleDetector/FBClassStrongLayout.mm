//
//  FFClassStrongLayout.m
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/21.
//  Copyright © 2019年 com.test. All rights reserved.
//

#import "FBClassStrongLayout.h"

#import <objc/runtime.h>
#import <math.h>
#import <memory>
#import <vector>
#import <string>

#import "FBIvarReference.h"
#import "FBObjectInStructReference.h"


static NSArray *FBGetReferencesForObjectsInStructEncoding(FBIvarReference *ivar, std::string encoding) {
    NSMutableArray<FBObjectInStructReference *> *references = [NSMutableArray new];
    
    std::string ivarName = std::string([ivar.name cStringUsingEncoding:NSUTF8StringEncoding]);

    
    
    return nil;
}

NSArray<id<FBObjectReference>> *FBGetClassReferences(Class aCls) {
    NSMutableArray<id<FBObjectReference>> *result = [NSMutableArray new];
    
    unsigned int count;
    Ivar *ivars = class_copyIvarList(aCls, &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        FBIvarReference *wrapper = [[FBIvarReference alloc] initWithIvar:ivar];
        
        if (wrapper.type == FBStructType) {
            std::string encoding = std::string(ivar_getTypeEncoding(wrapper.ivar));
            NSArray<FBObjectInStructReference *> *references = FBGetReferencesForObjectsInStructEncoding(wrapper, encoding);
            [result addObjectsFromArray:references];
        } else {
            [result addObject:wrapper];
        }
    }
    free(ivars);
    return [result copy];
}

//FBGetStrongReferencesForClass
static NSArray<id<FBObjectReference>> *FBGetStrongReferencesForClass(Class aCls) {
    NSArray<id<FBObjectReference>> *ivars = nil;
    return ivars;
}

NSArray<id<FBObjectReference>> *FBGetObjectStrongReferences(id obj, NSMutableDictionary<Class, NSArray*> *layoutCache) {
    NSMutableArray<id<FBObjectReference>> *array = [NSMutableArray new];
    
    __unsafe_unretained Class previousClass = nil;
    __unsafe_unretained Class currentClass = object_getClass(obj);
    while (previousClass != currentClass) {
        NSArray<id<FBObjectReference>> *ivars;
        if (layoutCache && currentClass) {
            ivars = layoutCache[currentClass];
        }
        if (!ivars) {
            ivars = FBGetStrongReferencesForClass(currentClass);;
            if (layoutCache && currentClass) {
                layoutCache[currentClass] = ivars;
            }
            layoutCache[currentClass] = ivars;
        }
        [array addObjectsFromArray:ivars];
        
        previousClass = currentClass;
        currentClass = class_getSuperclass(currentClass);
    }
    
    return [array copy];
}
