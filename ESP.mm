// language: Objective-C++ | file: ESP.mm | target: iOS arm64
#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <QuartzCore/QuartzCore.h>
#include "Offsets.h"
#include "Memory.h"
#include <substrate.h>
#include <cmath>

bool esp_enabled  = true;
bool aimbot_enabled = false;
bool speed_enabled = false;

NSMutableArray *g_actorList = [NSMutableArray array];

// Хуки через substrate
void (*_SetVisible)(void*, int, bool, bool);
void SetVisible(void *inst, int camp, bool vis, bool force) {
    if (inst && esp_enabled) {
        if (camp == 1 || camp == 2 || camp == 110 || camp == 255) vis = true;
    }
    _SetVisible(inst, camp, vis, force);
}

bool (*_IsLocal)(void*);
bool IsLocal(void *inst) {
    if (inst && aimbot_enabled) return true;
    return _IsLocal(inst);
}

void initESP() {
    MSHookFunction(getRealOffset(OFF_SETVISIBLE), (void*)SetVisible, (void**)&_SetVisible);
    MSHookFunction(getRealOffset(OFF_ISLOCAL),    (void*)IsLocal,    (void**)&_IsLocal);
}
