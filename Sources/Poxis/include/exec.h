//
//  exec.h
//  Poxis
//
//  Created by Toshihiro Suzuki on 2018/07/17.
//

#ifndef exec_h
#define exec_h

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <limits.h>
#include <fcntl.h>
#include <sys/wait.h>

/// executes given command.
/// stdout, stderr, stdin
int poxis_exec(const char *cmdstring, char *const *args);

#endif /* exec_h */
