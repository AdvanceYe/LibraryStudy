//
//  Type.h
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/23.
//  Copyright © 2019年 com.test. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <memory>
#import <string>
#import <vector>

#import "BaseType.h"

namespace FB {  namespace RetainCycleDetector {  namespace Parser {
    class Type: public BaseType {
    public:
        const std::string name;
        const std::string typeEncoding;
        
        Type(const std::string &name,
             const std::string &typeEncoding): name(name), typeEncoding(typeEncoding) {}
        Type(Type&&) = default;
        Type &operator=(Type&&) = default;
        
        Type(const Type&) = delete;
        Type &operator=(const Type&) = delete;
        
        virtual void passTypePath(std::vector<std::string> typePath) {
            this->typePath = typePath;
        }
        
        std::vector<std::string> typePath;
    };
} } }
