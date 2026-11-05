#import <Foundation/Foundation.h>

extern void initRageHooks();
extern void initESP();

__attribute__((constructor))
static void initAll() {
    initRageHooks();
    initESP();
}
