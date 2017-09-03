set PROTO_DIR=../src/script/mobile/NetWork/
set JAVA_OUT_DIR=../frameworks/runtime-src/proj.android/src/
set LUA_OUT_DIR=../src/script/mobile/NetWork/
for %%i in (%PROTO_DIR%*.proto) do (  
echo %%i
rem #convert to java
protoc.exe -I=%PROTO_DIR% --java_out=%JAVA_OUT_DIR% %PROTO_DIR%%%i
rem #convert to lua
protoc.exe -I=%PROTO_DIR% --plugin=protoc-gen-lua="protoc-gen-lua.bat" --lua_out=%LUA_OUT_DIR% %PROTO_DIR%%%i
)