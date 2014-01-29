/*
 * Copyright Andy Duplain (c)2014.
 *
 * See: https://github.com/trojanfoe/RunLoopController
 *
 * Licensed under the MIT License.
 */

#import "RunLoopController.h"

#ifdef LOGGING
#define LOG(fmt, ...) NSLog(fmt, ## __VA_ARGS__)
#else
#define LOG(fmt, ...) /* nothing */
#endif

static NSString * const _threadDictKey = @"RunLoopController";
static NSInteger _instanceCount = 0;

@implementation RunLoopController

#pragma mark - RunLoopController methods

+ (RunLoopController *)currentRunLoopController {
    return [[[NSThread currentThread] threadDictionary] objectForKey:_threadDictKey];
}

+ (RunLoopController *)mainRunLoopController {
    return [[[NSThread mainThread] threadDictionary] objectForKey:_threadDictKey];
}

+ (NSInteger)instanceCount {
    return _instanceCount;
}

- (void)register {

    NSAssert(![RunLoopController currentRunLoopController], @"Already registered");

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

    NSAssert([RunLoopController currentRunLoopController], @"Not registered");

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
    [self signal];

    // If we are not the main thread, then find the RunLoopController for the main thread
    // and also signal it's mach port to wake up its run loop
    if (![NSThread isMainThread]) {
        LOG(@"%p: Signalling main thread's run loop controller", self);

        RunLoopController *runLoopController = [RunLoopController mainRunLoopController];
        [runLoopController signal];
    }
}

- (BOOL)shouldTerminate {
    return _terminate;
}

- (void)signal {
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
