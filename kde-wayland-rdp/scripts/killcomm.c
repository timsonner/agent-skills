/* Kill processes whose /proc/<pid>/comm matches argv[1] (default krdpserver).
 * Useful from the wslc session after execns, when pkill inside the container
 * cannot see the host-started compositor. */
#include <dirent.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
    const char *want = argc > 1 ? argv[1] : "krdpserver";
    size_t n = strlen(want);
    DIR *d = opendir("/proc");
    struct dirent *e;
    if (!d)
        return 1;
    while ((e = readdir(d))) {
        char path[80], name[64];
        FILE *f;
        if (e->d_name[0] < '0' || e->d_name[0] > '9')
            continue;
        snprintf(path, sizeof path, "/proc/%s/comm", e->d_name);
        f = fopen(path, "r");
        if (!f)
            continue;
        if (!fgets(name, sizeof name, f)) {
            fclose(f);
            continue;
        }
        fclose(f);
        if (strncmp(name, want, n) == 0 && (name[n] == '\n' || name[n] == '\0')) {
            int pid = atoi(e->d_name);
            printf("kill %s %d\n", want, pid);
            kill(pid, SIGKILL);
        }
    }
    closedir(d);
    return 0;
}
