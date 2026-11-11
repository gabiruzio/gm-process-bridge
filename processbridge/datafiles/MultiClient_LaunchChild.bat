@echo off
setlocal DisableDelayedExpansion

rem Usage: MultiClient_LaunchChild.bat <uuid>
rem Starts exactly one additional game process.

set "CHILD_UUID=%~1"
set "MC_LOG=%~dp0MultiClient_LaunchChild.log"
> "%MC_LOG%" echo [%date% %time%] MultiClient child launcher started.

if not defined CHILD_UUID (
    call :log "ERROR: Missing child UUID."
    exit /b 2
)

set "MC_CONTEXT=%~dp0MultiClient_LaunchChild.context.bat"
if not exist "%MC_CONTEXT%" (
    call :log "ERROR: Context file not found: %MC_CONTEXT%"
    exit /b 3
)

call "%MC_CONTEXT%"

if not defined MC_OUTPUT (
    call :log "ERROR: MC_OUTPUT is missing from context."
    exit /b 4
)
if not defined MC_PROJECT (
    call :log "ERROR: MC_PROJECT is missing from context."
    exit /b 4
)
if not defined MC_RUNTIME (
    call :log "ERROR: MC_RUNTIME is missing from context."
    exit /b 4
)

call :log "Output: %MC_OUTPUT%"
call :log "Project: %MC_PROJECT%"
call :log "Runtime kind: %MC_RUNTIME_KIND%"
call :log "Runtime: %MC_RUNTIME%"
call :log "Child UUID: %CHILD_UUID%"

pushd "%MC_OUTPUT%" >nul 2>&1
if errorlevel 1 (
    call :log "ERROR: Cannot enter output folder: %MC_OUTPUT%"
    exit /b 5
)

if /i "%MC_RUNTIME_KIND%"=="YYC" goto :launch_yyc
goto :launch_vm

:launch_yyc
set "CHILD_EXE=%MC_OUTPUT%\%MC_YYCEXE%"
if not exist "%CHILD_EXE%" (
    call :log "ERROR: YYC executable not found: %CHILD_EXE%"
    popd
    exit /b 6
)

call :log "Launching YYC: %CHILD_EXE%"
start "" /b "%CHILD_EXE%" "ipc-shm-child-key-%CHILD_UUID%" "ipc-shm-child"
set "LAUNCH_RESULT=%ERRORLEVEL%"
goto :finish

:launch_vm
set "CHILD_RUNNER=%MC_RUNTIME%\Windows\x64\Runner.exe"
set "CHILD_GAME=%MC_OUTPUT%\%MC_PROJECT%.win"

if not exist "%CHILD_RUNNER%" (
    call :log "ERROR: VM runner not found: %CHILD_RUNNER%"
    popd
    exit /b 7
)
if not exist "%CHILD_GAME%" (
    call :log "ERROR: VM game file not found: %CHILD_GAME%"
    popd
    exit /b 8
)

call :log "Launching VM: %CHILD_RUNNER% -game %CHILD_GAME%"
start "" /b "%CHILD_RUNNER%" -game "%CHILD_GAME%" "ipc-shm-child-key-%CHILD_UUID%" "ipc-shm-child"
set "LAUNCH_RESULT=%ERRORLEVEL%"

:finish
call :log "START result: %LAUNCH_RESULT%"
popd
exit /b %LAUNCH_RESULT%

:log
>> "%MC_LOG%" echo [%date% %time%] %~1
exit /b 0
