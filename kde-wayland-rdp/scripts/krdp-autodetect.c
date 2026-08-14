/* Force FreeRDP_NetworkAutoDetect so mstsc RTT measure PDUs are accepted.
 * Also keep session QSize non-zero and replay last pointer position before
 * button clicks so fake_input is not left at 0,0 (Kickoff). */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

#ifndef WINPR_BOOL_DEFINED
typedef int BOOL;
#endif

/* settings_keys.h: FreeRDP_NetworkAutoDetect = 137 */
#define FREERDP_NETWORK_AUTODETECT 137

#define PTR_FLAGS_MOVE 0x0800
#define PTR_FLAGS_BUTTON1 0x1000
#define PTR_FLAGS_BUTTON2 0x2000
#define PTR_FLAGS_BUTTON3 0x4000
#define PTR_FLAGS_DOWN 0x8000
#define PTR_FLAGS_BUTTON_MASK (PTR_FLAGS_BUTTON1 | PTR_FLAGS_BUTTON2 | PTR_FLAGS_BUTTON3)

typedef BOOL (*get_bool_fn)(const void *settings, size_t id);
typedef BOOL (*set_bool_fn)(void *settings, size_t id, BOOL val);

BOOL freerdp_settings_get_bool(const void *settings, size_t id)
{
    static get_bool_fn real;
    if (!real)
        real = (get_bool_fn)dlsym(RTLD_NEXT, "freerdp_settings_get_bool");
    if (id == FREERDP_NETWORK_AUTODETECT)
        return 1;
    return real ? real(settings, id) : 0;
}

BOOL freerdp_settings_set_bool(void *settings, size_t id, BOOL val)
{
    static set_bool_fn real;
    if (!real)
        real = (set_bool_fn)dlsym(RTLD_NEXT, "freerdp_settings_set_bool");
    if (id == FREERDP_NETWORK_AUTODETECT)
        val = 1;
    return real ? real(settings, id, val) : 0;
}

/* Keep QSize 1920x1080 so motion scale is not 0. Qt6 QSize is two ints in rax. */
typedef unsigned long long (*size_fn)(void *);
static unsigned long long fix_qsize(unsigned long long r)
{
    int w = (int)(r & 0xffffffffu);
    int h = (int)(r >> 32);
    if (w <= 0)
        w = 1920;
    if (h <= 0)
        h = 1080;
    return ((unsigned long long)(unsigned)h << 32) | (unsigned)w;
}
unsigned long long _ZNK4KRdp15AbstractSession4sizeEv(void *self)
{
    static size_fn real;
    if (!real)
        real = (size_fn)dlsym(RTLD_NEXT, "_ZNK4KRdp15AbstractSession4sizeEv");
    return real ? fix_qsize(real(self)) : (1080ull << 32 | 1920ull);
}
unsigned long long _ZNK4KRdp15AbstractSession11logicalSizeEv(void *self)
{
    static size_fn real;
    if (!real)
        real = (size_fn)dlsym(RTLD_NEXT, "_ZNK4KRdp15AbstractSession11logicalSizeEv");
    return real ? fix_qsize(real(self)) : (1080ull << 32 | 1920ull);
}

static FILE *mouse_log(void)
{
    static FILE *f;
    static int tried;
    if (!tried) {
        tried = 1;
        f = fopen("/tmp/krdp-mouse.log", "a");
        if (f)
            setvbuf(f, NULL, _IOLBF, 0);
    }
    return f;
}

static void dlog(const char *fmt, unsigned short a, unsigned short b, unsigned short c)
{
    FILE *f = mouse_log();
    if (!f)
        return;
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    fprintf(f, "%ld.%03ld %s x=%u y=%u flags=0x%04x\n",
            (long)ts.tv_sec, ts.tv_nsec / 1000000L, fmt, a, b, c);
}

typedef unsigned char (*mouse_fn)(void *, unsigned short, unsigned short, unsigned short);

static unsigned char replay_mouse(void *self, unsigned short x, unsigned short y, unsigned short flags,
                                  mouse_fn real, const char *tag)
{
    static unsigned short last_x = 960, last_y = 540;
    unsigned short ox = x, oy = y, of = flags;

    if (x || y) {
        last_x = x;
        last_y = y;
    } else if (flags & (PTR_FLAGS_MOVE | PTR_FLAGS_BUTTON_MASK)) {
        x = last_x;
        y = last_y;
    }

    /* Inject a standalone MOVE, then deliver the original flags unchanged.
     * OR-ing MOVE into a button event makes KRdp take the MouseMove path
     * and drop the click (titlebar buttons do nothing). */
    if ((flags & PTR_FLAGS_BUTTON_MASK) && !(flags & PTR_FLAGS_MOVE)) {
        dlog(tag, ox, oy, of);
        dlog("  replay-move", x, y, PTR_FLAGS_MOVE);
        real(self, x, y, PTR_FLAGS_MOVE);
    } else if (flags & PTR_FLAGS_BUTTON_MASK) {
        dlog(tag, ox, oy, of);
    }

    return real(self, x, y, flags);
}

unsigned char _ZN4KRdp12InputHandler10mouseEventEttt(void *self, unsigned short x, unsigned short y,
                                                     unsigned short flags)
{
    static mouse_fn real;
    if (!real)
        real = (mouse_fn)dlsym(RTLD_NEXT, "_ZN4KRdp12InputHandler10mouseEventEttt");
    if (!real)
        return 1;
    return replay_mouse(self, x, y, flags, real, "mouse");
}

unsigned char _ZN4KRdp12InputHandler18extendedMouseEventEttt(void *self, unsigned short x, unsigned short y,
                                                             unsigned short flags)
{
    static mouse_fn real;
    if (!real)
        real = (mouse_fn)dlsym(RTLD_NEXT, "_ZN4KRdp12InputHandler18extendedMouseEventEttt");
    if (!real)
        return 1;
    return replay_mouse(self, x, y, flags, real, "xmouse");
}
