#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <mach-o/dyld.h>
#include <substrate.h>

// Оффсеты из dump.cs
#define OFF_SETVISIBLE 0x5F145F8
#define OFF_ISLOCAL    0x18E576C

uintptr_t getRealOffset(uintptr_t offset) {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char* name = _dyld_get_image_name(i);
        if (name && strstr(name, "UnityFramework")) {
            return (uintptr_t)_dyld_get_image_header(i) + offset;
        }
    }
    return 0;
}

// Оригинальные функции
void (*orig_SetVisible)(void* instance, int camp, bool bVisible, bool forceSync);
bool (*orig_IsLocal)(void* instance);

// Наши хуки
void my_SetVisible(void* instance, int camp, bool bVisible, bool forceSync) {
    if (instance != nullptr) {
        // Заставляем игру всегда рисовать модель
        bVisible = true; 
    }
    orig_SetVisible(instance, camp, bVisible, forceSync);
}

bool my_IsLocal(void* instance) {
    if (instance != nullptr) {
        return true; // Для аима (пока просто заглушка)
    }
    return orig_IsLocal(instance);
}

__attribute__((constructor))
static void init() {
    NSLog(@"[Sabhail Cheat] Dylib loaded!");
    
    uintptr_t setVisibleAddr = getRealOffset(OFF_SETVISIBLE);
    uintptr_t isLocalAddr = getRealOffset(OFF_ISLOCAL);
    
    if (setVisibleAddr) {
        MSHookFunction((void*)setVisibleAddr, (void*)my_SetVisible, (void**)&orig_SetVisible);
        NSLog(@"[Sabhail Cheat] SetVisible hooked!");
    }
    if (isLocalAddr) {
        MSHookFunction((void*)isLocalAddr, (void*)my_IsLocal, (void**)&orig_IsLocal);
        NSLog(@"[Sabhail Cheat] IsLocal hooked!");
    }
}
