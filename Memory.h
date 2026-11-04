// language: C++ | file: Memory.h | target: iOS arm64
#pragma once
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <string.h>

uintptr_t getModuleBase(const char *moduleName) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, moduleName))
            return (uintptr_t)_dyld_get_image_header(i);
    }
    return 0;
}

void *getRealOffset(uintptr_t offset) {
    return (void *)(getModuleBase("UnityFramework") + offset);
}

bool vm_writeData(void *address, uint64_t data) {
    vm_protect(mach_task_self(), (vm_address_t)address,
               sizeof(data), false,
               VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    *(uint64_t *)address = data;
    return true;
}
