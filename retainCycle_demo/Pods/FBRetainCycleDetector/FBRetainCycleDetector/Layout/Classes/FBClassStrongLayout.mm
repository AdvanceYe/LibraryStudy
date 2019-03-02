/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBClassStrongLayout.h"

#import <math.h>
#import <memory>
#import <objc/runtime.h>
#import <vector>

#import <UIKit/UIKit.h>

#import "FBIvarReference.h"
#import "FBObjectInStructReference.h"
#import "FBStructEncodingParser.h"
#import "Struct.h"
#import "Type.h"

/**
 If we stumble upon a struct, we need to go through it and check if it doesn't retain some objects.
 */
static NSArray *FBGetReferencesForObjectsInStructEncoding(FBIvarReference *ivar, std::string encoding) {
  NSMutableArray<FBObjectInStructReference *> *references = [NSMutableArray new];

  std::string ivarName = std::string([ivar.name cStringUsingEncoding:NSUTF8StringEncoding]);
  FB::RetainCycleDetector::Parser::Struct parsedStruct =
  FB::RetainCycleDetector::Parser::parseStructEncodingWithName(encoding, ivarName);
  
  std::vector<std::shared_ptr<FB::RetainCycleDetector::Parser::Type>> types = parsedStruct.flattenTypes();
  
  ptrdiff_t offset = ivar.offset;
  
  for (auto &type: types) {
    NSUInteger size, align;

    std::string typeEncoding = type->typeEncoding;
    if (typeEncoding[0] == '^') {
      // It's a pointer, let's skip
      size = sizeof(void *);
      align = _Alignof(void *);
    } else {
      @try {
        NSGetSizeAndAlignment(typeEncoding.c_str(),
                              &size,
                              &align);
      } @catch (NSException *e) {
        /**
         If we failed, we probably have C++ and ObjC cannot get it's size and alignment. We are skipping.
         If we would like to support it, we would need to derive size and alignment of type from the string.
         C++ does not have reflection so we can't really do that unless we create the mapping ourselves.
         */
        break;
      }
    }


    // The object must be aligned
    NSUInteger overAlignment = offset % align;
    NSUInteger whatsMissing = (overAlignment == 0) ? 0 : align - overAlignment;
    offset += whatsMissing;

    if (typeEncoding[0] == '@') {
    
      // The index that ivar layout will ask for is going to be aligned with pointer size

      // Prepare additional context
      NSString *typeEncodingName = [NSString stringWithCString:type->name.c_str() encoding:NSUTF8StringEncoding];
      
      NSMutableArray *namePath = [NSMutableArray new];
      
      for (auto &name: type->typePath) {
        NSString *nameString = [NSString stringWithCString:name.c_str() encoding:NSUTF8StringEncoding];
        if (nameString) {
          [namePath addObject:nameString];
        }
      }
      
      if (typeEncodingName) {
        [namePath addObject:typeEncodingName];
      }
      [references addObject:[[FBObjectInStructReference alloc] initWithIndex:(offset / sizeof(void *))
                                                                    namePath:namePath]];
    }

    offset += size;
  }

  return references;
}

