//
//  ViewController.m
//  ModelBenchmark
//
//  Created by ibireme on 15/9/18.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "DateFormatter.h"
#import "GitHubUser.h"
#import "YYWeiboModel.h"

@implementation ViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    [self testDictEnumerator];
    
    [self testMetaClass];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self benchmarkGithubUser];
        [self benchmarkWeiboStatus];
        
        [self testRobustness];
    });
}

- (void)testDictEnumerator {
//    enumerateKeysAndObjectsUsingBlock
    NSDictionary *dic = @{@"k1": @"v1",
                          @"k2": @"v1",
                          };
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"key = %@, value = %@", key, obj);
    }];

}

- (void)testMetaClass {
    NSObject *obj = [NSObject new];
    [self printIsMeta:[obj class]];
    
    [self printIsMeta:[self class]];
    
    [self printIsMeta:[[YYWeiboStatus new] class]];
}

- (void)printIsMeta:(Class)cls {
    BOOL isMeta = class_isMetaClass(cls);
    NSLog(@"cls = %@, isMeta = %d", cls, isMeta);
}

- (void)benchmarkGithubUser {
    
    
    printf("----------------------\n");
    printf("Benchmark (10000 times):\n");
    printf("GHUser             from json    to json    archive\n");
    
    /// get json data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    
    /// Benchmark
    int count = 10000;
    count = 1;
    NSTimeInterval begin, end;
    
//    /// warm up (NSDictionary's hot cache, and JSON to model framework cache)
//    FEMMapping *mapping = [FEGHUser defaultMapping];
//    MTLJSONAdapter *adapter = [[MTLJSONAdapter alloc] initWithModelClass:[MTGHUser class]];
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            
            // YYModel
            [YYGHUser yy_modelWithJSON:json];
        }
    }
    /// warm up holder
    NSMutableArray *holder = [NSMutableArray new];
    for (int i = 0; i < 1800; i++) {
        [holder addObject:[NSDate new]];
    }
    [holder removeAllObjects];
    

    
    /*------------------- YYModel -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                YYGHUser *user = [YYGHUser yy_modelWithJSON:json];
                [holder addObject:user];
            }
        }
        end = CACurrentMediaTime();
        printf("YYModel(#):         %8.2f   ", (end - begin) * 1000);
        
        
        YYGHUser *user = [YYGHUser yy_modelWithJSON:json];
        if (user.userID == 0) NSLog(@"error!");
        if (!user.login) NSLog(@"error!");
        if (!user.htmlURL) NSLog(@"error");
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSDictionary *json = [user yy_modelToJSONObject];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        if ([NSJSONSerialization isValidJSONObject:[user yy_modelToJSONObject]]) {
            printf("%8.2f   ", (end - begin) * 1000);
        } else {
            printf("   error   ");
        }
        
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        printf("%8.2f\n", (end - begin) * 1000);
    }
}

- (void)benchmarkWeiboStatus {
    printf("----------------------\n");
    printf("Benchmark (1000 times):\n");
    printf("WeiboStatus     from json    to json    archive\n");
    
    /// get json data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"weibo" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    
    
    
    
    /// Benchmark
    int count = 1000;
    count = 1;
    NSTimeInterval begin, end;
    
    @autoreleasepool {
        for (int i = 0; i < count * 2; i++) {
            // YYModel
            [YYWeiboStatus yy_modelWithJSON:json];
        }
    }
    
    /// warm up holder
    NSMutableArray *holder = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        [holder addObject:[NSData new]];
    }
    [holder removeAllObjects];
    
    
    /*------------------- YYModel -------------------*/
    {
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                YYWeiboStatus *feed = [YYWeiboStatus yy_modelWithJSON:json];
                [holder addObject:feed];
            }
        }
        end = CACurrentMediaTime();
        printf("YYModel:         %8.2f   ", (end - begin) * 1000);
        
        
        YYWeiboStatus *feed = [YYWeiboStatus yy_modelWithJSON:json];
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSDictionary *json = [feed yy_modelToJSONObject];
                [holder addObject:json];
            }
        }
        end = CACurrentMediaTime();
        if ([NSJSONSerialization isValidJSONObject:[feed yy_modelToJSONObject]]) {
            printf("%8.2f   ", (end - begin) * 1000);
        } else {
            printf("   error   ");
        }
        
        
        [holder removeAllObjects];
        begin = CACurrentMediaTime();
        @autoreleasepool {
            for (int i = 0; i < count; i++) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:feed];
                [holder addObject:data];
            }
        }
        end = CACurrentMediaTime();
        printf("%8.2f\n", (end - begin) * 1000);
    }
}

