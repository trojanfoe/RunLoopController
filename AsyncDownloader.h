/*
 * Copyright Andy Duplain (c)2014.
 *
 * See: https://github.com/trojanfoe/RunLoopController
 *
 * Licensed under the MIT License.
 */

@import Foundation;

// Notification name
extern NSString * const AsyncDownloaderFinishedNotification;

// Notification userInfo keys
extern NSString * const AsyncDownloaderFinishedNotificationSucceededKey;    // @(YES) or @(NO)
extern NSString * const AsyncDownloaderFinishedNotificationErrorKey;        // NSError or missing

@interface AsyncDownloader : NSObject <NSURLConnectionDelegate>

@property (getter=isCancelled)          BOOL   cancel;
@property (getter=isFinished,readonly)  BOOL   finished;

@property (readonly)        NSStringEncoding   responseEncoding;

@property (readonly)                   NSURL * url;
@property (readonly)                  NSData * responseData;
@property (readonly)                 NSError * error;

- (BOOL) downloadFromURL:(NSURL*)url;

@end
