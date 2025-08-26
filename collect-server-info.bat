@echo off
setlocal enabledelayedexpansion

REM Get Computer Name
set "ComputerName=%COMPUTERNAME%"


REM Get Logon domain and Workstation domain
for /f "tokens=3*" %%D in ('net config workstation ^| findstr /i /c:"Logon domain"') do set "LogonDomain=%%D"
for /f "tokens=3*" %%D in ('net config workstation ^| findstr /i /c:"Workstation domain"') do set "WorkgroupName=%%D"

REM Determine domain membership and set NetBIOSDomain accordingly
set "DomainStatus=NO"
if /I "%LogonDomain%"=="%ComputerName%" (
    set "NetBIOSDomain=%WorkgroupName%"
) else (
    set "NetBIOSDomain=%LogonDomain%"
    set "DomainStatus=YES"
)

REM Get IPv4 Address (not loopback) using PowerShell
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' -and ($_.PrefixOrigin -eq 'Dhcp' -or $_.PrefixOrigin -eq 'Manual') }).IPAddress"') do (
    set "IPAddress=%%A"
)


REM Output the results
echo.
echo ################################################
echo       ONLY WINDOWS SERVERS ARE SUPPORTED!
echo FOR WINDOWS SERVERS THAT ARE NOT PART OF DOMAIN,
echo  THEIR WORKGROUP IS USED AS DOMAIN NETBIOS NAME
echo ################################################
echo.
echo IS THIS SERVER PART OF A DOMAIN: !DomainStatus!
echo.
echo USE THE FOLLOWING INFORMATION TO CONFIGURE
echo     REMOTE OFFICE IN PATCH MANAGER PLUS
echo.
echo Domain NetBios Name: !NetBIOSDomain!
echo Computer Name: %ComputerName%
echo IP Address: !IPAddress!
echo.
echo.
pause
endlocal
