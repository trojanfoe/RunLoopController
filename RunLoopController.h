/*
 * Copyright Andy Duplain (c)2014.
 *
 * See: https://github.com/trojanfoe/RunLoopController
 *
 * Licensed under the MIT License.
 */

#import <Foundation/Foundation.h>

@interface RunLoopController : NSObject <NSMachPortDelegate>

@property (nonatomic) BOOL shouldTerminate;

/*! The number of registered instances.
    @note This value can be used to decide to terminate the main thread when no more worker threads exist.
 */
+ (NSInteger) instanceCount;

/// The RunLoopController object associated with the current thread.
+ (RunLoopController*) currentRunLoopController;

/// The RunLoopController object associated with the main thread.
+ (RunLoopController*) mainRunLoopController;

/// Register the run loop controller with the current run loop.
- (void) register;

/// Deregister the run loop controller from the current run loop.
- (void) deregister;

/*! Run the current run loop.  
    @note This is a shortcut for: @see runMode:NSDefaultRunLoopModebeforeDate: with NSDate.distantFuture  
    @return NO if the run loop was asked to terminate, or an error occurred. 
            YES if the run loop finished for another reason.
 */
- (BOOL) run;

/*! Run the current run loop.
    @param mode       As per [NSRunLoop runMode:limitDate:].
    @param limitDate  As per [NSRunLoop runMode:limitDate:].
    @return NO        if the run loop was asked to terminate, or an error occurred.
            YES       if the run loop finished for another reason.
 */
- (BOOL)runMode:(NSString*)mode beforeDate:(NSDate*)limitDate;

/// Set the terminate flag and signal the associated run loop (calling the @c -signal method).
//- (void) terminate;

/// Determine if the terminate flag is set. YES if the run loop should terminate, else NO.
//- (BOOL) shouldTerminate;

/*! Signal the run loop associated with the run loop controller.
    @note This is useful if you want to wake up a run loop so the code running the loop 
          can evaluate conditions for termination (normally the main thread run loop).
 */
- (void)  signal;

@end

