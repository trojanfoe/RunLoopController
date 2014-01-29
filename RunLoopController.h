/*
 * Copyright Andy Duplain (c)2014.
 *
 * See: https://github.com/trojanfoe/RunLoopController
 *
 * Licensed under the MIT License.
 */

#import <Foundation/Foundation.h>

@interface RunLoopController : NSObject <NSMachPortDelegate> {
    NSMachPort *_terminatePort;
    BOOL _terminate;
}

/**
 * Get the number of registered instances.
 *
 * This value can be used to decide to terminate the main thread when no
 * more worker threads exist.
 *
 * @return The number of registered instances.
 */
+ (NSInteger)instanceCount;

/**
 * Retrieve the RunLoopController object associated with the current thread.
 *
 * @return The RunLoopController object associated with the current thread.
 */
+ (RunLoopController *)currentRunLoopController;

/**
 * Retrieve the RunLoopController object associated with the main thread.
 *
 * @return The RunLoopController object associated with the main thread.
 */
+ (RunLoopController *)mainRunLoopController;

/**
 * Register the run loop controller with the current run loop.
 */
- (void)register;

/**
 * Deregister the run loop controller from the current run loop.
 */
- (void)deregister;

/**
 * Run the current run loop.  This is a shortcut for:
 * calling runMode:NSDefaultRunLoopModebeforeDate:[NSDate distantFuture]
 *
 * @return NO if the run loop was asked to terminate, or an error occurred. YES if
 * the run loop finished for another reason.
 */
- (BOOL)run;

/**
 * Run the current run loop.
 *
 * @param mode As per [NSRunLoop runMode:limitDate:].
 * @param limitDate As per [NSRunLoop runMode:limitDate:].
 *
 * @return NO if the run loop was asked to terminate, or an error occurred. YES if
 * the run loop finished for another reason.
 */
- (BOOL)runMode:(NSString *)mode
     beforeDate:(NSDate *)limitDate;

/**
 * Set the terminate flag and signal the associated run loop (calling the
 * -signal method).
 */
- (void)terminate;

/**
 * Determine if the terminate flag is set.
 *
 * @return YES if the run loop should terminate, else NO.
 */
- (BOOL)shouldTerminate;

/**
 * Signal the run loop associated with the run loop controller.
 *
 * This is useful if you want to wake up a run loop so the code running the loop
 * can evaluate conditions for termination (normally the main thread run loop).
 */
- (void)signal;

@end

