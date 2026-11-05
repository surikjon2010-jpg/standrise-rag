#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <mach-o/dyld.h>
#include <substrate.h>
#include <sys/sysctl.h>
#include <sys/ptrace.h>

// Оффсеты ВХ
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

// --- БАЙПАСС: Скрываем наш dylib из списка загруженных ---
const char* (*orig_dyld_get_image_name)(uint32_t image_index);
const char* my_dyld_get_image_name(uint32_t image_index) {
    const char* name = orig_dyld_get_image_name(image_index);
    if (name && (strstr(name, "StandriseRage") || strstr(name, "substrate"))) {
        return "";
    }
    return name;
}

// --- БАЙПАСС: Блокируем ptrace (анти-отладка) ---
int (*orig_ptrace)(int request, pid_t pid, caddr_t addr, int data);
int my_ptrace(int request, pid_t pid, caddr_t addr, int data) {
    if (request == PT_DENY_ATTACH) return 0;
    return orig_ptrace(request, pid, addr, data);
}

// --- ВХ ---
void (*orig_SetVisible)(void* instance, int camp, bool bVisible, bool forceSync);
bool (*orig_IsLocal)(void* instance);

void my_SetVisible(void* instance, int camp, bool bVisible, bool forceSync) {
    if (instance != nullptr) bVisible = true;
    orig_SetVisible(instance, camp, bVisible, forceSync);
}

bool my_IsLocal(void* instance) {
    if (instance != nullptr) return true;
    return orig_IsLocal(instance);
}

__attribute__((constructor))
static void init() {
    NSLog(@"[Sabhail Cheat] Dylib loaded!");
    
    // ВХ
    uintptr_t setVisibleAddr = getRealOffset(OFF_SETVISIBLE);
    if (setVisibleAddr) MSHookFunction((void*)setVisibleAddr, (void*)my_SetVisible, (void**)&orig_SetVisible);
    
    // Байпасс
    MSHookFunction((void*)_dyld_get_image_name, (void*)my_dyld_get_image_name, (void**)&orig_dyld_get_image_name);
    MSHookFunction((void*)ptrace, (void*)my_ptrace, (void**)&orig_ptrace);
}
