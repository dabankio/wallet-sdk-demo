#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#include "Wallet/Mobile.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //sdk binding
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel* walletChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"walletcore/eth"
                                            binaryMessenger:controller];
    
    [walletChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        // Note: this method is invoked on the UI thread.
        // TODO
        
        if ([@"buildTime" isEqualToString:call.method]) {
            NSString* t = MobileGetBuildTime();
            
            result(t);
            
//            if (batteryLevel == -1) {
//                result([FlutterError errorWithCode:@"UNAVAILABLE"
//                                           message:@"Battery info unavailable"
//                                           details:nil]);
//            } else {
//                result(@(batteryLevel));
//            }
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
