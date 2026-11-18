#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <mach-o/dyld.h>
#include <substrate.h>
#include <string.h>

// Объявляем ptrace вручную
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
extern ptrace_ptr_t ptrace;

// Байпасс: Скрываем чит и наш байпасс
const char* (*orig_dyld_get_image_name)(uint32_t image_index);
const char* my_dyld_get_image_name(uint32_t image_index) {
    const char* name = orig_dyld_get_image_name(image_index);
    // Скрываем MoodyDLC, наш файл и substrate
    if (name && (strstr(name, "MoodyDLC") || strstr(name, "StandriseRage") || strstr(name, "substrate") || strstr(name, "Cydia"))) {
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

__attribute__((constructor))
static void init() {
    NSLog(@"[Bypass] Dylib loaded!");
    
    // Ставим хуки только на байпасс
    MSHookFunction((void*)_dyld_get_image_name, (void*)my_dyld_get_image_name, (void**)&orig_dyld_get_image_name);
    MSHookFunction((void*)ptrace, (void*)my_ptrace, (void**)&orig_ptrace);
}
