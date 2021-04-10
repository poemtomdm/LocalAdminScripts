Import-Module Microsoft.Powershell.LocalAccounts

$group = Get-LocalGroup -SID "S-1-5-32-544" | select name -ExpandProperty name


$A = New-ScheduledTaskAction -Execute cmd.exe -Argument '/c start /min powershell.exe -windowstyle hidden -file C:\Windows\SysWOW64\LocalAccountsMgt.ps1 ^& exit'
$T = New-ScheduledTaskTrigger -Weekly -WeeksInterval 2 -DaysOfWeek Wednesday -At 12pm
$S = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$P = New-ScheduledTaskPrincipal -GroupId "BUILTIN\$group" -RunLevel Highest
$D = New-ScheduledTask -Action $A -Trigger $T -Settings $S -Principal $P
Register-ScheduledTask LocalAccountMgt -InputObject $D