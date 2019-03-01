/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <string>

namespace FB { namespace RetainCycleDetector { namespace Parser {
  class BaseType {
  public:
    virtual ~BaseType() {}
  };
  
    //TODO: 干哈用的，回头再看??
  class Unresolved: public BaseType {
  public:
    std::string value;
    Unresolved(std::string value): value(value) {}
      
      /*
       https://blog.csdn.net/caroline_wendy/article/details/15029287
       lvalue, rvalue重载
       右值引用 &&i: 对象值引用
      */
    Unresolved(Unresolved&&) = default;
    Unresolved &operator=(Unresolved&&) = default;
    
    Unresolved(const Unresolved&) = delete; //拷贝构造函数为deleted函数
    Unresolved &operator=(const Unresolved&) = delete; //拷贝赋值操作符为 deleted 函数
  };
} } }
