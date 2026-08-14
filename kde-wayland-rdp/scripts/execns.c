#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char **argv)
{
    if (argc < 3) {
        fprintf(stderr, "usage: execns <host-pid> [-d] <cmd> [args...]\n");
        return 2;
    }
    int pid = atoi(argv[1]);
    if (pid <= 0) {
        fprintf(stderr, "bad pid\n");
        return 2;
    }
    char path[64];
    int fd_ipc = -1, fd_uts = -1, fd_net = -1, fd_mnt = -1, fd_pid = -1;
    snprintf(path, sizeof path, "/proc/%d/ns/ipc", pid);
    fd_ipc = open(path, O_RDONLY);
    snprintf(path, sizeof path, "/proc/%d/ns/uts", pid);
    fd_uts = open(path, O_RDONLY);
    snprintf(path, sizeof path, "/proc/%d/ns/net", pid);
    fd_net = open(path, O_RDONLY);
    snprintf(path, sizeof path, "/proc/%d/ns/pid", pid);
    fd_pid = open(path, O_RDONLY);
    snprintf(path, sizeof path, "/proc/%d/ns/mnt", pid);
    fd_mnt = open(path, O_RDONLY);
    if (fd_mnt < 0 || fd_net < 0) {
        perror("open ns");
        return 1;
    }
    if (fd_ipc >= 0 && setns(fd_ipc, CLONE_NEWIPC) < 0)
        perror("setns ipc");
    if (fd_uts >= 0 && setns(fd_uts, CLONE_NEWUTS) < 0)
        perror("setns uts");
    if (setns(fd_net, CLONE_NEWNET) < 0) {
        perror("setns net");
        return 1;
    }
    /* CLONE_NEWPID only applies to children — fork after this. */
    if (fd_pid >= 0 && setns(fd_pid, CLONE_NEWPID) < 0)
        perror("setns pid");
    if (setns(fd_mnt, CLONE_NEWNS) < 0) {
        perror("setns mnt");
        return 1;
    }
    if (fd_ipc >= 0)
        close(fd_ipc);
    if (fd_uts >= 0)
        close(fd_uts);
    if (fd_pid >= 0)
        close(fd_pid);
    close(fd_net);
    close(fd_mnt);

    int daemonize = (argv[2][0] == '-' && argv[2][1] == 'd');
    if (daemonize)
        argv += 1;

    pid_t child = fork();
    if (child < 0) {
        perror("fork");
        return 1;
    }
    if (child > 0) {
        if (daemonize) {
            printf("forked %d\n", (int)child);
            return 0;
        }
        int st = 0;
        waitpid(child, &st, 0);
        return WIFEXITED(st) ? WEXITSTATUS(st) : 1;
    }
    setsid();
    if (daemonize) {
        int n = open("/tmp/execns-child.log", O_WRONLY | O_CREAT | O_APPEND, 0644);
        if (n >= 0) {
            dup2(n, 1);
            dup2(n, 2);
            if (n > 2)
                close(n);
        }
    }
    execvp(argv[2], &argv[2]);
    fprintf(stderr, "execvp %s: %s\n", argv[2], strerror(errno));
    return 127;
}
