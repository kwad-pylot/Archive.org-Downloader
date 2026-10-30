@echo off
cd /d "%~dp0"
set "FILE=login.txt"
set "LIST=%TEMP%\archive-urls.txt"
set "email="
set "password="
set "return_book="
if exist "%LIST%" del "%LIST%"
if not exist "%FILE%" goto nofile
for /f "usebackq tokens=1,* delims==" %%a in ("%FILE%") do set "%%a=%%b"
if not defined email goto nologin
if not defined password goto nologin
set "KEEP="
if /i "%return_book%"=="no" set "KEEP=--keep-loan"

echo What do you want to download?
echo   1 = PDF only (same as before)
echo   2 = PDF and text
echo   3 = Text only, no pictures
set "MODE="
set /p "MODE=Type 1, 2 or 3 and press Enter (Enter alone = 1): "
set "OPTS="
if "%MODE%"=="2" set "OPTS=--text"
if "%MODE%"=="3" set "OPTS=--text-only"
if defined KEEP (echo The book stays borrowed when done. To change this, set return_book=yes in %FILE%.) else (echo The book is returned when done. To keep it, set return_book=no in %FILE%.)
echo.

echo Paste a book link and press Enter. Right-click pastes.
echo The link must start with https://archive.org/details/
echo You can paste more links, one at a time.
echo When you are done, press Enter on an empty line to start.
echo.

:ask
set "URL="
set /p "URL=Book link: "
if not defined URL goto start
for /f "delims=" %%u in ("%URL%") do >>"%LIST%" echo %%u
goto ask

:start
if not exist "%LIST%" goto nourl
.venv\Scripts\python archive-org-downloader.py -e "%email%" -p "%password%" -r 0 %OPTS% %KEEP% -f "%LIST%"
goto end

:nofile
echo Cannot find %FILE% in this folder.
echo Make a text file with this name, with these 2 lines:
echo   email=your archive.org email
echo   password=your archive.org password
goto end

:nologin
echo Your email or password is missing from %FILE%.
echo Open the file and make sure it has these 2 lines:
echo   email=your archive.org email
echo   password=your archive.org password
goto end

:nourl
echo No link entered. Nothing to download.

:end
echo.
pause
