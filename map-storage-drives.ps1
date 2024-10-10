$global:serverhost = "<some-storage-location>.home.local"

function Add-Network-Disk
{
    Param
    (
            [Parameter(Mandatory=$true, Position=0)]
            [string] $servername,
            [Parameter(Mandatory=$true, Position=1)]
            [string] $foldername,
            [Parameter(Mandatory=$true, Position=2)]
            [string] $driveLetter,
            [Parameter(Mandatory=$false, Position=4)]
            [ValidateNotNull()]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            $credential = [System.Management.Automation.PSCredential]::Empty
    )

    write-host "Mounting drive $($driveletter):" -ForegroundColor Green

    try
    {
    
    
        try
        {
            $drive = Get-PSDrive -Name $driveletter -Scope Global -PSProvider FileSystem -ErrorAction SilentlyContinue



            if ($drive -ne $null)
            {
                Remove-PSDrive -Name $driveletter -ErrorAction Stop
            }
        }
        catch
        {
            write-host "`tWarning: Drive exists" -ForegroundColor Yellow
        }
        
        
        [System.Collections.Specialized.ListDictionary]$params = @{}

        if($credential -ne [System.Management.Automation.PSCredential]::Empty)
        {
            $params.Add('ScriptBlock', { New-PSDrive -Name $driveletter -PSProvider FileSystem -Root "\\$servername\$foldername" -Persist -Scope Global -ErrorAction Stop -Credential $credential})   
        }
        else
        {
            $params.Add('ScriptBlock', { New-PSDrive -Name $driveletter -PSProvider FileSystem -Root "\\$servername\$foldername" -Persist -Scope Global -ErrorAction Stop })
        }
        
        Invoke-Command @params -ErrorAction Stop

        write-host "Drive $($driveletter.ToUpper()): mounted"
    }
	catch [System.ComponentModel.Win32Exception]{
		write-host "`tWarning drive letter already mounted" -ForegroundColor Blue
	}
    catch {
        write-host "`tError mounting disk: $($_.Exception.Message) $($_.Exception.GetType().FullName)" -ForegroundColor Magenta
    }
        
}

function Get-Local-Credential
{
    Param(
        [Parameter(Mandatory=$true)]
        [string] $username

    )

    $password = ConvertTo-SecureString $username -AsPlainText -Force
    $rtnval = New-Object System.Management.Automation.PSCredential($username, $password)

    return $rtnval

}

$lowercomputername = ($env:COMPUTERNAME).ToLower()

$credential = Get-Local-Credential -username $lowercomputername

#system drives

Add-Network-Disk -servername $serverhost -foldername "File History" -driveLetter "f" -credential $credential 
Add-Network-Disk -servername $serverhost -foldername "Backup Data" -driveLetter "k" -credential $credential 
Add-Network-Disk -servername $serverhost -foldername "profiles\netlogon" -driveLetter "n" -credential $credential
Add-Network-Disk -servername $serverhost -foldername "3rd Party Apps" -driveLetter "t" -credential $credential


#user drives

Add-Network-Disk -servername $serverhost -foldername "games" -driveLetter "g" -credential $credential 
Add-Network-Disk -servername $serverhost -foldername "profiles\$lowercomputername" -driveLetter "h" -credential $credential 
Add-Network-Disk -servername $serverhost -foldername "Images" -driveLetter "i" -credential $credential 
Add-Network-Disk -servername $serverhost -foldername "Music" -driveLetter "m" -credential $credential 
Add-Network-Disk -servername $serverhost -foldername "Documents" -driveLetter "o" -credential $credential 
Add-Network-Disk -servername $serverhost -foldername "Printable" -driveLetter "p" -credential $credential 
Add-Network-Disk -servername $serverhost -foldername "code" -driveLetter "s" -credential $credential 
Add-Network-Disk -servername $serverhost -foldername "Videos" -driveLetter "v" -credential $credential 