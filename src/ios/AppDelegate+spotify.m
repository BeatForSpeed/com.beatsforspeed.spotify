//
//  AppDelegate+spotify.m
//  
//
//  Created by Tim Flapper on 24/04/14.
//
//

#import "AppDelegate+spotify.h"
#import "CDVSpotify.h"

@implementation AppDelegate (spotify)

- (id) getCommandInstance:(NSString*)className
{
    
    
	return [self.viewController getCommandInstance:className];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"APP ACTIVATED");
    
    CDVSpotify *spotGap = [self getCommandInstance:@"Spotify"];
    
    [spotGap setup];
}

// Handle auth callback
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"openURL");
    
    CDVSpotify *spotGap = [self getCommandInstance:@"Spotify"];
    
    return [spotGap verifyLogin:url];
}

@end
