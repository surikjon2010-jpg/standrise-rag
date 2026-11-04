// language: Objective-C++ | file: ESP.mm | target: iOS arm64
#import "ESP.h"
#import "Offsets.h"
#import "Memory.h"
#import <OpenGLES/ES3/gl.h>
#import <QuartzCore/QuartzCore.h>

bool esp_enabled  = true;
bool aimbot_enabled = false;
bool speed_enabled = false;

// ---- SetVisible hook ----
void (*_SetVisible)(void*, int, bool, bool);
void SetVisible(void *inst, int camp, bool vis, bool force) {
    if (inst && esp_enabled) {
        if (camp == 1 || camp == 2 || camp == 110 || camp == 255) vis = true;
    }
    _SetVisible(inst, camp, vis, force);
}

// ---- IsLocal hook ----
bool (*_IsLocal)(void*);
bool IsLocal(void *inst) {
    if (inst && aimbot_enabled) return true;
    return _IsLocal(inst);
}

// ---- Camera matrix ----
void GetProjectionMatrix(float m[16]) {
    void *cam = *(void **)getRealOffset(OFF_CAMERA_MAIN);
    if (!cam) return;
    memcpy(m, (void *)((uintptr_t)cam + OFF_PROJECTION), sizeof(float)*16);
}

Vec3 GetPlayerPos(void *actor) {
    Vec3 p = {0,0,0};
    memcpy(&p, (void *)((uintptr_t)actor + OFF_PLAYER_POS), sizeof(Vec3));
    return p;
}

// ---- ESP draw ----
extern NSMutableArray *g_actorList;

void DrawESP() {
    if (!esp_enabled) return;
    float m[16]; GetProjectionMatrix(m);
    int w = (int)([UIScreen mainScreen].bounds.size.width  * [UIScreen mainScreen].scale);
    int h = (int)([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale);

    for (NSValue *v in g_actorList) {
        void *actor = [v pointerValue];
        Vec3 pos = GetPlayerPos(actor);
        Vec2 s;
        if (!WorldToScreen(pos, s, m, w, h)) continue;
        glEnable(GL_SCISSOR_TEST);
        glScissor((int)(s.x-30), (int)(s.y-100), 60, 100);
        glClearColor(1,0,0,0.8f);
        glClear(GL_COLOR_BUFFER_BIT);
        glDisable(GL_SCISSOR_TEST);
    }
}

// ---- Init ----
__attribute__((constructor))
static void initRage() {
    DobbyHook(getRealOffset(OFF_SETVISIBLE), (void*)SetVisible, (void**)&_SetVisible);
    DobbyHook(getRealOffset(OFF_ISLOCAL),    (void*)IsLocal,    (void**)&_IsLocal);
}
