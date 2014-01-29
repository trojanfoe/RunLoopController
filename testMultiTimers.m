#import "RunLoopController.h"

#define LOGGING 1

#if LOGGING
#define LOG(fmt, ...) NSLog(fmt, ## __VA_ARGS__)
#else
#define LOG(fmt, ...) /* nothing */
#endif

@interface TimerThread : NSThread {
    NSTimer *_timer;
}
@property NSTimeInterval sleepTime;
@property RunLoopController *runLoopController;
@property (readonly, assign) BOOL finished;
@end

@implementation TimerThread

@synthesize sleepTime = _sleepTime;
@synthesize finished = _finished;

- (void)main {
    LOG(@"%p: Starting", self);

    self.runLoopController = [RunLoopController new];
    _timer = [NSTimer scheduledTimerWithTimeInterval:_sleepTime
                                              target:self
                                            selector:@selector(timerFired:)
                                            userInfo:nil
                                             repeats:NO];

    while ([self.runLoopController run])
        ;
}

- (void)timerFired:(NSTimer *)timer {
    LOG(@"%p: Fired", self);
    _finished = YES;
    [self.runLoopController terminate];
}

@end

int main(int argc, const char **argv) {
    int retval = 0;
    @autoreleasepool {

        RunLoopController *runLoopController = [RunLoopController new];
        
        TimerThread *threads[4];
        for (unsigned i = 0; i < 4; i++) {
            LOG(@"Creating timer %u", i);
            threads[i] = [TimerThread new];
            threads[i].sleepTime = i;
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
    }
    return retval;
}

