@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ==========================================
echo    MAKELAN KULMA - PAIVITYS
echo ==========================================
echo Kansio: %CD%
echo.

if not exist "index.html" (
    echo VIRHE: index.html puuttuu. Aja tama tiedosto makelankulma-kansiossa.
    echo.
    pause
    exit /b
)

REM ---------- 2. Varmista git ----------
where git >nul 2>nul
if errorlevel 1 (
    echo VIRHE: Gitia ei loydy koneelta.
    echo Asenna Git osoitteesta https://git-scm.com/download/win
    echo.
    pause
    exit /b
)

if not exist ".git" (
    echo Alustetaan git-repo...
    git init >nul
    git branch -M main
    git remote add origin https://github.com/mattsmatias/makelankulma.git
)

git remote get-url origin >nul 2>nul
if errorlevel 1 git remote add origin https://github.com/mattsmatias/makelankulma.git

REM ---------- 3. Commit ja push ----------
git add -A
git diff --cached --quiet
if not errorlevel 1 (
    echo Ei muutoksia - kaikki on jo ajan tasalla.
    echo.
    pause
    exit /b
)

for /f "tokens=1-3 delims=." %%a in ("%date%") do set "PVM=%%a.%%b.%%c"
set "KLO=%time:~0,5%"
git commit -m "Paivitys %PVM% %KLO%" >nul
echo Commit tehty: Paivitys %PVM% %KLO%

echo Lahetetaan GitHubiin...
git push -u origin main
if errorlevel 1 (
    echo.
    echo Push ei onnistunut. Haetaan etamuutokset ja yritetaan uudelleen...
    git pull --rebase origin main
    git push -u origin main
)

echo.
echo ==========================================
echo  VALMIS. Sivusto paivittyy noin minuutissa.
echo  Paina selaimessa Ctrl+F5 jos vanha nakyy.
echo ==========================================
echo.
pause
