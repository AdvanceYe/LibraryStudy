//
//  BaseType.h
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/23.
//  Copyright © 2019年 com.test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <string>

namespace FB { namespace RetainCycleDetector { namespace Parser {
    class BaseType {
    public:
        virtual ~BaseType() {}
    };
    
    class Unresolved: public BaseType {
    public:
        std::string value;
        Unresolved(std::string value): value(value) {}
        Unresolved(Unresolved&&) = default;
        
        Unresolved(const Unresolved&) = delete;
        Unresolved &operator=(const Unresolved&) = delete;
    };
}}}





