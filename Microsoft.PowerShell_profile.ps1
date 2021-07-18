# Изменение внешнего вида консоли
#(Get-Host).UI.RawUI.ForegroundColor = "green"
#(Get-Host).UI.RawUI.BackgroundColor = "black"
#(Get-Host).UI.RawUI.CursorSize = 10
#(Get-Host).UI.RawUI.WindowTitle = "My Window"

# Установка директорию по умолчанию
Set-Location C:\

# Новый алиас для Get-Help
#Set-Alias HelpMе Get-Help

# Добавление всех зарегистрированных оснасток и модулей
#Get-Pssnapin -Registered | Add-Pssnapin -Passthru -ErrorAction SilentlyContinue
#Get-Module -ListAvailable| Import-Module -PassThru -ErrorAction SilentlyContinue

# Очиcтка экрана
#Clear-Host

# Приветствие себя любимого
#Write-Host "Hello, my friend !!!"
Write-Host "You Login Milovanov"
Write-Host

function Get-AllNotMFA (){
get-aduser -SearchBase "OU=VRN02,OU=REGIONS RUSSIA,OU=OFFICES,DC=office,DC=softline,DC=ru" -Filter * -Properties * | Select  Name,UserPrincipalName,extensionAttribute4 | foreach{if ($_.extensionAttribute4 -eq $null) { $_.UserPrincipalName}} | Out-File not_mfa.txt -Append
}



# Запро информации MFA находящийся в extensionAttribute4.
function Get-MFA ($UserName,$UserMail) {
	if ($UserName -ne $null) {
		Get-ADUser $UserName -Properties * | Select extensionAttribute4 | foreach {$_.extensionAttribute4} | Write-Host -ForegroundColor darkgreen -NoNewline; Write-Host " => " -ForegroundColor white -NoNewline; ; Write-Host $args[0] -ForegroundColor DarkGreen;
	}
	elseif ($UserMail -ne $null){
		Get-ADUser -Filter "UserPrincipalName -eq '$($UserMail)'" -Properties extensionAttribute4 | Select extensionAttribute4 | foreach {$_.extensionAttribute4} | Write-Host -ForegroundColor darkgreen -NoNewline; Write-Host " => " -ForegroundColor white -NoNewline; ; Write-Host $args[0] -ForegroundColor DarkGreen; 
	}
}



# Запрос орг структуры используя ключи Identity и Recurse
function Get-ADDirectReports {
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory)]
        [String[]]$Identity,
        [Switch]$Recurse
    )
    BEGIN {
        TRY {
            IF (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction 'Stop' -Verbose:$false }
        }
        CATCH {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    PROCESS {
        foreach ($Account in $Identity) {
            TRY {
                IF ($PSBoundParameters['Recurse']) {
                    # Get the DirectReports
                    Write-Verbose -Message "[PROCESS] Account: $Account (Recursive)"
                    Get-Aduser -identity $Account -Properties directreports |
                        ForEach-Object -Process {
                            $_.directreports | ForEach-Object -Process {
                                # Output the current object with the properties Name, SamAccountName, Mail and Manager
                                Get-ADUser -Identity $PSItem -Properties * | Select-Object -Property *, @{ Name = "ManagerAccount"; Expression = { (Get-Aduser -identity $psitem.manager).samaccountname } }
                                # Gather DirectReports under the current object and so on...
                                Get-ADDirectReports -Identity $PSItem -Recurse
                            }
                        }
                }#IF($PSBoundParameters['Recurse'])
                IF (-not ($PSBoundParameters['Recurse'])) {
                    Write-Verbose -Message "[PROCESS] Account: $Account"
                    # Get the DirectReports
                    Get-Aduser -identity $Account -Properties directreports | Select-Object -ExpandProperty directReports |
                    Get-ADUser -Properties * | Select-Object -Property *, @{ Name = "ManagerAccount"; Expression = { (Get-Aduser -identity $psitem.manager).samaccountname } }
            }#IF (-not($PSBoundParameters['Recurse']))
        }#TRY
        CATCH {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}
END {
    Remove-Module -Name ActiveDirectory -ErrorAction 'SilentlyContinue' -Verbose:$false | Out-Null
}
}

#