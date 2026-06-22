@echo off
setlocal

cd /d "%~dp0..\.."

if not exist ".git" (
    echo [Init git...]
    git init
    git remote add origin https://github.com/ChenaZhao/assets_dayily_report.git
    git branch -M main
)

git config user.email "zhaoxiben@gmail.com"
git config user.name "ChenaZhao"

git add reports\html\

git diff --cached --quiet
if %errorlevel% == 0 (
    echo [No new files, skip]
    goto :done
)

for /f %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set TODAY=%%d
git commit -m "update reports %TODAY%"

echo [Pushing to GitHub...]
git push -u origin main

if %errorlevel% neq 0 (
    echo [Push FAILED - may need GitHub login]
) else (
    echo Done!
    echo https://chenazhao.github.io/assets_dayily_report/reports/html/
)

:done
echo.
pause
