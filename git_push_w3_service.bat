@echo off
setlocal

REM ==================================================
REM 自動偵測 Git Repository 目錄
REM ==================================================
set "REPO_DIR="

if exist "C:\Users\archer\Documents\GitHub\w3_service\.git\" (
    set "REPO_DIR=C:\Users\archer\Documents\GitHub\w3_service"
) else if exist "C:\Users\arche\Documents\GitHub\w3_service\.git\" (
    set "REPO_DIR=C:\Users\arche\Documents\GitHub\w3_service"
)

REM ==================================================
REM 找不到 Repository 時停止
REM ==================================================
if not defined REPO_DIR (
    echo.
    echo [ERROR] 找不到 w3_service Git Repository。
    echo.
    echo 已檢查：
    echo C:\Users\archer\Documents\GitHub\w3_service
    echo C:\Users\arche\Documents\GitHub\w3_service
    echo.
    pause
    exit /b 1
)

REM ==================================================
REM 切換到 Repository 目錄
REM /d 可同時切換磁碟機及目錄
REM ==================================================
cd /d "%REPO_DIR%"

if errorlevel 1 (
    echo.
    echo [ERROR] 無法切換到目錄：
    echo %REPO_DIR%
    pause
    exit /b 1
)

REM ==================================================
REM 使用日期與時間產生 Commit 訊息
REM 範例：2026-08-03 13-25-30
REM ==================================================
for /f "delims=" %%i in ('powershell.exe -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH-mm-ss'"') do (
    set "COMMIT_MESSAGE=%%i"
)

echo.
echo ==================================================
echo Repository：%REPO_DIR%
echo Commit：%COMMIT_MESSAGE%
echo ==================================================
echo.

REM ==================================================
REM 加入所有新增、修改及刪除的檔案
REM ==================================================
git add -A

if errorlevel 1 (
    echo.
    echo [ERROR] git add 執行失敗。
    pause
    exit /b 1
)

REM ==================================================
REM 檢查是否有內容可以 Commit
REM ==================================================
git diff --cached --quiet

if not errorlevel 1 (
    echo.
    echo [INFO] 沒有任何變更需要 Commit。
    echo [INFO] 將嘗試同步遠端 Repository。
    echo.

    git pull --rebase

    if errorlevel 1 (
        echo.
        echo [ERROR] git pull --rebase 執行失敗。
        pause
        exit /b 1
    )

    git push

    if errorlevel 1 (
        echo.
        echo [ERROR] git push 執行失敗。
        pause
        exit /b 1
    )

    echo.
    echo [SUCCESS] Repository 已完成同步。
    pause
    exit /b 0
)

REM ==================================================
REM Commit
REM ==================================================
git commit -m "%COMMIT_MESSAGE%"

if errorlevel 1 (
    echo.
    echo [ERROR] git commit 執行失敗。
    pause
    exit /b 1
)

REM ==================================================
REM Push 前先同步遠端內容
REM ==================================================
git pull --rebase

if errorlevel 1 (
    echo.
    echo [ERROR] git pull --rebase 執行失敗。
    echo 可能發生檔案衝突，請手動處理後再執行。
    pause
    exit /b 1
)

REM ==================================================
REM Push 到遠端 Repository
REM ==================================================
git push

if errorlevel 1 (
    echo.
    echo [ERROR] git push 執行失敗。
    pause
    exit /b 1
)

echo.
echo ==================================================
echo [SUCCESS] Commit 與 Push 已完成
echo Repository：%REPO_DIR%
echo Commit：%COMMIT_MESSAGE%
echo ==================================================
echo.

pause
endlocal