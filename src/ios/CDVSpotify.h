#import <Cordova/CDVPlugin.h>

@interface CDVSpotify : CDVPlugin
{
    NSString *testValue;
}

@property (nonatomic, strong) NSString *testValue;

- (void)login:(CDVInvokedUrlCommand*)command;
- (BOOL)verifyLogin:(NSURL *)url;
- (void)setup;
@end