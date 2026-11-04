// language: Objective-C++ | file: Rage.mm | target: iOS arm64
#import "Offsets.h"
#import "Memory.h"
#include "ESP.h"

extern bool aimbot_enabled;
extern bool speed_enabled;

// ---- Aimbot hook on SetRotation / LookAt ----
void (*_SetRotation)(void*, Vec3);
void SetRotation(void *inst, Vec3 rot) {
    if (inst && aimbot_enabled) {
        // найти ближайшего врага и подменить rot на вектор к нему
        extern void *FindNearestEnemy(void *localPlayer);
        void *enemy = FindNearestEnemy(inst);
        if (enemy) {
            Vec3 myPos, enPos;
            memcpy(&myPos, (void*)((uintptr_t)inst + OFF_PLAYER_POS), sizeof(Vec3));
            memcpy(&enPos, (void*)((uintptr_t)enemy + OFF_PLAYER_POS), sizeof(Vec3));
            Vec3 dir = {enPos.x-myPos.x, enPos.y-myPos.y, enPos.z-myPos.z};
            rot.x = atan2(dir.y, sqrt(dir.x*dir.x + dir.z*dir.z)) * 180.0f / M_PI;
            rot.y = atan2(dir.x, dir.z) * 180.0f / M_PI;
        }
    }
    _SetRotation(inst, rot);
}

// ---- Speed hack ----
void (*_SetSpeed)(void*, float);
void SetSpeed(void *inst, float spd) {
    if (inst && speed_enabled) spd *= 3.0f;
    _SetSpeed(inst, spd);
}

// ---- No recoil ----
void (*_ApplyRecoil)(void*, float);
void ApplyRecoil(void *inst, float r) {
    if (inst && aimbot_enabled) r = 0.0f;
    _ApplyRecoil(inst, r);
}

__attribute__((constructor))
static void initRageHooks() {
    // заменить оффсеты на реальные
    DobbyHook(getRealOffset(0x5A12340), (void*)SetRotation, (void**)&_SetRotation);
    DobbyHook(getRealOffset(OFF_MOVE_SPEED), (void*)SetSpeed, (void**)&_SetSpeed);
    DobbyHook(getRealOffset(OFF_WEAPON_RECOIL), (void*)ApplyRecoil, (void**)&_ApplyRecoil);
}
