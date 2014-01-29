#import "RunLoopController.h"

#define LOGGING 1

#if LOGGING
#define LOG(fmt, ...) NSLog(fmt, ## __VA_ARGS__)
#else
#define LOG(fmt, ...) /* nothing */
#endif

@interface AsyncDownloader : NSObject <NSURLConnectionDelegate> {
    NSURLConnection *_connection;
    NSMutableData *_responseData;
    NSStringEncoding _responseEncoding;
}

@property RunLoopController *runLoopController;

- (BOOL)startDownload;

@end

@implementation AsyncDownloader

- (BOOL)startDownload {
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];

    // Accept-Charset is not honoured by google.com :-/
    [request addValue:@"utf-8" forHTTPHeaderField:@"Accept-Charset"];

    _connection = [[NSURLConnection alloc] initWithRequest:request
                                                  delegate:self];
    
    LOG(@"Request sent");

    return YES;
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {

    NSString *textEncodingName = response.textEncodingName;
    LOG(@"Received response. Encoding=%@", textEncodingName);
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

    LOG(@"Received %lu bytes", (unsigned long)[data length]);

    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;         // Not necessary
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    LOG(@"Finished loading");

    NSString *responseString = [[NSString alloc] initWithData:_responseData
                                                     encoding:_responseEncoding];

    LOG(@"%@", responseString);

    [self.runLoopController terminate];
}

- (void)connection:(NSURLConnection *)connection
didFailWithError:(NSError *)error {

    LOG(@"Network error: %@", [error localizedDescription]);
    [self.runLoopController terminate];
}

@end

int main(int argc, const char **argv) {
    int retval = 0;
    @autoreleasepool {

        RunLoopController *runLoopController = [RunLoopController new];
        AsyncDownloader *downloader = [AsyncDownloader new];
        downloader.runLoopController = runLoopController;

        [downloader startDownload];

        while ([runLoopController run])
            ;

    }
    return retval;
}

