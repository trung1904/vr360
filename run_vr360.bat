@echo off
setlocal
pushd "%~dp0"

set "PORT=5173"
set "URL=http://localhost:%PORT%/vr360.html"

where py >nul 2>nul
if %errorlevel%==0 (
  set "PY=py"
) else (
  where python >nul 2>nul
  if %errorlevel%==0 (
    set "PY=python"
  ) else (
    echo [ERROR] Khong tim thay Python.
    echo Hay cai Python hoac py launcher roi chay lai.
    popd
    exit /b 1
  )
)

start "" "%URL%"
echo Dang mo: %URL%
echo Nhan Ctrl+C de dung server.
echo.

%PY% -m http.server %PORT%

popd
endlocal
