#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <mach-o/dyld.h>
#include <substrate.h>
#include <string.h>

// Объявляем ptrace вручную
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
extern ptrace_ptr_t ptrace;

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

// Байпасс: Скрываем только НАШ dylib и substrate (LSTrial не трогаем)
const char* (*orig_dyld_get_image_name)(uint32_t image_index);
const char* my_dyld_get_image_name(uint32_t image_index) {
    const char* name = orig_dyld_get_image_name(image_index);
    if (name && (strstr(name, "Sabhail") || strstr(name, "substrate") || strstr(name, "Cydia"))) {
        return ""; 
    }
    return name;
}

// Байпасс: Блокируем ptrace
int (*orig_ptrace)(int request, pid_t pid, caddr_t addr, int data);
int my_ptrace(int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) return 0; // 31 = PT_DENY_ATTACH
    return orig_ptrace(request, pid, addr, data);
}

// ВХ
void (*orig_SetVisible)(void* instance, int camp, bool bVisible, bool forceSync);
void my_SetVisible(void* instance, int camp, bool bVisible, bool forceSync) {
    if (instance != nullptr) bVisible = true;
    orig_SetVisible(instance, camp, bVisible, forceSync);
}

bool (*orig_IsLocal)(void* instance);
bool my_IsLocal(void* instance) {
    if (instance != nullptr) return true;
    return orig_IsLocal(instance);
}

__attribute__((constructor))
static void init() {
    NSLog(@"[Sabhail Cheat] Dylib loaded!");
    
    uintptr_t setVisibleAddr = getRealOffset(OFF_SETVISIBLE);
    if (setVisibleAddr) MSHookFunction((void*)setVisibleAddr, (void*)my_SetVisible, (void**)&orig_SetVisible);
    
    MSHookFunction((void*)_dyld_get_image_name, (void*)my_dyld_get_image_name, (void**)&orig_dyld_get_image_name);
    MSHookFunction((void*)ptrace, (void*)my_ptrace, (void**)&orig_ptrace);
}