- (void)testRobustness {
    
    {
        printf("----------------------\n");
        printf("The property is NSString, but the json value is number:\n");
        NSString *jsonStr = @"{\"type\":1}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            printf("%s ",model.UTF8String);
            if (!user) {
                printf("⚠️ model is nil\n");
            } else {
                NSString *type = ((YYGHUser *)user).type;
                if (type == nil || type == (id)[NSNull null]) {
                    printf("⚠️ property is nil\n");
                } else if ([type isKindOfClass:[NSString class]]) {
                    printf("✅ property is %s\n",NSStringFromClass(type.class).UTF8String);
                } else {
                    printf("🚫 property is %s\n",NSStringFromClass(type.class).UTF8String);
                }
            }
        };
        
        // YYModel
        YYGHUser *yyUser = [YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
    }
    
    {
        printf("----------------------\n");
        printf("The property is int, but the json value is string:\n");
        NSString *jsonStr = @"{\"followers\":\"100\"}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            printf("%s ",model.UTF8String);
            if (!user) {
                printf("⚠️ model is nil\n");
            } else {
                UInt32 num = ((YYGHUser *)user).followers;
                if (num != 100) {
                    printf("🚫 property is %u\n",(unsigned int)num);
                } else {
                    printf("✅ property is %u\n",(unsigned int)num);
                }
            }
        };
        
        // YYModel
        YYGHUser *yyUser = [YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
    }
    
    
    {
        printf("----------------------\n");
        printf("The property is NSDate, and the json value is string:\n");
        NSString *jsonStr = @"{\"updated_at\":\"2009-04-02T03:35:22Z\"}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            printf("%s ",model.UTF8String);
            if (!user) {
                printf("⚠️ model is nil\n");
            } else {
                NSDate *date = ((YYGHUser *)user).updatedAt;
                if (date == nil || date == (id)[NSNull null]) {
                    printf("⚠️ property is nil\n");
                } else if ([date isKindOfClass:[NSDate class]]) {
                    printf("✅ property is %s\n",NSStringFromClass(date.class).UTF8String);
                } else {
                    printf("🚫 property is %s\n",NSStringFromClass(date.class).UTF8String);
                }
            }
        };
        
        // YYModel
        YYGHUser *yyUser = [YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
    }
    
    
    {
        printf("----------------------\n");
        printf("The property is NSValue, and the json value is string:\n");
        NSString *jsonStr = @"{\"test\":\"https://github.com\"}";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        void (^logError)(NSString *model, id user) = ^(NSString *model, id user){
            printf("%s ",model.UTF8String);
            if (!user) {
                printf("⚠️ model is nil\n");
            } else {
                NSValue *valur = ((YYGHUser *)user).test;
                if (valur == nil || valur == (id)[NSNull null]) {
                    printf("✅ property is nil\n");
                } else if ([valur isKindOfClass:[NSURLRequest class]]) {
                    printf("✅ property is %s\n",NSStringFromClass(valur.class).UTF8String);
                } else {
                    printf("🚫 property is %s\n",NSStringFromClass(valur.class).UTF8String);
                }
            }
        };
        // YYModel
        YYGHUser *yyUser = [YYGHUser yy_modelWithJSON:json];
        logError(@"YYModel:        ", yyUser);
    }
    
}

@end

