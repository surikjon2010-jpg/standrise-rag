// language: Objective-C++ | file: Tweak.xm | target: iOS arm64
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ESP.h"

NSMutableArray *g_actorList = nil;

%hook LActorRoot
- (instancetype)init {
    self = %orig;
    if (!g_actorList) g_actorList = [NSMutableArray array];
    [g_actorList addObject:[NSValue valueWithPointer:(__bridge void*)self]];
    return self;
}
%end

// античит — глушим словарь
%hook AntiCheatChecker
- (NSDictionary *)collectChecks {
    return @{
        @"Root": @NO,
        @"Injected": @NO,
        @"Dylibs": @[],
        @"Mod": @NO,
        @"InstallMode": @"AppStore",
        @"IsDebugged": @NO,
    };
}
%end

%hook UnityAppController
- (void)applicationDidBecomeActive:(UIApplication *)app {
    %orig;
    [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 repeats:YES block:^(NSTimer *t){
        DrawESP();
    }];
}
%end
