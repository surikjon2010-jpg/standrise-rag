// language: C++ | file: ESP.h | target: iOS arm64
#pragma once
#include <cmath>

struct Vec3 { float x, y, z; };
struct Vec2 { float x, y; };

bool WorldToScreen(Vec3 world, Vec2 &screen, float matrix[16], int w, int h) {
    float cx = world.x*matrix[0] + world.y*matrix[4] + world.z*matrix[8]  + matrix[12];
    float cy = world.x*matrix[1] + world.y*matrix[5] + world.z*matrix[9]  + matrix[13];
    float cw = world.x*matrix[3] + world.y*matrix[7] + world.z*matrix[11] + matrix[15];
    if (cw < 0.1f) return false;
    screen.x = (cx/cw + 1.0f) * 0.5f * w;
    screen.y = (1.0f - cy/cw) * 0.5f * h;
    return true;
}
