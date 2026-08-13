/* Survive GRD FUSE clipboard without /dev/fuse (container seccomp).
 *
 * 1) Stub fuse_session_mount/loop so the FUSE thread can signal sync_point
 *    and the RDP peer setup continues (otherwise g_error infinite-loops the
 *    thread and black-screens the session).
 * 2) Demote residual FUSE g_log ERRORs to WARNING as a safety net.
 *
 * Build: gcc -shared -fPIC -o /usr/local/lib/libnofuseabort.so nofuseabort.c -ldl
 * Use:   LD_PRELOAD=/usr/local/lib/libnofuseabort.so gnome-remote-desktop-daemon --headless
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

enum {
  G_LOG_FLAG_FATAL    = 1 << 1,
  G_LOG_LEVEL_ERROR   = 1 << 2,
  G_LOG_LEVEL_WARNING = 1 << 4
};

typedef void (*g_logv_fn)(const char *domain, int level, const char *format, va_list args);
static g_logv_fn real_g_logv;

static int is_fuse_msg(const char *format, va_list args) {
  char buf[1024];
  va_list ap;
  if (!format) return 0;
  if (strstr(format, "FUSE") || strstr(format, "fuse") || strstr(format, "Clipboard"))
    return 1;
  va_copy(ap, args);
  vsnprintf(buf, sizeof(buf), format, ap);
  va_end(ap);
  return (strstr(buf, "FUSE") || strstr(buf, "fuse") || strstr(buf, "Clipboard")) ? 1 : 0;
}

void g_logv(const char *domain, int level, const char *format, va_list args) {
  if (!real_g_logv)
    real_g_logv = (g_logv_fn)dlsym(RTLD_NEXT, "g_logv");
  if ((level & G_LOG_LEVEL_ERROR) && is_fuse_msg(format, args)) {
    fprintf(stderr, "nofuseabort: demote g_log ERROR for FUSE/clipboard\n");
    level = (level & ~(G_LOG_LEVEL_ERROR | G_LOG_FLAG_FATAL)) | G_LOG_LEVEL_WARNING;
  }
  if (real_g_logv)
    real_g_logv(domain, level, format, args);
}

void g_log(const char *domain, int level, const char *format, ...) {
  va_list ap;
  va_start(ap, format);
  g_logv(domain, level, format, ap);
  va_end(ap);
}

struct fuse_session;

int fuse_session_mount(struct fuse_session *se, const char *mountpoint) {
  fprintf(stderr,
          "nofuseabort: fuse_session_mount(\"%s\") -> stub success (no /dev/fuse)\n",
          mountpoint ? mountpoint : "(null)");
  return 0;
}

int fuse_session_loop(struct fuse_session *se) {
  fprintf(stderr, "nofuseabort: fuse_session_loop stub - parking fuse thread\n");
  for (;;)
    sleep(3600);
  return 0;
}

void fuse_session_unmount(struct fuse_session *se) {
  fprintf(stderr, "nofuseabort: fuse_session_unmount stub\n");
}
