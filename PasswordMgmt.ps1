function Get-RandomPassword {
    param (
        [Parameter(Mandatory)]
        [int] $length,
        [int] $amountOfNonAlphanumeric = 1
    )
    Add-Type -AssemblyName 'System.Web'
    return [System.Web.Security.Membership]::GeneratePassword($length, $amountOfNonAlphanumeric)
}

function Change-Password {
    param (
        [Parameter(Mandatory)]
        [string] $Username,
        [string] $Password
    )

    # Convert pass
    $Pass = ConvertTo-SecureString $Password -AsPlainText -Force 

    Set-ADAccountPassword -Identity $Username -NewPassword $Pass
}

function Set-ServicePassword-UserPass {
    param (
        [Parameter(Mandatory)]
        [string] $ServiceName,
        [string] $Username,
        [string] $Password
    )

    # Convert password to setup credential object
    $Pass = ConvertTo-SecureString $Password -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)

    # Set service credentials
    Set-ServicePassword-Credential -ServiceName $ServiceName -Credential $Credential

}

function Set-ServicePassword-Credential {
    param (
        [Parameter(Mandatory)]
        [string] $ServiceName,
        [System.Net.CredentialCache] $Credential
    )

    # Stop the service
    $proc = Set-Service -Name $ServiceName -Status Stopped
    Wait-Process -InputObject $proc

    # Set the service credentials
    Set-Service -Name $ServiceName -Credential $Credential

    # Start the service
    $proc = Set-Service -Name $ServiceName -Status Running
    Wait-Process -InputObject $proc

}