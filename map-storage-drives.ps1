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


Add-Network-Disk -servername $serverhost -foldername "<share name>" -driveLetter "d" -credential $credential 
#Add-Network-Disk -servername $serverhost -foldername "<share name 2>" -driveLetter "e" -credential $credential 