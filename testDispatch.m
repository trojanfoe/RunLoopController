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
        for (unsigned i = 0; i < 4; i++) {
            count++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (i + 1) * NSEC_PER_SEC), q, ^{
                LOG(@"Block %u fired", i);
                count--;

                // signal is used to get the main thread's run loop to terminate, allowing
                // the code below to check if all work is complete
                [[RunLoopController mainRunLoopController] signal];
            });
        }

        while ([runLoopController run]) {
            if (count == 0)
                break;
        }

        [runLoopController deregister];
    }
    return retval;
}

