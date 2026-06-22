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
    goto :push
)

for /f %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set TODAY=%%d
git commit -m "update reports %TODAY%"

:push
echo [Pushing...]
git push -u origin main 2>nul
if %errorlevel% == 0 goto :done

echo [Syncing with remote...]
if exist "README.md" rename "README.md" "README.md.bak"
git fetch origin main
git rebase origin/main
if exist "README.md.bak" rename "README.md.bak" "README.md"

git push -u origin main
if %errorlevel% == 0 goto :done

echo [FAILED] Please run: git push origin main --force
goto :end

:done
echo Done!
echo https://chenazhao.github.io/assets_dayily_report/reports/html/

:end
echo.
pause
