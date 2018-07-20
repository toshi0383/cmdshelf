//
//  exec.c
//  Poxis
//
//  Created by Toshihiro Suzuki on 2018/07/17.
//

#include "exec.h"
int
poxis_exec(const char *cmdstring, char *const *args)
{
    errno = 0;
    pid_t pid;
    int ret, status;
    status = 0;
    ret = 0;
    if ((pid = fork()) < 0) {
        // error
        errno = EINVAL;
        return(-1);
    } else if (pid == 0) {
        // child
        execv(cmdstring, args);
        _exit(errno); // execl error
    }

    // parent

    while ((ret = waitpid(pid, &status, 0)) < 0)
        if (errno != EINTR)
            return(-1);    /* error other than EINTR from waitpid() */

    int exitStatus;
    exitStatus = -1;

    if (WIFEXITED(status))
        exitStatus = WEXITSTATUS(status);

    exit(exitStatus);
}
