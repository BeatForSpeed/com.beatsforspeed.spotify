#import <Spotify/Spotify.h>
#import <Cordova/CDV.h>
#import "CDVSpotify.h"

static NSString * const kClientId = @"spotify-ios-sdk-beta";
static NSString * const kCallbackURL = @"spotify-ios-sdk-beta://callback";
static NSString * const kTokenSwapURL = @"http://localhost:1234/swap";

@interface CDVSpotify ()
@property (nonatomic, readwrite) SPTTrackPlayer *trackPlayer;
@end

@implementation CDVSpotify

@synthesize testValue;

- (void)setup
{
    NSLog(@"SETTING UP SPOTIFY");
}

- (void)login:(CDVInvokedUrlCommand*)command
{
    
    NSLog(@"SPOTIFY LOGIN");
    
    testValue = @"Yep";
    
    
    [self.commandDelegate runInBackground:^{
        // Some blocking logic...
        SPTAuth *auth = [SPTAuth defaultInstance];
        NSURL *loginURL = [auth loginURLForClientId:kClientId
                                declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
                                             scopes:@[@"login"]];
        // Opening a URL in Safari close to application launch may trigger
        // an iOS bug, so we wait a bit before doing so.
        [[UIApplication sharedApplication] performSelector:@selector(openURL:)
                                                withObject:loginURL];
        
        // The sendPluginResult method is thread-safe.
        CDVPluginResult* pluginResult = nil;
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(BOOL)verifyLogin:(NSURL *)url {
    NSLog(@"VERIFYING");
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
        
        // Call the token swap service to get a logged in session
        [[SPTAuth defaultInstance]
         handleAuthCallbackWithTriggeredAuthURL:url
         tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapURL]
         callback:^(NSError *error, SPTSession *session) {
             
             if (error != nil) {
                 NSLog(@"*** Auth error: %@", error);
                 return;
             }
             
             // Call the -playUsingSession: method to play a track
             [self playUsingSession:session];
         }];
        return YES;
    }
    
    return NO;
  
}

-(void)playUsingSession:(SPTSession *)session {
    NSLog(@"PLAYING");
    
    // Create a new track player if needed
    if (self.trackPlayer == nil) {
        self.trackPlayer = [[SPTTrackPlayer alloc] initWithCompanyName:@"Your-Company-Name"
                                                               appName:@"Your-App-Name"];
    }
    
    [self.trackPlayer enablePlaybackWithSession:session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        
        [SPTRequest requestItemAtURI:[NSURL URLWithString:@"spotify:album:4L1HDyfdGIkACuygktO7T7"]
                         withSession:nil
                            callback:^(NSError *error, SPTAlbum *album) {
                                
                                if (error != nil) {
                                    NSLog(@"*** Album lookup got error %@", error);
                                    return;
                                }
                                
                                [self.trackPlayer playTrackProvider:album];
                                
                            }];
    }];
    
}

@end
