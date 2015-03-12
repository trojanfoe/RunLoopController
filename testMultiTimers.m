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

@interface TimerThread : NSThread {
    NSTimer *_timer;
}
@property NSTimeInterval sleepTime;
@property RunLoopController *runLoopController;
@end

@implementation TimerThread

@synthesize sleepTime = _sleepTime;
@synthesize finished = _finished;

- (void)main {
    LOG(@"%p: Starting", self);

    self.runLoopController = [RunLoopController new];
    [self.runLoopController register];

    _timer = [NSTimer scheduledTimerWithTimeInterval:_sleepTime
                                              target:self
                                            selector:@selector(timerFired:)
                                            userInfo:nil
                                             repeats:NO];

    while ([self.runLoopController run])
        ;

    [self.runLoopController deregister];
}

- (void)timerFired:(NSTimer *)timer {
    LOG(@"%p: Fired", self);
    _finished = YES;
    [self.runLoopController setShouldTerminate:YES];
}

@end

int main(int argc, const char **argv) {
    int retval = 0;
    @autoreleasepool {

        RunLoopController *runLoopController = [RunLoopController new];
        [runLoopController register];
        
        TimerThread *threads[4];
        for (unsigned i = 0; i < 4; i++) {
            LOG(@"Creating timer %u", i);
            threads[i] = [TimerThread new];
            threads[i].sleepTime = i + 1.0;
            [threads[i] start];
        }

        while ([runLoopController run]) {

            // As the global instance count isn't updated until the RunLoopController
            // object is dealloc'd, we have to determine which timer thread have
            // finished and explicitly "release" them:
            for (unsigned i = 0; i < 4; i++) {
                if (threads[i].finished) {
                    LOG(@"Thread %u has finished", i);
                    threads[i] = nil;
                }
            }

            if ([RunLoopController instanceCount] == 1)
                break;
        }

        [runLoopController deregister];
    }
    return retval;
}

