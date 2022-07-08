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
echo /============ BUILD =============
echo /

cd ..\..
mkdir .\.build\VipM-MultiJump\amxmodx\scripting\

xcopy .\amxmodx\ .\.build\VipM-MultiJump\amxmodx\ /s /e /y
copy .\README.md .\.build\

if exist .\VipM-MultiJump.zip del .\VipM-MultiJump.zip
cd .\.build
zip -r .\..\VipM-MultiJump.zip .
cd ..
rmdir .\.build /s /q

echo /
echo /
echo /============ END =============
echo /

set /p q=