/*
 * Copyright Andy Duplain (c)2014.
 *
 * See: https://github.com/trojanfoe/RunLoopController
 *
 * Licensed under the MIT License.
 *
 * usage: testAsyncNetworking [options] [url ... url]
 * options:
 *     -s:        Use a single thread.
 * If a url is not specified then http://www.google.com is used.
 */

#import "RunLoopController.h"
#import "AsyncDownloader.h"

// Move the implementation from main() into MainObject in order to receive notifications.
@interface MainObject : NSObject {
    RunLoopController *_runLoopController;
}

@property (readonly, getter=isFinished) BOOL finished;

- (int)runWithArguments:(NSArray *)arguments;

@end

@implementation MainObject

@synthesize finished = _finished;

- (int)runWithArguments:(NSArray *)arguments {
    @autoreleasepool {
        _runLoopController = [RunLoopController new];
        [_runLoopController register];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadFinished:)
                                                     name:AsyncDownloaderFinishedNotification
                                                   object:nil];

        if ([arguments count] == 0)
            arguments = @[ @"http://www.google.com" ];

        NSMutableArray *downloaders = [NSMutableArray new];
        for (NSString *urlString in arguments) {
            AsyncDownloader *downloader = [AsyncDownloader new];
            [downloaders addObject:downloader];
            [downloader downloadFromURL:[NSURL URLWithString:urlString]];
        }

        // Wait until all downloaders are finished
        BOOL allFinished = NO;
        while (!allFinished && [_runLoopController run]) {
            NSInteger finished = 0;
            for (AsyncDownloader *downloader in downloaders)
                if (downloader.isFinished)
                    finished++;
            NSLog(@"%ld/%ld downloaders complete", (long)finished, (long)[downloaders count]);
            allFinished = (finished == [downloaders count]);
        }

        _finished = YES;
        if (![NSThread isMainThread]) {
            [[RunLoopController mainRunLoopController] signal];
        }

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AsyncDownloaderFinishedNotification
                                                      object:nil];

        [_runLoopController deregister];

    }
    return 0;
}

- (void)downloadFinished:(NSNotification *)notification {

    AsyncDownloader *downloader = (AsyncDownloader *)[notification object];
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *succeeded = userInfo[AsyncDownloaderFinishedNotificationSucceededKey];
    NSAssert(succeeded, @"Expected a succeeded value in the notification userInfo dictionary");

    if ([succeeded boolValue]) {
        NSLog(@"Download complete from '%@'", downloader.url);
    } else {
        NSError *error = userInfo[AsyncDownloaderFinishedNotificationErrorKey];
        NSAssert(error, @"Expected an error value in the notification userInfo dictionary");
        NSError *underlyingError = (NSError *)[[error userInfo] objectForKey:NSUnderlyingErrorKey];
        if (underlyingError) {
            NSLog(@"Failed to download from '%@': %@: %@",
                downloader.url, [error localizedDescription], [underlyingError localizedDescription]);
        } else {
            NSLog(@"Failed to download from '%@': %@",
                downloader.url, [error localizedDescription]);
        }
    }

    [_runLoopController signal];
}

@end

int main(int argc, const char **argv) {
    int retval = 0;
    @autoreleasepool {
        int opt;
        BOOL singleThread = NO;
        while ((opt = getopt(argc, (char * const *)argv, "s")) != -1) {
            switch (opt) {
                case 's':
                    singleThread = YES;
                    break;
                default:
                    NSLog(@"Invalid option '%c'", (char)opt);
                    return 1;
            }
        }
        argc -= optind;
        argv += optind;

        if (singleThread) {
            // Send all URLs to [MainObject runWithArguments:] on the current (main) thread
            NSLog(@"Using a single thread");
            MainObject *mainObj = [MainObject new];
            NSMutableArray *arguments = [NSMutableArray new];
            for (int i = 0; i < argc; i++)
                [arguments addObject:[NSString stringWithUTF8String:argv[i]]];
            retval = [mainObj runWithArguments:arguments];
        } else {
            NSInteger count = MAX(argc, 1);
            NSLog(@"Using %ld threads", (long)count);

            RunLoopController *runLoopController = [RunLoopController new];
            [runLoopController register];

            // Send each URL to [MainObject runWithArguments:] using a separate thread
            NSMutableArray *mainObjs = [NSMutableArray new];
            for (NSInteger i = 0; i < count; i++) {
                MainObject *mainObj = [MainObject new];
                NSMutableArray *arguments = [NSMutableArray new];
                if (i + 1 < argc)
                    [arguments addObject:[NSString stringWithUTF8String:argv[i + 1]]];
                [mainObjs addObject:mainObj];
                [NSThread detachNewThreadSelector:@selector(runWithArguments:)
                                         toTarget:mainObj
                                       withObject:arguments];
            }

            // Wait until all MainObject objects are finished
            BOOL allFinished = NO;
            while (!allFinished && [runLoopController run]) {
                NSInteger finished = 0;
                for (MainObject *mainObj in mainObjs)
                    if (mainObj.isFinished)
                        finished++;
                NSLog(@"%ld/%ld mainObjects complete", (long)finished, (long)[mainObjs count]);
                allFinished = (finished == [mainObjs count]);
            }

            [runLoopController deregister];
        }
    }
    return retval;
}

