/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBRetainCycleUtils.h"

#import <objc/runtime.h>

#import "FBBlockStrongLayout.h"
#import "FBClassStrongLayout.h"
#import "FBObjectiveCBlock.h"
#import "FBObjectiveCGraphElement.h"
#import "FBObjectiveCNSCFTimer.h"
#import "FBObjectiveCObject.h"
#import "FBObjectGraphConfiguration.h"

static BOOL _ShouldBreakGraphEdge(FBObjectGraphConfiguration *configuration,
                                  FBObjectiveCGraphElement *fromObject,
                                  NSString *byIvar,
                                  Class toObjectOfClass) {
    //TODO: 仔细看
  for (FBGraphEdgeFilterBlock filterBlock in configuration.filterBlocks) {
    if (filterBlock(fromObject, byIvar, toObjectOfClass) == FBGraphEdgeInvalid) {
      return YES;
    }
  }

  return NO;
}

FBObjectiveCGraphElement *FBWrapObjectGraphElementWithContext(FBObjectiveCGraphElement *sourceElement,
                                                              id object,
                                                              FBObjectGraphConfiguration *configuration,
                                                              NSArray<NSString *> *namePath) {
  
    //大概意思：过滤掉这个
    if (_ShouldBreakGraphEdge(configuration, sourceElement, [namePath firstObject], object_getClass(object))) {
    return nil;
  }
  FBObjectiveCGraphElement *newElement;
  if (FBObjectIsBlock((__bridge void *)object)) { //(__bridge void *)object)变为c的类，判断block
    newElement = [[FBObjectiveCBlock alloc] initWithObject:object
                                             configuration:configuration
                                                  namePath:namePath];
  } else {
    if ([object_getClass(object) isSubclassOfClass:[NSTimer class]] &&
        configuration.shouldInspectTimers) {
      newElement = [[FBObjectiveCNSCFTimer alloc] initWithObject:object
                                                   configuration:configuration
                                                        namePath:namePath];
    } else {
      newElement = [[FBObjectiveCObject alloc] initWithObject:object
                                                configuration:configuration
                                                     namePath:namePath];
    }
  }
    //是否要转换。
  return (configuration && configuration.transformerBlock) ? configuration.transformerBlock(newElement) : newElement;
}

FBObjectiveCGraphElement *FBWrapObjectGraphElement(FBObjectiveCGraphElement *sourceElement,
                                                   id object,
                                                   FBObjectGraphConfiguration *configuration) {
  return FBWrapObjectGraphElementWithContext(sourceElement, object, configuration, nil);
}
