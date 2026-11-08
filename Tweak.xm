#import <Foundation/Foundation.h>

__attribute__((constructor))
static void init() {
    NSLog(@"[Sabhail Cheat] Empty tweak loaded!");
}
