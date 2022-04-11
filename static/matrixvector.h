#include <lua.h>
#include <luaconf.h>
#include <lauxlib.h>

typedef struct vect {
  lua_Unsigned size;
  lua_Number data[];
} vect;

typedef struct matrix {
  lua_Unsigned rows;
  lua_Unsigned cols;
  lua_Number data[];
} matrix;

size_t mv_vect_mem(vect*);
vect* mv_vect_add(vect*, vect*);