NSArray<id<FBObjectReference>> *FBGetClassReferences(Class aCls) {
  NSMutableArray<id<FBObjectReference>> *result = [NSMutableArray new];

  unsigned int count;
    //获取到ivar list
  Ivar *ivars = class_copyIvarList(aCls, &count);

  for (unsigned int i = 0; i < count; ++i) {
    Ivar ivar = ivars[i];
    FBIvarReference *wrapper = [[FBIvarReference alloc] initWithIvar:ivar];

      // struct类型的获取
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

static NSIndexSet *FBGetLayoutAsIndexesForDescription(NSUInteger minimumIndex, const uint8_t *layoutDescription) {
  NSMutableIndexSet *interestingIndexes = [NSMutableIndexSet new];
  NSUInteger currentIndex = minimumIndex;

    /*
     https://zhidao.baidu.com/question/1047277538585998979.html
     eg. '\x02' & 0xf0 = 0x0000 0010 & 0x1111 0000 = 0x0000 0000 >> 4 = 0x0000 - 低4位被清0，高4位
     eg. '\x02' & 0xf = 0x 0000 0010 & 0x0000 1111 = 0x0000 0010 = 低4位
     eg. '\x02!', '\x02', '\0x21'ASCII码
     */
  while (*layoutDescription != '\x00') {
    int upperNibble = (*layoutDescription & 0xf0) >> 4;
    int lowerNibble = *layoutDescription & 0xf;

    // Upper nimble is for skipping -- 高位是weak个数，需要跳的
    currentIndex += upperNibble;

    // Lower nimble describes count
    [interestingIndexes addIndexesInRange:NSMakeRange(currentIndex, lowerNibble)];
    currentIndex += lowerNibble;

    ++layoutDescription;
  }

  return interestingIndexes;
}

static NSUInteger FBGetMinimumIvarIndex(__unsafe_unretained Class aCls) {
  NSUInteger minimumIndex = 1;
  unsigned int count;
  Ivar *ivars = class_copyIvarList(aCls, &count);

  if (count > 0) {
    Ivar ivar = ivars[0];
    ptrdiff_t offset = ivar_getOffset(ivar);
    minimumIndex = offset / (sizeof(void *));
  }

  free(ivars);

  return minimumIndex;
}

static NSArray<id<FBObjectReference>> *FBGetStrongReferencesForClass(Class aCls) {
  NSArray<id<FBObjectReference>> *ivars = [FBGetClassReferences(aCls) filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
      //object类型的
    if ([evaluatedObject isKindOfClass:[FBIvarReference class]]) {
      FBIvarReference *wrapper = evaluatedObject;
      return wrapper.type != FBUnknownType; //object或者block的(无论strong/weak)
    }
      //struct类型的
    return YES;
  }]];

  const uint8_t *fullLayout = class_getIvarLayout(aCls);

  //有变量
  if (!fullLayout) {
    return nil;
  }

  NSUInteger minimumIndex = FBGetMinimumIvarIndex(aCls);
    //获取strong ivar的位置
  NSIndexSet *parsedLayout = FBGetLayoutAsIndexesForDescription(minimumIndex, fullLayout);

  NSArray<id<FBObjectReference>> *filteredIvars =
  [ivars filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<FBObjectReference> evaluatedObject,
                                                                           NSDictionary *bindings) {
      //ivar或者struct, 获取index
    return [parsedLayout containsIndex:[evaluatedObject indexInIvarLayout]];
  }]];

  return filteredIvars;
}

NSArray<id<FBObjectReference>> *FBGetObjectStrongReferences(id obj,
                                                            NSMutableDictionary<Class, NSArray<id<FBObjectReference>> *> *layoutCache) {
  NSMutableArray<id<FBObjectReference>> *array = [NSMutableArray new];

    //此处为什么是__unsafe_unretained? class类不会释放，所以还好其实。。用strong也行。。可能后来iOS接口性质变了
  __unsafe_unretained Class previousClass = nil;
  __unsafe_unretained Class currentClass = object_getClass(obj); //如果不用的话很快就释放了

  while (previousClass != currentClass) {
      NSLog(@"currentClass = %@, = %p, isMeta = %d", currentClass, currentClass, class_isMetaClass(currentClass));
    NSArray<id<FBObjectReference>> *ivars;
    
    if (layoutCache && currentClass) {
      ivars = layoutCache[currentClass]; //指针可以作为key值
    }
    
      //懒加载获取一个class的ivars
    if (!ivars) {
        //获取strong类型的地方
      ivars = FBGetStrongReferencesForClass(currentClass);
      if (layoutCache && currentClass) {
        layoutCache[currentClass] = ivars;
          NSLog(@"layoutCache = %@", layoutCache);
      }
    }
    [array addObjectsFromArray:ivars];

    previousClass = currentClass;
    currentClass = class_getSuperclass(currentClass);
  }

    NSLog(@"class - current = %@", currentClass);
    NSLog(@"class - prev = %@", previousClass);
  return [array copy];
}
