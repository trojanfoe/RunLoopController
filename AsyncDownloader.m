/*
 * Copyright Andy Duplain (c)2014.
 *
 * See: https://github.com/trojanfoe/RunLoopController
 *
 * Licensed under the MIT License.
 */

#import "AsyncDownloader.h"

#ifdef LOGGING
#define LOG(fmt, ...) NSLog(fmt, ## __VA_ARGS__)
#else
#define LOG(fmt, ...) /* nothing */
#endif

NSString * const AsyncDownloaderFinishedNotification = @"AsyncDownloaderFinishedNotification";
NSString * const AsyncDownloaderFinishedNotificationSucceededKey = @"AsyncDownloaderFinishedNotificationSucceeded";
NSString * const AsyncDownloaderFinishedNotificationErrorKey = @"AsyncDownloaderFinishedNotificationError";
static NSString * const _asyncDownloaderErrorDomain = @"AsyncDownloaderErrorDomain";

// Private Methods
@interface AsyncDownloader ()

- (void)_sendFinishedNotification;
- (void)_setErrorWithString:(NSString *)message
            underlyingError:(NSError *)underlyingError;

@end

@implementation AsyncDownloader

@synthesize cancel = _cancel;
@synthesize url = _url;
@synthesize responseEncoding = _responseEncoding;
@synthesize finished = _finished;
@synthesize error = _error;

- (BOOL)downloadFromURL:(NSURL *)url {
    _url = url;
    _connection = nil;
    _responseData = nil;
    _cancel = NO;
    _responseEncoding = NSUTF8StringEncoding;
    _error = nil;

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (!request) {
        _finished = YES;
        [self _setErrorWithString:@"Failed to create NSURLRequest object"
                  underlyingError:nil];
        [self _sendFinishedNotification];
        return NO;
    }

    _connection = [[NSURLConnection alloc] initWithRequest:request
                                                  delegate:self];
    if (!_connection) {
        _finished = YES;
        [self _setErrorWithString:@"Failed to create NSURLConnection object"
                  underlyingError:nil];
        [self _sendFinishedNotification];
        return NO;
    }
    
    LOG(@"Request to '%@' sent", url);

    return YES;
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {

    if (_cancel)
        return;

    NSString *textEncodingName = response.textEncodingName;
    LOG(@"Received response from '%@'. Encoding=%@", _url, textEncodingName);
    _responseData = [NSMutableData new];
    if (textEncodingName) {
        CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)textEncodingName);
        _responseEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
    } else {
        _responseEncoding = NSUTF8StringEncoding;
    }
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {

    if (_cancel)
        return;

    LOG(@"Received %lu bytes from '%@'", (unsigned long)[data length], _url);

    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;         // Not necessary
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    LOG(@"Finished downloading from '%@'", _url);
    _finished = YES;
    [self _sendFinishedNotification];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {

    LOG(@"Error downloading from '%@': %@", _url, [error localizedDescription]);
    _finished = YES;
    [self _setErrorWithString:@"Failed to download"
              underlyingError:error];
    [self _sendFinishedNotification];
}

- (void)_sendFinishedNotification {
    NSAssert(_finished, @"Download didn't finish!");

    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (_error) {
        userInfo[AsyncDownloaderFinishedNotificationSucceededKey] = @(NO);
        userInfo[AsyncDownloaderFinishedNotificationErrorKey] = _error;
    } else {
        userInfo[AsyncDownloaderFinishedNotificationSucceededKey] = @(YES);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:AsyncDownloaderFinishedNotification
                                                        object:self
                                                    userInfo:userInfo];
}

- (void)_setErrorWithString:(NSString *)message
            underlyingError:(NSError *)underlyingError {

    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (message)
        userInfo[NSLocalizedDescriptionKey] = message;
    if (underlyingError)
        userInfo[NSUnderlyingErrorKey] = underlyingError;

    _error = [NSError errorWithDomain:_asyncDownloaderErrorDomain
                                 code:0
                             userInfo:userInfo];
}

@end
