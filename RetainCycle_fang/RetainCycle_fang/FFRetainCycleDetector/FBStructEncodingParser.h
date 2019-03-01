//
//  FBStructEncodingParse.h
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/23.
//  Copyright © 2019年 com.test. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Struct.h"
#import "Type.h"

namespace FB {  namespace RetainCycleDetector {  namespace Parser {
    
    Struct parseStructEncoding(const std::string &structEncodingString);
    
    Struct parseStructEncodingWithName(const std::string &structEncodingString,
                                       const std::string &structName);
} } }





