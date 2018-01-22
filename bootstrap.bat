@echo off

pushd .

IF EXIST "%ProgramFiles(x86)%" (
  set "ProgramFiles32=%ProgramFiles(x86)%"
) ELSE (
  set "ProgramFiles32=%ProgramFiles%"
)

set VC14VARS=%VS140COMNTOOLS%..\..\VC\vcvarsall.bat
IF EXIST "%VC14VARS%" (
  set "VS_VCVARS=%VC14VARS%"
) ELSE (
  for %%e in (Enterprise Professional Community BuildTools) do (
    IF EXIST "%ProgramFiles32%\Microsoft Visual Studio\2017\%%e\VC\Auxiliary\Build\vcvarsall.bat" (
      set "VS_VCVARS=%ProgramFiles32%\Microsoft Visual Studio\2017\%%e\VC\Auxiliary\Build\vcvarsall.bat"
    )
  )
)

IF EXIST "%VS_VCVARS%" (
  IF NOT DEFINED Platform (
    IF EXIST "%ProgramFiles(x86)%" (
      call "%VS_VCVARS%" x64
    ) ELSE (
      ECHO 32-bit Windows is currently unsupported.
      EXIT /B
    )
  )
) ELSE (
  ECHO Visual Studio 2015 or 2017 is not installed.
  ECHO Download and install Visual Studio 2015 or 2017 from https://www.visualstudio.com/
  EXIT /B
)

popd

powershell .\bootstrap.ps1

set drive=%~dp0
set drivep=%drive%
if #%drive:~-1%# == #\# set drivep=%drive:~0,-1%

"%drivep%\.servo\rustup-init.exe" -y --default-host x86_64-pc-windows-msvc --default-toolchain none
set PATH=%PATH%;%HOMEPATH%\.cargo\bin

rem OpenSSL configuration
rem this may be set globally by other apps, reset it
set OPENSSL_CONF=
set OPENSSL_LIBS=libsslMD:libcryptoMD
set OPENSSL_LIB_DIR=%drivep%\.servo\msvc-dependencies\openssl\1.1.0e-vs2015\lib64
set OPENSSL_INCLUDE_DIR=%drivep%\.servo\msvc-dependencies\openssl\1.1.0e-vs2015\include

rem Moztools and path to python for it
set MOZTOOLS_PATH=%drivep%\.servo\msvc-dependencies\moztools\0.0.1-5\bin
rem it assumes c:\python27 if this envar isn't set, and that might not be true
for /f "tokens=*" %%i in ('where python.exe') do set NATIVE_WIN32_PYTHON=%%i
set PATH=%PATH%;%NATIVE_WIN32_PYTHON:~0,-11%\Scripts

rem ninja for components/script
set PATH=%PATH%;%drivep%\.servo\msvc-dependencies\ninja\1.7.1\bin

rem cmake for components/script
set PATH=%PATH%;%drivep%\.servo\msvc-dependencies\cmake\3.7.2\bin

rem rust configuration
set RUSTFLAGS= -W unused-extern-crates
