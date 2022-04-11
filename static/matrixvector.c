#include "matrixvector.h"
#include <stdlib.h>
#include <string.h>

size_t mv_vect_mem(vect* arg) {
  return sizeof(vect) + arg->size * sizeof(lua_Number);
}

static void checkVVArg(lua_State *L) {
  if (!(lua_type(L, 1) == LUA_TUSERDATA && lua_type(L, 2) == LUA_TUSERDATA)) {
    luaL_error(L, "function expecting two vector arguments was passed non-vector arguments");
  }
  luaL_getmetatable(L, "vect");
  lua_getmetatable(L, 1);
  lua_getmetatable(L, 2);
  if (!(lua_rawequal(L, -3, -1) && lua_rawequal(L, -3, -2))) {
    lua_pushliteral(L, "function expecting two vector arguments was passed non-vector arguments");
    lua_error(L);
  }
  lua_pop(L, 3);
}

static void checkVIArg(lua_State *L) {
  if (lua_type(L, 1) != LUA_TUSERDATA) {
    lua_pushliteral(L, "function expecting a vector was called with something else");
    lua_error(L);
  }
  luaL_getmetatable(L, "vect");
  lua_getmetatable(L, 1);
  if (!lua_rawequal(L, -2, -1) && lua_type(L, 2) == LUA_TNUMBER) {
    lua_pushliteral(L, "function expecting a vector and an integer was called with something else");
    lua_error(L);
  }
  lua_pop(L, 2);
}

static void checkVArg(lua_State *L) {
  if (lua_type(L, 1) != LUA_TUSERDATA) {
    lua_pushliteral(L, "function expecting a vector was called with something else");
    lua_error(L);
  }
  luaL_getmetatable(L, "vect");
  lua_getmetatable(L, 1);
  if (!lua_rawequal(L, -2, -1)) {
    lua_pushliteral(L, "function expecting a vector was called with something else");
    lua_error(L);
  }
}

vect* mv_vect_add(vect* a, vect* b) {
  if (a == NULL || b == NULL) {
    return NULL;
  }
  if (a->size != b-> size) {
    return NULL;
  }
  vect* result = (vect*)malloc(sizeof(vect) + a->size * sizeof(lua_Number));
  result->size = a->size;
  for (lua_Unsigned i = 0; i < a->size; ++i) {
    result->data[i] = a->data[i]*b->data[i];
  }
  return result;
}

int lua_mv_vect_add(lua_State *L) {
  checkVVArg(L);
  vect* arg0 = (vect*)lua_touserdata(L, 1);
  vect* arg1 = (vect*)lua_touserdata(L, 2);
  vect* res = mv_vect_add(arg0, arg1);
  if (res == NULL) {
    luaL_error(L, "unable to add the provided vectors");
  }
  size_t mem = mv_vect_mem(res);
  void* dest = lua_newuserdata(L, mem);
  memcpy(dest, res, mem);
  free(res);
  luaL_getmetatable(L, "vect");
  lua_setmetatable(L, -2);
  return 1;
}

int lua_mv_vect_index(lua_State *L) {
  checkVIArg(L);
  vect* v = (vect*)lua_touserdata(L, 1);
  lua_Unsigned index = lua_tointeger(L, 2);
  if (index > v->size) {
    lua_pushliteral(L, "invalid index into vector");
    lua_error(L);
  }
  lua_pushnumber(L, v->data[index-1]);
  return 1;
}

int lua_mv_vect_tostring(lua_State *L) {
  checkVArg(L);
  vect* v = (vect*)lua_touserdata(L, 1);
  luaL_Buffer b;
  luaL_buffinit(L, &b);
  luaL_addstring(&b, "vector(");
  if (v->size > 1) {
    for (unsigned int i = 0; i < v->size-1; ++i) {
      char* dest = luaL_prepbuffsize(&b, 16);
      int len = sprintf(dest, "%f, ", v->data[i]);
      luaL_addsize(&b, len);
    }
    char* dest = luaL_prepbuffsize(&b, 16);
    int len = sprintf(dest, "%f", v->data[v->size-1]);
    luaL_addsize(&b, len);
  }
  luaL_addchar(&b, ')');
  luaL_pushresult(&b);
  return 1;
}

int lua_mv_vect_create(lua_State *L) {
  int n = lua_gettop(L);
  vect* v = (vect*)lua_newuserdata(L, sizeof(vect) + n*sizeof(lua_Number));
  v->size = n;
  for (int i = 0; i < n; ++i) {
    if (lua_type(L, i+1) != LUA_TNUMBER) {
      lua_pushliteral(L, "attempted to construct a vector with something that isn't a number");
      lua_error(L);
    }
    v->data[i] = lua_tonumber(L, i+1);
  }
  luaL_getmetatable(L, "vect");
  lua_setmetatable(L, -2);
  return 1;
}

int luaopen_matrixvector(lua_State *L) {
  luaL_newmetatable(L, "vect");
  lua_pushcfunction(L, lua_mv_vect_add);
  lua_setfield(L, -2, "__add");
  lua_pushcfunction(L, lua_mv_vect_index);
  lua_setfield(L, -2, "__index");
  lua_pushcfunction(L, lua_mv_vect_tostring);
  lua_setfield(L, -2, "__tostring");
  lua_pop(L, -1);
  lua_pushcfunction(L, lua_mv_vect_create);
  return 1;
}
