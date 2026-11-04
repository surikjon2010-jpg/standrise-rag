// language: C++ | file: Offsets.h | target: iOS arm64
#pragma once

// ЗАМЕНИТЬ на актуальные из dump.cs Standrise Rework.
// Ниже — примерные заглушки, НЕ рабочие.

#define OFF_SETVISIBLE      0x5F145F8   // LVActorLinker::SetVisible
#define OFF_ISLOCAL         0x18E576C   // get_IsLocal
#define OFF_CAMERA_MAIN     0x1A3B9C0   // Camera.main static field
#define OFF_PROJECTION      0x2C4       // Camera.projectionMatrix field
#define OFF_PLAYER_POS      0xB8        // LActorRoot::Position field
#define OFF_PLAYER_HP       0xC0        // LActorRoot::Health field
#define OFF_WEAPON_RECOIL   0x1F0       // Weapon::recoil field
#define OFF_MOVE_SPEED      0x98        // CharacterController::speed

// Античит
#define OFF_AC_COLLECT      0x2A1B3D0   // AntiCheat::collectChecks
#define OFF_AC_KICK         0x2A1B9C0   // AntiCheat::kick
