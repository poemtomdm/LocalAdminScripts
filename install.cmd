rem Copy Files
copy LocalAccountsMgt.ps1 C:\Windows\SysWOW64
copy TaskAccountMgt.ps1 C:\Windows\SysWOW64


%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -ex bypass -file C:\Windows\SysWOW64\TaskAccountMgt.ps1
SCHTASKS.EXE /RUN /TN "LocalAccountMgt"

