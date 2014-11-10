#import "SPTDataLoaderService.h"

#import "SPTDataLoader+Private.h"
#import "SPTDataLoaderFactory+Private.h"
#import "SPTCancellationTokenFactoryImplementation.h"
#import "SPTCancellationToken.h"

@interface SPTDataLoaderService () <SPTDataLoaderPrivateDelegate, SPTCancellationTokenDelegate>

@property (nonatomic, strong) id<SPTCancellationTokenFactory> cancellationTokenFactory;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *sessionQueue;

@end

@implementation SPTDataLoaderService

#pragma mark SPTDataLoaderService

+ (instancetype)dataLoaderServiceWithUserAgent:(NSString *)userAgent
{
    return [[self alloc] initWithUserAgent:userAgent];
}

- (instancetype)initWithUserAgent:(NSString *)userAgent
{
    const NSTimeInterval SPTDataLoaderServiceTimeoutInterval = 20.0;
    
    NSString * const SPTDataLoaderServiceUserAgentHeader = @"User-Agent";
    
    if (!(self = [super init])) {
        return nil;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = SPTDataLoaderServiceTimeoutInterval;
    configuration.timeoutIntervalForResource = SPTDataLoaderServiceTimeoutInterval;
    configuration.HTTPShouldUsePipelining = YES;
    if (userAgent) {
        configuration.HTTPAdditionalHeaders = @{ SPTDataLoaderServiceUserAgentHeader : userAgent };
    }
    
    _cancellationTokenFactory = [SPTCancellationTokenFactoryImplementation new];
    _sessionQueue = [NSOperationQueue new];
    _sessionQueue.maxConcurrentOperationCount = 1;
    _sessionQueue.name = NSStringFromClass(self.class);
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:_sessionQueue];
    
    return self;
}

- (SPTDataLoaderFactory *)createDataLoaderFactory
{
    return [SPTDataLoaderFactory dataLoaderFactoryWithPrivateDelegate:self];
}

#pragma mark SPTDataLoaderPrivateDelegate

- (id<SPTCancellationToken>)performRequest:(SPTDataLoaderRequest *)request
{
    return [self.cancellationTokenFactory createCancellationTokenWithDelegate:self];
}

#pragma mark SPTCancellationTokenDelegate

- (void)cancellationTokenDidCancel:(id<SPTCancellationToken>)cancellationToken
{
    
}

@end
