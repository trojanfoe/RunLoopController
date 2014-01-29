#import "RunLoopController.h"

#define LOGGING 1

#if LOGGING
#define LOG(fmt, ...) NSLog(fmt, ## __VA_ARGS__)
#else
#define LOG(fmt, ...) /* nothing */
#endif

static NSString * const _threadDictKey = @"RunLoopController";
static NSInteger _instanceCount = 0;

// Private Methods
@interface RunLoopController ()
- (void)_signal;
@end

@implementation RunLoopController

#pragma mark - RunLoopController methods

+ (NSInteger)instanceCount {
    return _instanceCount;
}

- (void)register {
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    _terminatePort = [NSMachPort new];
    _terminatePort.delegate = self;
    [runloop addPort:_terminatePort
             forMode:NSDefaultRunLoopMode];

    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    [threadDict setObject:self forKey:_threadDictKey];

    _instanceCount++;

    LOG(@"%p: register. instanceCount=%ld", self, (long)_instanceCount);
}

- (void)deregister {

    NSAssert(_terminatePort, @"Object is not registered");

    _instanceCount--;

    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    [threadDict removeObjectForKey:_threadDictKey];

    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop removePort:_terminatePort
                forMode:NSDefaultRunLoopMode];
    [_terminatePort invalidate];
    _terminatePort = nil;

    LOG(@"%p: deregister. instanceCount=%ld", self, (long)_instanceCount);
}
 
- (BOOL)run {
    return [self runMode:NSDefaultRunLoopMode
              beforeDate:[NSDate distantFuture]];
}

- (BOOL)runMode:(NSString *)mode
        beforeDate:(NSDate *)limitDate {

    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    if (![runloop runMode:mode
              beforeDate:limitDate]) {
        LOG(@"%p: Error in [NSRunLoop runMode:beforeDate:]", self);
        return NO;
    }

    return !_terminate;
}

- (void)terminate {

    LOG(@"%p: Terminating", self);

    _terminate = YES;
    [self _signal];

    // If we are not the main thread, then find the RunLoopController for the main thread
    // and also signal it's mach port to wake up its run loop
    if (![NSThread isMainThread]) {
        LOG(@"%p: Signalling main thread's run loop controller", self);

        NSThread *mainThread = [NSThread mainThread];
        RunLoopController *runLoopController = [[mainThread threadDictionary] objectForKey:_threadDictKey];
        [runLoopController _signal];
    }
}

- (BOOL)shouldTerminate {
    return _terminate;
}

- (void)_signal {
    [_terminatePort sendBeforeDate:[NSDate date]
                        components:nil
                              from:nil
                          reserved:0];
}

#pragma mark - NSMachPortDelegate methods

- (void)handleMachMessage:(void *)machMessage {
    LOG(@"%p: Mach message received", self);
}

@end
