echo off
REM /XD "teste" nao copia a pasta teste
del G:\vms\robocopy.log
\Windows\System32\Robocopy.exe C:\Users\Alessandro\Dropbox C:\Users\Alessandro\OneDrive /E /W:0 /R:1 /LOG:C:\Users\Alessandro\Dropbox\robocopy.log
C:\Users\Alessandro\Dropbox\robocopy.log
exit