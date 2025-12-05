@echo off
chdir /d "%~dp0"
python replace_images.py
git config --global core.quotepath true
git status
set /p commit_msg="please input commit message:"
if "%commit_msg%"=="" (
    for /f "tokens=1-3 delims=/" %%a in ('date /t') do set date=%%a%%b%%c
    for /f "tokens=1-3 delims=:" %%a in ('time /t') do set time=%%a%%b%%c
    set commit_msg="auto push %date% %time%"
)
git add --all
git add .
git commit -m "%commit_msg%"
git push
pause