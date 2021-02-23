
 $address = Read-Host "Введите адресс"

 New-Item c:\Log -Force -ItemType Directory
 $LogFile = "C:\Log\ya.ru.txt"
 $Date = Get-Date -Format "dd-MM-yyyy [HH:mm:ss]"

ping $address -t | %{
$Temp = "[$($Date)] $($_)"
$TimePing = "" 

   if($_ -like '*Ответ от*'){
      if (($_ -match "время=") -or ($_ -match "time=")) {
      $TimePing = $_.remove(0, (($_.LastIndexOfAny("время")-4))) 
      for ($i = 0; $i -lt $TimePing.Length; $i++) {
         if (-not($TimePing -match "^\d")) {$TimePing = $TimePing.remove(0,1)}
      }
      $TimePing = $TimePing.remove(($TimePing.IndexOfAny("мс")),($TimePing.Length - $TimePing.IndexOfAny("мс")))
      if ([int]$TimePing -ge 1000) {Write-Host $Date +"Lost Connect" -ForegroundColor Red; echo "$Temp Bad connect!" >> $LogFile}
      elseif ([int]$TimePing -ge 100) {Write-Host $Date +"Lost Connect" -ForegroundColor Yellow; echo "$Temp Bad connect!" >> $LogFile}
      else { Write-Host $Temp "Success !" -ForegroundColor Green}
   }   
}
   else {
   Write-Host $Date +"Lost Connect" -ForegroundColor Red 
   echo "$Date Lost connect !" >> $LogFile
   }
}