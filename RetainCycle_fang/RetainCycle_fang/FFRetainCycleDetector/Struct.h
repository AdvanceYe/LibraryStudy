//
//  Struct.h
//  RetainCycle_fang
//
//  Created by yeye(* ￣＾￣) on 2019/2/23.
//  Copyright © 2019年 com.test. All rights reserved.
//

#ifndef Struct_h
#define Struct_h

#import <Foundation/Foundation.h>

#import "Type.h"

#import <memory>
#import <string>
#import <vector>

namespace FB {  namespace RetainCycleDetector {  namespace Parser {
    class Struct: public Type {
    public:
        const std::string structTypeName;
        
        Struct(const std::string &name,
               const std::string &typeEncoding,
               const std::string &structTypeName,
               std::vector<std::shared_ptr<Type>> &typesContainedInStruct)
        : Type(name, typeEncoding),
        structTypeName(structTypeName),
        typesContainedInStruct(std::move(typesContainedInStruct)) {};
        Struct(Struct&&) = default;
        Struct &operator=(Struct&&) = default;
        
        Struct(const Struct&) = delete;
        Struct &operator=(const Struct&) = delete;
        
        std::vector<std::shared_ptr<Type>> flattenTypes();
        
        virtual void passTypePath(std::vector<std::string> typePath);
        std::vector<std::shared_ptr<Type>> typesContainedInStruct;
    };
} } }

#endif /* Struct_h */
