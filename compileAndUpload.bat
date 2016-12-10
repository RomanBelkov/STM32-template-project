@echo off

set CYGWIN_DIR=C:\cygwin64\bin
set OPENOCD_DIR=C:\Users\RB\Downloads\openocd-0.9.0
set OPENOCD_BIN_DIR=%OPENOCD_DIR%\bin
set OPENOCD

set PATH=%PATH%;%CYGWIN_DIR%;%OPENOCD_BIN_DIR%
rem set LIBRARIES="%~dp0"

rem small hack to receive ouyput of cygpath
for /f %%i in ('cygpath -m "%~dp0"') do set LIBRARIES=%%i
rem echo %LIBRARIES%

set MAKEFILE="%LIBRARIES%"/Makefile

rem the folder that contains this bat & makefile
echo Launch dir: "%~dp0"

rem the folder with the generated cpp
echo Current dir: "%CD%"

cd "%CD%"

rem set MAKE=make -f "%MAKEFILE%"
set MAKE_ARGS="LIBRARIES=%LIBRARIES%"
set GOAL=clean

make -f %MAKEFILE% %MAKE_ARGS% %GOAL%

REM Exit