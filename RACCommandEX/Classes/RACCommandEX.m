

#import "RACCommandEX.h"
@implementation EXDataType
@end
@interface _EXDataType : EXDataType
@end
@implementation _EXDataType
@end
@interface RACCommandEX ()
@property (nonatomic, strong) id currentValue; // 缓存值
@property (nonatomic, strong) RACReplaySubject *cacheSubject; // 缓存信号
@property (nonatomic,strong)RACSubject *cancelSignal;
@property (nonatomic,strong)RACReplaySubject *errorSubject;
@property (nonatomic, strong,readwrite) EXDataType *lastData;
@property (atomic,assign,readwrite)BOOL hasError;
@end
@implementation RACCommandEX
- (RACReplaySubject *)cacheSubject {
    if (!_cacheSubject) {
        _cacheSubject = [RACReplaySubject replaySubjectWithCapacity:1];
    }
    return _cacheSubject;
}
- (RACSubject *)cancelSignal {
    if (!_cancelSignal) {
        _cancelSignal = [RACSubject subject];
    }
    return _cancelSignal;
}
- (RACReplaySubject *)errorSubject {
    if (!_errorSubject) {
        _errorSubject = [RACReplaySubject replaySubjectWithCapacity:1];
        
    }
    return _errorSubject;
}
- (instancetype)initWithSignalBlock:(RACSignal<id> * (^)(id input))signalBlock {
    return [self initWithEnabled:nil signalBlock:signalBlock];
}
- (instancetype)initWithEnabled:(RACSignal *)enabledSignal signalBlock:(RACSignal<id> * (^)(id input))signalBlock {
    @weakify(self)
    self = [super initWithEnabled:enabledSignal signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        if ([input isKindOfClass:_EXDataType.class]) {
            return [[RACSignal return:input] doNext:^(id  _Nullable x) {
                @strongify(self)
                [self updateCache:x];
            }];
        }
        return [[[[signalBlock(input) takeUntil:self.cancelSignal] map:^id _Nullable(id  _Nullable value) {
            EXDataType *dataType = [[EXDataType alloc] init];
            dataType.input = input;
            dataType.value = value;
            return dataType;
        }] doNext:^(EXDataType*  _Nullable x) {
            @strongify(self)
            [self updateCache:x];
        }]  doError:^(NSError * _Nonnull error) {
            @strongify(self)
            self.hasError = YES;
            [self.errorSubject sendNext:error];
        }];
    }];
    return self;
}
- (RACSignal *)replayLatestValue {
    return self.cacheSubject;
}
- (RACSignal<NSError *> *)replayLatestError {
    @weakify(self)
    return [self.errorSubject filter:^BOOL(id  _Nullable value) {
        @strongify(self)
        return self.hasError;
    }];
}
- (void)updateCache:(EXDataType *)value {
    self.hasError = NO;
    self.lastData = value;
    [self.cacheSubject sendNext:value];
}
- (RACSignal *)pushValue:(id)data {
    @synchronized (self) {
        [self cancel];
        _EXDataType *dataType = [[_EXDataType alloc] init];
        dataType.input = self.lastData.input;
        dataType.value = data;
        dataType.isPushValue = YES;
        return [self execute:dataType];
    }
}
- (RACSignal *)pushValueWithInput:(id)input value:(id)value {
    @synchronized (self) {
        [self cancel];
        _EXDataType *dataType = [[_EXDataType alloc] init];
        dataType.input = input;
        dataType.value = value;
        dataType.isPushValue = YES;
        return [self execute:dataType];
    }
}
- (RACSignal *)refresh {
    return [self execute:self.lastData.input];
}
- (void)cancel {
    [self.cancelSignal sendNext:nil];
}
- (void)dealloc
{
    [self.cancelSignal sendNext:nil];
}
@end
