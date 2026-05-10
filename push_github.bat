@echo off
setlocal EnableExtensions

REM Usage:
REM   push_github.bat
REM   push_github.bat https://github.com/<user>/<repo>.git
REM   push_github.bat https://github.com/<user>/<repo>.git main

pushd "%~dp0"

set "REPO_URL=%~1"
if "%REPO_URL%"=="" set "REPO_URL=https://github.com/trung1904/vr360.git"

set "BRANCH=%~2"
if "%BRANCH%"=="" set "BRANCH=main"

set "LOGFILE=%~dp0push_github.log"
echo =======================>"%LOGFILE%"
echo START %date% %time%>>"%LOGFILE%"
echo =======================>>"%LOGFILE%"

echo (Log: %LOGFILE%)
echo.
echo ============================================
echo   PUSH VR360 TO GITHUB
echo   Repo:   %REPO_URL%
echo   Branch: %BRANCH%
echo ============================================
echo.

where git >nul 2>nul
if errorlevel 1 goto :no_git

REM Big file check (GitHub ~100MB/file)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location '%CD%'; $big = Get-ChildItem -Recurse -Force -File | Where-Object { $_.Length -ge 95MB } | Sort-Object Length -Descending; if ($big) { $big | Select-Object -First 20 FullName, @{n='MB';e={[math]::Round($_.Length/1MB,2)}} | Format-Table -AutoSize | Out-String | Write-Host; exit 2 } else { exit 0 }" >>"%LOGFILE%" 2>&1
if errorlevel 1 goto :big_files

if not exist ".git\" (
  echo [INFO] git init
  git init>>"%LOGFILE%" 2>&1
  if errorlevel 1 goto :fail
)

echo [INFO] checkout %BRANCH%
git checkout -B "%BRANCH%">>"%LOGFILE%" 2>&1
if errorlevel 1 goto :fail

git remote get-url origin >nul 2>nul
if errorlevel 1 (
  echo [INFO] add remote origin = %REPO_URL%
  git remote add origin "%REPO_URL%">>"%LOGFILE%" 2>&1
  if errorlevel 1 goto :fail
) else (
  for /f "usebackq delims=" %%R in (`git remote get-url origin`) do set "CUR_REMOTE=%%R"
  if /i not "%CUR_REMOTE%"=="%REPO_URL%" (
    echo [INFO] update origin -> %REPO_URL%
    git remote set-url origin "%REPO_URL%">>"%LOGFILE%" 2>&1
    if errorlevel 1 goto :fail
  )
)

echo [INFO] git add -A
git add -A>>"%LOGFILE%" 2>&1
if errorlevel 1 goto :fail

git diff --cached --quiet
if errorlevel 1 (
  echo [INFO] git commit
  git commit -m "Deploy VR360">>"%LOGFILE%" 2>&1
  if errorlevel 1 goto :fail
) else (
  echo [INFO] Khong co thay doi moi de commit.
)

echo.
echo [INFO] git push -u origin %BRANCH%
git push -u origin "%BRANCH%">>"%LOGFILE%" 2>&1
if errorlevel 1 goto :push_fail

echo.
echo [OK] Da push len GitHub.
goto :ok

:no_git
echo [ERROR] Chua co Git. Hay cai Git for Windows: https://git-scm.com/download/win
echo [ERROR] git not found>>"%LOGFILE%"
goto :fail

:big_files
echo.
echo [ERROR] Co file qua lon (>=95MB). GitHub se tu choi push (gioi han ~100MB/file).
echo Goi y: dung Git LFS hoac giam/kieu host khac cho panos.
echo [ERROR] big files detected>>"%LOGFILE%"
goto :fail

:push_fail
echo.
echo [ERROR] Push that bai. Xem log: %LOGFILE%
echo - Neu GitHub hoi password: hay dung Personal Access Token (PAT) thay cho password.
echo - Hoac dang nhap bang GitHub Desktop.
goto :fail

:fail
echo.
echo [FAIL] Khong hoan tat. Xem log: %LOGFILE%
echo.
pause
popd
endlocal
exit /b 1

:ok
echo Xem log: %LOGFILE%
echo.
pause
popd
endlocal
exit /b 0

