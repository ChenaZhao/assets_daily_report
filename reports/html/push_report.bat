@echo off
setlocal

cd /d "%~dp0..\.."

git config user.email "zhaoxiben@gmail.com"
git config user.name "ChenaZhao"

if not exist ".git" (
    git init
    git remote add origin https://github.com/ChenaZhao/assets_dayily_report.git
    git branch -M main
)

git add reports\html\

git diff --cached --quiet
if %errorlevel% == 0 (
    echo [No new files to commit]
) else (
    for /f %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set TODAY=%%d
    git commit -m "update reports %TODAY%"
)

echo [Pushing...]
git push -u origin main
if %errorlevel% == 0 (
    echo.
    echo Done!
    echo https://chenazhao.github.io/assets_dayily_report/reports/html/
) else (
    echo.
    echo [Sync then push...]
    if exist "README.md" rename "README.md" "README.md.bak"
    git fetch origin main
    git rebase origin/main
    if exist "README.md.bak" rename "README.md.bak" "README.md"
    git push -u origin main
    if %errorlevel% == 0 (
        echo Done!
        echo https://chenazhao.github.io/assets_dayily_report/reports/html/
    ) else (
        echo [FAILED] run: git push origin main --force
    )
)

echo.
pause
