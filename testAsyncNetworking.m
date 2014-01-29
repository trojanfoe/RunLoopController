/*
 * Copyright Andy Duplain (c)2014.
 *
 * See: https://github.com/trojanfoe/RunLoopController
 *
 * Licensed under the MIT License.
 *
 * Usage: testAsyncDownloader [url ... url]
 * If a url is not specified then http://www.google.com is used.
 */

#import "RunLoopController.h"
#import "AsyncDownloader.h"

#ifdef LOGGING
#define LOG(fmt, ...) NSLog(fmt, ## __VA_ARGS__)
#else
#define LOG(fmt, ...) /* nothing */
#endif

@interface MainObject : NSObject {
    RunLoopController *_runLoopController;
}

- (int)runWithArgc:(int)argc
              argv:(const char **)argv;

@end

@implementation MainObject

- (int)runWithArgc:(int)argc
              argv:(const char **)argv {
    @autoreleasepool {
        _runLoopController = [RunLoopController new];
        [_runLoopController register];

        AsyncDownloader *downloader = [AsyncDownloader new];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadFinished:)
                                                     name:AsyncDownloaderFinishedNotification
                                                   object:nil];

        // Capture the list of URLs
        NSMutableArray *urls = [NSMutableArray new];
        if (argc == 1) {
            [urls addObject:[NSURL URLWithString:@"http://www.google.com"]];
        } else {
            for (int i = 1; i < argc; i++) {
                [urls addObject:[NSURL URLWithString:[NSString stringWithUTF8String:argv[i]]]];
            }
        }

        // Initialize the list of AsyncDownloader objects
        NSMutableArray *downloaders = [NSMutableArray new];
        for (NSURL *url in urls) {
            AsyncDownloader *downloader = [AsyncDownloader new];
            [downloaders addObject:downloader];
        }

        // Start downloading from the URLs
        for (NSInteger i = 0; i < [downloaders count]; i++) {
            AsyncDownloader *downloader = [downloaders objectAtIndex:i];
            [downloader downloadFromURL:[urls objectAtIndex:i]];
        }

        BOOL allFinished = NO;
        while (!allFinished && [_runLoopController run]) {
            // Check if all downloaders have finished
            NSInteger finished = 0;
            for (AsyncDownloader *downloader in downloaders) {
                if (downloader.isFinished)
                    finished++;
            }
            if (finished == [downloaders count]) {
                NSLog(@"All downloaders complete");
                allFinished = YES;
            } else {
                NSLog(@"%ld/%ld downloaders complete", (long)finished, (long)[downloaders count]);
            }
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
        NSLog(@"Failed to download from '%@': %@", downloader.url, [error localizedDescription]);
    }

    [_runLoopController signal];
}

@end


int main(int argc, const char **argv) {
    int retval = 0;
    @autoreleasepool {
        MainObject *mainObject = [MainObject new];
        retval = [mainObject runWithArgc:argc
                                    argv:argv];
    }
    return retval;
}

