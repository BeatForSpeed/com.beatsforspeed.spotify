#import <Spotify/Spotify.h>
#import <Cordova/CDV.h>
#import "CDVSpotify.h"

static NSString * const kClientId = @"spotify-ios-sdk-beta";
static NSString * const kCallbackURL = @"spotify-ios-sdk-beta://callback";
//static NSString * const kTokenSwapURL = @"http://localhost:3000/users/register";
static NSString * const kTokenSwapURL = @"http://localhost:1234/swap";

@interface CDVSpotify ()
@property (nonatomic, readwrite) SPTTrackPlayer *trackPlayer;
@property(nonatomic, copy) NSString *callbackId;
@property(nonatomic, strong) SPTSession *session;
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
    
    self.callbackId = command.callbackId;
    
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
        
    }];
}

-(BOOL)verifyLogin:(NSURL *)url {
    NSLog(@"VERIFYING");
    
    // The sendPluginResult method is thread-safe.
    CDVPluginResult* pluginResult = nil;
    
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
             
             self.session = session;
             
             [self playSong:@"spotify:track:73vllOpuLXzUu1bycglv5L"];
             
             // Call the -playUsingSession: method to play a track
             // [self playUsingSession:session];
         }];

         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                 
         [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
         
        return YES;
    }

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Login failed"];
            
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    
    return NO;
  
}

-(void)playSong:(NSString *)songID {
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
        
        [SPTRequest requestItemAtURI:[NSURL URLWithString:songID]
                         withSession:nil
                            callback:^(NSError *error, SPTTrack *track) {
                                
                                if (error != nil) {
                                    NSLog(@"*** Album lookup got error %@", error);
                                    return;
                                }
                                                                
                                [self.trackPlayer playTrackProvider:prov];
                                
                            }];
    }];
    
}

@end
