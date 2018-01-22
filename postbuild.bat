@echo off
set TARGET=release
if "%1"=="dev" set TARGET=debug

copy /Y components\servo\servo.exe.manifest target\%TARGET%\
copy /Y components\servo\servo.exe.manifest target\%TARGET%\

if _TARGET_==release editbin /nologo /subsystem:windows target\%TARGET%\servo.exe
copy /Y .servo\msvc-dependencies\openssl\1.1.0e-vs2015\bin64\libcryptoMD.dll target\%TARGET%\
copy /Y .servo\msvc-dependencies\openssl\1.1.0e-vs2015\bin64\libsslMD.dll target\%TARGET%\
