# Intializ data 
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$log      = "$ScriptDir\PingScript.log"
$date     = Get-Date -Format "dd-MM-yyyy hh:mm:ss"
$list = Get-Content ".\pc.txt"
$logFilder = New-Item "C:\Log\VRN02\" -Force -Type Directory 
"---------------------  Script executed on $date (DD-MM-YYYY hh:mm:ss) ---------------------" + "`r`n" | Out-File $log -append

$process = $False
Do {
    $process = Read-Host "1. Запустить тест Ping`n2. Выключить тест Ping`n3. Копировать скрипт`n4. Скопировать и запустить`nВыберете номер [1-4]"
    switch($process){
        1 {Foreach ($PC in $list) { 
        Write-Host "--------------------------$PC START-------------------------" -ForegroundColor DarkGreen
        Invoke-Command -ComputerName $PC -FilePath .\PingTest.ps1 -AsJob -JobName $PC 
        }} # Запустить тест
        2 {Foreach ($PC in $list) { 
        $session = New-PSSession -ComputerName $PC
        Invoke-Command -computername $PC -ScriptBlock {foreach($prc in (get-job | Select id)) {Stop-Job $prc.Id; Remove-Job $prc.Id}} | Out-File $log -Append}}  #Выключить тест
        3 {Foreach ($PC in $list) { 
        $session = New-PSSession -ComputerName $PC
        Copy-Item -Path ".\PingTest.ps1" -ToSession $session -Destination "C:\" -Recurse -Force -ErrorAction SilentlyContinue}} # Скопировать скрипт
        4 {Foreach ($PC in $list) { 
                $session = New-PSSession -ComputerName $PC
                Copy-Item -Path ".\PingTest.ps1" -ToSession $session -Destination "C:\" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host $PC
                Enter-PSSession $PC; C:\PingTest.ps1; exit
                Out-File $log -InputObject ($PC +" Запущен " + $date ) -Append 
}} # Скопировать и запустить
        5 {Foreach ($PC in $list) { 
                $DirSession = New-Item "C:\Log\VRN02\$PC" -Force -Type Directory 
                $session = New-PSSession -ComputerName "$PC"
                Copy-Item -Path "C:\Log\*" -Destination $DirSession -Recurse -Force -FromSession $session 
                Invoke-Command -ComputerName "$PC" {Remove-Item -Path "C:\Log\*" -recurse -Force}
        } #-ErrorAction SilentlyContinue
        }
        6 {Foreach ($PC in $list) { 
        $session = New-PSSession -ComputerName $PC
        Copy-Item -Path ".\PingTest.ps1" -ToSession $session -Destination "C:\" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host $PC
        Enter-PSSession $PC; C:\PingTest.ps1; exit
        Out-File $log -InputObject ($PC +" Запущен " + $date ) -Append 
}} # Выгрузить данные по тесту

        Default {
            Write-Host "Неверный выбор"
            $process = $False
            }
    }
}
While ($process -eq $false)
