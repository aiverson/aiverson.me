  return {
    name = "aiverson/codeclicker",
    version = "0.0.1",
    description = "A prototype of the game mechanics for Project Kardashev",
    tags = { },
    license = "MIT",
    author = { name = "aiverson", email = "alexjiverson@gmail.com" },
    homepage = "",
    public = false,
    dependencies = {
      "creationix/weblit@3.1.2",
      "luvit/luvit@2.5.2",
      "creationix/coro-fs@2.2.3",
      "creationix/coro-split@2.0.0"
    },
    files = {
      "**.lua",
      "**.js",
      "**.html",
      "**.css",
      "static/**",
      "!test*"
    }
  }
  
