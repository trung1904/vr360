@echo off
setlocal
pushd "%~dp0"

set "PORT=5173"
set "URL=http://localhost:%PORT%/vr360.html"

echo ============================================
echo             RUN FULL VR360 LOCAL
echo ============================================
echo.

if not exist "vr360.html" (
  echo [ERROR] Thieu file: vr360.html
  goto :end_fail
)
if not exist "hanoionline.js" (
  echo [ERROR] Thieu file: hanoionline.js
  goto :end_fail
)
if not exist "hanoionline.xml" (
  echo [ERROR] Thieu file: hanoionline.xml
  goto :end_fail
)

where py >nul 2>nul
if %errorlevel%==0 (
  set "PY=py"
) else (
  where python >nul 2>nul
  if %errorlevel%==0 (
    set "PY=python"
  ) else (
    echo [ERROR] Khong tim thay Python hoac py launcher.
    goto :end_fail
  )
)

echo Dang mo: %URL%
start "" "%URL%"
echo Dang chay server tai port %PORT%...
echo Nhan Ctrl+C de dung server.
echo.

%PY% -m http.server %PORT%
goto :end_ok

:end_fail
echo.
echo Khong the chay "full" do thieu file hoac thieu moi truong.
pause
popd
endlocal
exit /b 1

:end_ok
popd
endlocal
exit /b 0

