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

int main(int argc, const char **argv) {
    int retval = 0;
    @autoreleasepool {

        RunLoopController *runLoopController = [RunLoopController new];
        [runLoopController register];
        
        __block NSInteger count = 0;
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        for (unsigned i = 0; i < 8; i++) {
            LOG(@"Dispatching block %u", i);
            count++;
            if (i < 4) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (i + 1) * NSEC_PER_SEC), q, ^{
                    LOG(@"Block %u fired", i);

                    // Decrement the count and signal the main thread's run loop, allowing
                    // the code below to check if all work is complete
                    count--;
                    [[RunLoopController mainRunLoopController] signal];
                });
            } else {
                dispatch_async(q, ^{
                    [NSThread sleepForTimeInterval:i - 3.0f]; 
                    LOG(@"Block %u finished", i);

                    // Decrement the count and signal the main thread's run loop, allowing
                    // the code below to check if all work is complete
                    count--;
                    [[RunLoopController mainRunLoopController] signal];
                });
            }
        }

        while ([runLoopController run]) {
            if (count == 0)
                break;
        }

        [runLoopController deregister];
    }
    return retval;
}

