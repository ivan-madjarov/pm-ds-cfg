@echo off
setlocal enabledelayedexpansion

REM Use PowerShell for detection (robust, language-independent)

REM Use PowerShell for all detection (language-independent)
for /f "delims=" %%A in ('powershell -NoProfile -Command "try { $cs = Get-WmiObject -Class Win32_ComputerSystem; if ($cs.PartOfDomain) { Write-Output 'DOMAIN:'$cs.Domain } elseif ($cs.Domain -and $cs.Domain -ne $env:COMPUTERNAME -and $cs.Domain -ne 'WORKGROUP') { Write-Output 'DOMAIN:'$cs.Domain } else { Write-Output 'WORKGROUP:'$cs.Domain } } catch { Write-Output 'ERROR' }" 2^>nul') do set "DomainInfo=%%A"
for /f "delims=" %%A in ('powershell -NoProfile -Command "try { $ntd = Get-WmiObject Win32_NTDomain | Where-Object { $_.DomainName -ne $null }; if ($ntd) { $ntd.Name } } catch { }" 2^>nul') do set "NetBiosDomain=%%A"
for /f "delims=" %%A in ('powershell -NoProfile -Command "$env:COMPUTERNAME" 2^>nul') do set "ComputerName=%%A"
for /f "delims=" %%A in ('powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.IPAddress -notlike '169.*' } | Select-Object -First 1 -ExpandProperty IPAddress" 2^>nul') do set "IPAddress=%%A"

REM Fallbacks if PowerShell fails
if not defined ComputerName set "ComputerName=%COMPUTERNAME%"
if not defined DomainInfo if not "%USERDOMAIN%"=="" set "DomainInfo=DOMAIN:%USERDOMAIN%"
if not defined NetBiosDomain if not "%USERDOMAIN%"=="" set "NetBiosDomain=%USERDOMAIN%"
if not defined IPAddress set "IPAddress=Not detected"

REM Debug output flag
set "DEBUG=0"
if "%DEBUG%"=="1" (
    echo [DEBUG] Raw DomainInfo: [%DomainInfo%]
    echo [DEBUG] Raw NetBiosDomain: [%NetBiosDomain%]
    echo [DEBUG] Raw ComputerName: [%ComputerName%]
    echo [DEBUG] Raw IPAddress: [%IPAddress%]
    echo [DEBUG] Raw USERDOMAIN: [%USERDOMAIN%]
)

REM Output the results
echo.
echo ################################################
echo       ONLY WINDOWS SERVERS ARE SUPPORTED
echo FOR WINDOWS SERVERS THAT ARE NOT PART OF DOMAIN,
echo  THEIR WORKGROUP IS USED AS DOMAIN NETBIOS NAME
echo ################################################
echo.
echo USE THE FOLLOWING INFORMATION TO CONFIGURE
echo     REMOTE OFFICE IN PATCH MANAGER PLUS
echo.
REM Clean NetBiosDomain: remove any 'Domain:' prefix and trim spaces
set "CleanNetBiosDomain=%NetBiosDomain%"
setlocal enabledelayedexpansion
set "_tmp=!CleanNetBiosDomain!"
set "_tmp=!_tmp:Domain:=!"
set "_tmp=!_tmp:domain:=!"
REM Remove all spaces
for /f "tokens=*" %%C in ("!_tmp: =!") do set "_tmp=%%C"
endlocal & set "CleanNetBiosDomain=%_tmp%"
REM If CleanNetBiosDomain is empty or only spaces, fallback to DomainInfo
for /f "tokens=*" %%X in ("%CleanNetBiosDomain%") do set "CleanNetBiosDomain=%%X"
set "_isCleanNetBiosDomainNonEmpty=0"
for %%Z in ("%CleanNetBiosDomain%") do (
    if not "%%~Z"=="" set "_isCleanNetBiosDomainNonEmpty=1"
)
if "%_isCleanNetBiosDomainNonEmpty%"=="1" (
    echo Domain NetBios Name: %CleanNetBiosDomain%
) else (
    echo Domain NetBios Name: %DomainInfo%
)
echo Computer Name: %ComputerName%
echo IP Address: %IPAddress%
echo.
pause
endlocal
