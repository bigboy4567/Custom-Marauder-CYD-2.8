@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "REPO_DIR=%~dp0"
if "%REPO_DIR:~-1%"=="\" set "REPO_DIR=%REPO_DIR:~0,-1%"

set "REMOTE_URL=https://github.com/bigboy4567/Custom-Marauder-CYD-2.8"
set "DEFAULT_BRANCH=main"

where git >nul 2>&1
if errorlevel 1 (
  echo [ERROR] git is not installed or not in PATH.
  goto :fail
)

pushd "%REPO_DIR%" >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Cannot enter repo directory: "%REPO_DIR%"
  goto :fail
)

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Not a git repository: "%REPO_DIR%"
  goto :fail
)

for /f "delims=" %%b in ('git branch --show-current') do set "BRANCH=%%b"
if "%BRANCH%"=="" (
  set "BRANCH=%DEFAULT_BRANCH%"
  echo [INFO] Detached HEAD detected, switching to %BRANCH%...
  git checkout -B "%BRANCH%"
  if errorlevel 1 goto :fail
)

echo Repo: %REPO_DIR%
echo Branch: %BRANCH%

REM Ensure origin points to the expected repo
for /f "delims=" %%u in ('git remote get-url origin 2^>nul') do set "CURRENT_ORIGIN=%%u"
if not defined CURRENT_ORIGIN (
  git remote add origin "%REMOTE_URL%"
  if errorlevel 1 goto :fail
) else (
  if /I not "%CURRENT_ORIGIN%"=="%REMOTE_URL%" (
    git remote set-url origin "%REMOTE_URL%"
    if errorlevel 1 goto :fail
  )
)

echo.
set /p "MSG=Commit message (leave empty for auto): "
if "%MSG%"=="" set "MSG=Update %DATE% %TIME%"

git add -A
if errorlevel 1 goto :fail

git diff --cached --quiet
if not errorlevel 1 (
  echo [INFO] No changes to commit.
  goto :done
)

git commit -m "%MSG%"
if errorlevel 1 goto :fail

echo [INFO] Syncing with origin/%BRANCH%...
git pull --rebase origin "%BRANCH%"
if errorlevel 1 goto :fail

echo [INFO] Pushing to origin/%BRANCH%...
git push -u origin "%BRANCH%"
if errorlevel 1 goto :fail

echo.
echo [OK] Commit and push completed.
goto :done

:fail
echo.
echo [FAILED] push_updates.bat encountered an error.
popd >nul 2>&1
pause
exit /b 1

:done
popd >nul 2>&1
pause
exit /b 0
