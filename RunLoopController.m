/*
 * Copyright Andy Duplain (c)2014.
 *
 * See: https://github.com/trojanfoe/RunLoopController
 *
 * Licensed under the MIT License.
 */

#ifndef WANT_RUNLOOP_LOGGER
#define WANT_RUNLOOP_LOGGER
#endif

#import "RunLoopController.h"

static NSString * const _threadDictKey = @"RunLoopController";
static NSInteger _instanceCount = 0;

@implementation RunLoopController { NSMachPort *_terminatePort; }

#pragma mark - RunLoopController methods

+ (RunLoopController *)currentRunLoopController {

    return NSThread.currentThread.threadDictionary[_threadDictKey];
}

+ (RunLoopController *)mainRunLoopController {

    return NSThread.mainThread.threadDictionary[_threadDictKey];
}

+ (NSInteger)instanceCount { return _instanceCount; }

- (void) register {

    NSAssert(!RunLoopController.currentRunLoopController, @"Already registered");

    NSRunLoop *runloop      = NSRunLoop.currentRunLoop;
    _terminatePort          = NSMachPort.new;
    _terminatePort.delegate = self;

    [runloop addPort:_terminatePort forMode:NSDefaultRunLoopMode];

    NSThread.currentThread.threadDictionary[_threadDictKey] = self;

    _instanceCount++;

    LOG(@"%p: register. instanceCount=%ld", self, (long)_instanceCount);
}

- (void)deregister {

    NSAssert(RunLoopController.currentRunLoopController, @"Not registered");

    _instanceCount--;

    [NSThread.currentThread.threadDictionary removeObjectForKey:_threadDictKey];

    NSRunLoop *runloop = NSRunLoop.currentRunLoop;

    [runloop removePort:_terminatePort forMode:NSDefaultRunLoopMode];
    [_terminatePort invalidate];
    _terminatePort = nil;

    LOG(@"%p: deregister. instanceCount=%ld", self, (long)_instanceCount);
}
 
- (BOOL)run { return [self runMode:NSDefaultRunLoopMode beforeDate:NSDate.distantFuture]; }

- (BOOL)runMode:(NSString*)mode beforeDate:(NSDate*)limitDate {

  return ![NSRunLoop.currentRunLoop runMode:mode beforeDate:limitDate]
         ? ({ LOG(@"%p: Error in [NSRunLoop runMode:beforeDate:]", self); NO; })
         : !self.shouldTerminate;
}

- (void) setShouldTerminate:(BOOL)shouldTerminate {

  if (shouldTerminate) {

    LOG(@"%p: Terminating", self);

    _shouldTerminate = shouldTerminate;
    [self signal];

    // If we are not the main thread, then find the RunLoopController for the main thread
    // and also signal it's mach port to wake up its run loop
    if (NSThread.isMainThread) return;

    LOG(@"%p: Signalling main thread's run loop controller", self);
    [RunLoopController.mainRunLoopController signal];

  }
}

- (void) signal {

    [_terminatePort sendBeforeDate:NSDate.date components:nil from:nil reserved:0];
}

#pragma mark - NSMachPortDelegate methods

- (void) handleMachMessage:(void*)machMessage { LOG(@"%p: Mach message received", self); }

@end
