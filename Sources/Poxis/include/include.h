//
//  popen.h
//  cmdshelf
//
//  Created by Toshihiro Suzuki on 2018/01/01.
//

#ifndef popen_h
#define popen_h

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <limits.h>
#include <fcntl.h>
#include <sys/wait.h>

FILE *poxis_popen(const char *cmdstring, const char *type);
int poxis_pclose(FILE *fp);
long open_max(void);

#endif /* popen_h */
