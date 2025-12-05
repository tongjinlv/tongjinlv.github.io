@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 切换到脚本所在目录
cd /d "%~dp0"
echo 当前目录：%cd%
echo.

echo 正在查找需要合并的目录...
echo.

:: 获取当前目录名称
for %%I in (.) do set "current_dir_name=%%~nxI"

:: 先检查父目录中是否有其他类似目录
set found=0
pushd ..
for /d %%d in ("%current_dir_name%*") do (
    set "dir_name=%%~nxd"
    
    :: 排除当前目录本身
    if not "!dir_name!"=="%current_dir_name%" (
        set /a found+=1
        echo 找到目录：%%d
    )
)
popd

if !found! equ 0 (
    echo 未找到需要合并的其他目录。
    echo 跳过合并步骤。
    echo.
) else (
    echo.
    echo 开始合并目录...
    echo.
    
    pushd ..
    for /d %%d in ("%current_dir_name%*") do (
        set "dir_name=%%~nxd"
        
        if not "!dir_name!"=="%current_dir_name%" (
            echo 正在处理：%%d
            
            :: 检查源目录是否存在且不为空
            if exist "%%d\" (
                echo   移动文件到：%cd%\%current_dir_name%
                
                :: 移动所有文件
                move "%%d\*" "%cd%\%current_dir_name%\" >nul 2>nul
                
                :: 删除空目录
                rd "%%d" 2>nul
                echo   处理完成
                echo.
            )
        )
    )
    popd
    
    echo 目录合并完成！
    echo.
)

:: 检查Python脚本是否存在
if not exist "replace_images.py" (
    echo 错误：在当前目录找不到 replace_images.py
    echo.
    pause
    exit /b 1
)

echo 执行Python脚本处理图片...
python replace_images.py
if errorlevel 1 (
    echo Python脚本执行失败！
    pause
    exit /b 1
)

echo.
echo Python脚本执行成功！
echo.

echo 配置Git...
git config --global core.quotepath true

echo.
echo Git状态：
git status

echo.
set /p commit_msg="请输入提交信息："
if "%commit_msg%"=="" (
    for /f "tokens=1-3 delims=/." %%a in ('date /t') do set date=%%a%%b%%c
    for /f "tokens=1-3 delims=:." %%a in ('time /t') do set time=%%a%%b%%c
    set commit_msg=自动提交 %date%_%time%
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