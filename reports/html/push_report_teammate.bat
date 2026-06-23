@echo off
setlocal

REM ===== First time: change REPO_DIR to where you cloned the repo =====
set REPO_DIR=%~dp0..\..\

cd /d "%REPO_DIR%"

git config user.email "your@email.com"
git config user.name "YourName"

echo [Pulling latest...]
git pull origin main --rebase

echo [Pushing your files...]
git add reports\html\
git diff --cached --quiet
if %errorlevel% == 0 (
    echo [No new files]
    goto :done
)

for /f %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set TODAY=%%d
git commit -m "update reports %TODAY%"
git push -u origin main

:done
echo.
echo Done! View at:
echo https://chenazhao.github.io/assets_dayily_report/reports/html/
echo.
pause
