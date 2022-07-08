@echo off

echo /============ PREPARE =============
echo /

if exist .\amxmodx\plugins rd /S /q .\amxmodx\plugins
mkdir .\amxmodx\plugins
cd .\amxmodx\plugins

echo /
echo /
echo /============ COMPILE =============
echo /

for /R ..\scripting\ %%F in (*.sma) do (
    echo / /
    echo / / Compile %%~nF:
    echo / /
    amxx190 %%F
)

echo /
echo /
echo /============ END =============
echo /

set /p q=