@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 正在合并所有目录内容...
echo.
cd /d "%~dp0"
echo 当前目录：%cd%
:: 设置当前目录为主目录
set "main_dir=."
echo 当前目录：%cd%

:: 获取父目录中所有以博客笔记_HTML开头但不是当前目录的目录
set count=0
for /d %%d in ("..\博客笔记_HTML*") do (
    set "dirname=%%~nd"
    
    :: 检查是否是当前目录（通过比较完整路径）
    pushd "%%d"
    set "current_path=!cd!"
    popd
    
    pushd "."
    set "main_path=!cd!"
    popd
    
    if not "!current_path!"=="!main_path!" (
        echo 正在处理目录：%%d
        set /a count+=1
        
        :: 移动所有内容到当前目录
        echo   移动所有文件和文件夹...
        xcopy "%%d\*" ".\\" /E /I /Y >nul
        
        :: 删除源目录
        rd /s /q "%%d" 2>nul
        echo   目录处理完成
        echo.
    )
)

echo.
if %count% gtr 0 (
    echo 完成！已合并 %count% 个子目录到当前目录。
) else (
    echo 未找到需要合并的目录。
    echo 注意：只处理父目录中类似 "博客笔记_HTML002"、"博客笔记_HTML003" 格式的目录。
)

echo.
echo 执行Python脚本处理图片...
cd /d "%~dp0"
echo 当前目录：%cd%
python replace_images.py
if errorlevel 1 (
    echo Python脚本执行失败！
    pause
    exit /b 1
)

echo.
echo 配置Git...
git config --global core.quotepath true

echo.
echo Git状态：
git status

echo.
set /p commit_msg="请输入提交信息："
if "%commit_msg%"=="" (
    for /f "tokens=1-3 delims=/" %%a in ('date /t') do set date=%%a%%b%%c
    for /f "tokens=1-3 delims=:" %%a in ('time /t') do set time=%%a%%b%%c
    set commit_msg=自动提交 %date% %time%
)

echo.
echo 提交更改...
git add --all
git commit -m "%commit_msg%"

echo.
echo 推送到远程仓库...
git push

echo.
echo 所有操作完成！
pause