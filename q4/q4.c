#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

#define op_len 6
typedef int (*fptr)(int, int);

int main() {
    char op[op_len];

    int x1, x2;
    while (scanf("%5s %d %d", op, &x1, &x2) == 3) {
        
        char libname[20];
        snprintf(libname, sizeof(libname), "./lib%s.so", op);
        /*
        strcpy(libname, "./lib");
        strcat(libname, op);
        strcat(libname, ".so");
        */

        void *handle = dlopen(libname, RTLD_LAZY);
        if (!handle) {
            printf("Could not load library %s\n", libname);
            continue;
        }

        fptr func = (fptr)dlsym(handle, op);
        if (!func) {
            printf("Function %s not found in %s\n", op, libname);
            dlclose(handle);
            continue;
        }

        printf("%d\n", func(x1,x2));
        dlclose(handle);
    }

    return 0;
}