@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "REPO_DIR=%SCRIPT_DIR:~0,-1%"
if not exist "%REPO_DIR%." (
  echo Repo directory not found: "%REPO_DIR%"
  goto :fail
)
pushd "%REPO_DIR%" >nul 2>&1
if errorlevel 1 (
  echo Failed to enter repo directory: "%REPO_DIR%"
  goto :fail
)

set "GIT_CEILING_DIRECTORIES=%REPO_DIR%"
set "GIT_DIR=%REPO_DIR%\.git"
set "GIT_WORK_TREE=%REPO_DIR%"

set "REMOTE_URL=https://github.com/bigboy4567/Custom-Marauder-CYD-2.8"
set "DEFAULT_BRANCH=main"

if not exist ".git" (
  git init -b "%DEFAULT_BRANCH%"
  if errorlevel 1 goto :fail
)

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo Not a git repository.
  goto :fail
)
cd /d "%REPO_DIR%"
echo Repo: %REPO_DIR%

git remote get-url origin >nul 2>&1
if errorlevel 1 (
  if not "%REMOTE_URL%"=="" (
    git remote add origin "%REMOTE_URL%"
  ) else (
    echo Remote "origin" missing.
    goto :fail
  )
) else (
  if not "%REMOTE_URL%"=="" (
    git remote set-url origin "%REMOTE_URL%"
  )
)

set "PUSH_REFSPEC="
for /f %%b in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "BRANCH=%%b"
if /I "%BRANCH%"=="HEAD" (
  set "BRANCH=%DEFAULT_BRANCH%"
  set "PUSH_REFSPEC=HEAD:%DEFAULT_BRANCH%"
) else (
  if /I not "%BRANCH%"=="%DEFAULT_BRANCH%" (
    echo Current branch is "%BRANCH%". Please switch to "%DEFAULT_BRANCH%" manually.
    goto :fail
  )
  set "PUSH_REFSPEC=%BRANCH%"
)

echo.
set /p msg=Commit message:
if "%msg%"=="" (
  echo Commit message required.
  goto :fail
)

git add -A

REM Check if there are staged changes
git diff --cached --quiet
if errorlevel 1 goto :has_staged_changes

REM No staged changes - check if there are any changes at all
git status --porcelain > "%TEMP%\git_status.txt"
set "HAS_ANY_CHANGES=0"
for /f "delims=" %%l in (%TEMP%\git_status.txt) do set "HAS_ANY_CHANGES=1"
del "%TEMP%\git_status.txt"

if "!HAS_ANY_CHANGES!"=="0" (
echo No changes to commit in %REPO_DIR%.
  echo If you edited files in another folder ^(ex: Downloads^), they won't be committed.
  goto :done
)

REM Has changes but nothing staged
echo Changes detected but none staged. Check .gitignore or file permissions.
git status -sb
goto :done

:has_staged_changes
git status -sb
git commit -m "%msg%"
if errorlevel 1 goto :fail

git fetch origin
if errorlevel 1 goto :fail

git push -u --force-with-lease origin "%PUSH_REFSPEC%"
if errorlevel 1 goto :fail

set "APP_VERSION="
for /f "tokens=1,2 delims==" %%a in ('findstr /R /C:"^[ ]*APP_VERSION[ ]*=" "%REPO_DIR%\\src\\ledfx_icue_core.py"') do set "APP_VERSION=%%b"
if defined APP_VERSION (
  for /f "tokens=1 delims=#" %%v in ("!APP_VERSION!") do set "APP_VERSION=%%v"
  for /f "tokens=* delims= " %%v in ("!APP_VERSION!") do set "APP_VERSION=%%v"
  set "APP_VERSION=!APP_VERSION: =!"
  set "APP_VERSION=!APP_VERSION:\"=!"
  set "APP_VERSION=!APP_VERSION:'=!"
)
if "%APP_VERSION%"=="" (
  echo APP_VERSION introuvable dans ledfx_icue_core.py.
  goto :fail
)
set "RELEASE_TAG=v!APP_VERSION!"

git rev-parse -q --verify "refs/tags/%RELEASE_TAG%" >nul 2>&1
if not errorlevel 1 (
  echo Tag deja existant: %RELEASE_TAG%
  goto :fail
)

git tag -a "%RELEASE_TAG%" -m "%msg%"
if errorlevel 1 goto :fail

git push origin "%RELEASE_TAG%"
if errorlevel 1 goto :fail

where gh >nul 2>&1
if errorlevel 1 (
  echo GitHub CLI ^(gh^) not found. Release not created.
  goto :done
)

set "EXE_PATH=%REPO_DIR%\\ledfx_icue_bridge.exe"
if not exist "%EXE_PATH%" (
  set "EXE_PATH=%REPO_DIR%\\dist\\ledfx_icue_bridge.exe"
)

echo.
echo Creating GitHub release %RELEASE_TAG%...
gh release create "%RELEASE_TAG%" -t "%RELEASE_TAG%" -n "%msg%"
if errorlevel 1 (
  echo Warning: Failed to create GitHub release, but commit and tag were pushed successfully.
  goto :done
)

if exist "%EXE_PATH%" (
  echo Uploading asset: %EXE_PATH%
  gh release upload "%RELEASE_TAG%" "%EXE_PATH%" --clobber
  if errorlevel 1 (
    echo Warning: Failed to upload EXE to the release.
  )
) else (
  echo EXE introuvable. Aucun asset n'a ete ajoute.
)

echo.
echo ========================================
echo SUCCESS!
echo ========================================
echo Commit: %msg%
echo Tag: %RELEASE_TAG%
echo Release: https://github.com/bigboy4567/Custom-Marauder-CYD-2.8/releases/tag/%RELEASE_TAG%
echo ========================================
echo.

goto :done

:done
pause
exit /b 0

:fail
pause
exit /b 1
