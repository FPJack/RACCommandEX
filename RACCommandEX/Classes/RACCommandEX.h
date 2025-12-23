//
//  RACCommandEX.h
//  GMPopView_Example
//
//  Created by admin on 2025/11/19.
//  Copyright © 2025 fanpeng. All rights reserved.
//

#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN
@interface EXDataType<__covariant InputType,__covariant ValueType> : NSObject
@property (nonatomic,strong)InputType input;
@property (nonatomic,strong)ValueType value;
@property (nonatomic,assign)BOOL isPushValue;
@end
@interface RACCommandEX<__covariant InputType,__covariant ValueType> : RACCommand<InputType,EXDataType<InputType,ValueType> *>
@property (nonatomic, strong,readonly) EXDataType<InputType,ValueType> *lastData;

@property (atomic,assign,readonly)BOOL hasError;
/// 回放最新输入值和对应的输出值
@property (nonatomic,readonly)RACSignal<EXDataType<InputType,ValueType> *> *replayLatestValue;
/// 回放最新错误信息
@property (nonatomic,readonly)RACSignal<NSError *> *replayLatestError;

- (RACSignal *)pushValue:(ValueType)data;
- (RACSignal *)pushValueWithInput:(InputType)input value:(ValueType)value;
- (RACSignal *)refresh;
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
