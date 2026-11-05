// language: Objective-C++ | file: Rage.mm | target: iOS arm64
#import <Foundation/Foundation.h>
#include "Offsets.h"
#include "Memory.h"
#include <substrate.h>
#include <cmath>

extern bool aimbot_enabled;
extern bool speed_enabled;

void (*_SetSpeed)(void*, float);
void SetSpeed(void *inst, float spd) {
    if (inst && speed_enabled) spd *= 3.0f;
    _SetSpeed(inst, spd);
}

void (*_ApplyRecoil)(void*, float);
void ApplyRecoil(void *inst, float r) {
    if (inst && aimbot_enabled) r = 0.0f;
    _ApplyRecoil(inst, r);
}

void initRageHooks() {
    MSHookFunction(getRealOffset(OFF_MOVE_SPEED), (void*)SetSpeed, (void**)&_SetSpeed);
    MSHookFunction(getRealOffset(OFF_WEAPON_RECOIL), (void*)ApplyRecoil, (void**)&_ApplyRecoil);
}
