/*
 * Copyright Andy Duplain (c)2014.
 *
 * See: https://github.com/trojanfoe/RunLoopController
 *
 * Licensed under the MIT License.
 */

#import <Foundation/Foundation.h>

// Notification name
extern NSString * const AsyncDownloaderFinishedNotification;

// Notification userInfo keys
extern NSString * const AsyncDownloaderFinishedNotificationSucceededKey;    // @(YES) or @(NO)
extern NSString * const AsyncDownloaderFinishedNotificationErrorKey;        // NSError or missing

@interface AsyncDownloader : NSObject <NSURLConnectionDelegate> {
    NSURLConnection *_connection;
    NSMutableData *_responseData;
}

@property (getter=isCancelled) BOOL cancel;
@property (readonly) NSURL *url;
@property (readonly) NSData *responseData;
@property (readonly) NSStringEncoding responseEncoding;
@property (readonly, getter=isFinished) BOOL finished;
@property (readonly) NSError *error;

- (BOOL)downloadFromURL:(NSURL *)url;

@end
