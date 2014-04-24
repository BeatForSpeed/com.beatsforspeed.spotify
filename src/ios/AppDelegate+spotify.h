//
//  AppDelegate+spotify.h
//  
//
//  Created by Tim Flapper on 24/04/14.
//
//

#import "AppDelegate.h"

@interface AppDelegate (spotify)
- (void)applicationDidBecomeActive:(UIApplication *)application;
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (id) getCommandInstance:(NSString*)className;
@end
