
[CmdletBinding()]
param (
  [string] $OutputDirectory = ".\events",

  [string] $DatesFiles = "dates.txt",

  [string] $Location
)

function New-IcsEvent {
    [OutputType([System.IO.FileInfo[]])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime[]] $StartDate,

        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $Subject,

        [Parameter()]
        [string] $Location,

        [Parameter()]
        [timespan] $Duration = '01:00:00',

        [Parameter()]
        [string] $EventDescription,

        [Parameter()]
        [switch] $PassThru,

        [ValidateSet('Free', 'Busy')]
        [string] $ShowAs = 'Busy',

        [ValidateSet('Private', 'Public', 'Confidential')]
        [string] $Visibility = 'Public',

        [Parameter()]
        [string[]] $Category 
    )

    begin {
        # Custom date formats that we want to use
        $icsDateFormat = "yyyyMMddTHHmmssZ"
    }

    process {
        # Checkout RFC 5545 for more options
        foreach ($Date in $StartDate) {
            $fileName = Join-Path -Path $Path -ChildPath "$($Date.ToString($icsDateFormat)).ics"
            $event = @"
BEGIN:VCALENDAR
VERSION:2.0
METHOD:PUBLISH
PRODID:-//JHP//We love PowerShell!//EN
BEGIN:VEVENT
UID:$([guid]::NewGuid())
CREATED:$((Get-Date).ToUniversalTime().ToString($icsDateFormat))
DTSTAMP:$((Get-Date).ToUniversalTime().ToString($icsDateFormat))
LAST-MODIFIED:$((Get-Date).ToUniversalTime().ToString($icsDateFormat))
CLASS:$Visibility
CATEGORIES:$($Category -join ',')
SEQUENCE:0
DTSTART:$($Date.ToUniversalTime().ToString($icsDateFormat))
DTEND:$($Date.Add($Duration).ToUniversalTime().ToString($icsDateFormat))
DESCRIPTION:$EventDescription
SUMMARY:$Subject
LOCATION:$Location
TRANSP:$(if($ShowAs -eq 'Free') {'TRANSPARENT'})
END:VEVENT
END:VCALENDAR
"@
            if ($PSCmdlet.ShouldProcess($fileName, 'Write ICS file')) {
                $event | Out-File -FilePath $fileName -Encoding utf8 -Force
                if ($PassThru) { Get-Item -Path $fileName }
            }
        }
    }
}

if (!$(Test-Path $OutputDirectory)) {
    mkdir $OutputDirectory
}

$events = Import-CSV -Path ..\events.txt
foreach ($event in $events) {
  $event

  New-IcsEvent `
    -Path $OutputDirectory `
    -Subject $event.Name `
    -Location $Location `
    -StartDate $event.StartDateTime `
    -Duration $event.DurationHMS `
    -EventDescription $event.Description `
    -ShowAs Busy
}


# # Create events one by one
# New-IcsEvent -Path $OutputDirectory -Subject 'Be hung over' -Location $Location -StartDate '2018-01-01 09:00' -ShowAs Free

# # Or use the pipeline for multiple dates
# '08-15', '08-16' | New-IcsEvent -Path $OutputDirectory -Subject 'Super important meeting' -Location 'Area 51' -Visibility Private -ShowAs Busy

# # By using PassThru, you can attach those to emails as well
# $attachments = ('08-15', '08-16' | New-IcsEvent -Path D:\temp -Subject 'Super important meeting' -Location 'Area 51' -PassThru).FullName

# $Outlook = New-Object -ComObject Outlook.Application
# $account = $Outlook.Session.Accounts | Where {$_.SmtpAddress -eq 'YOUR@MAIL.HERE' } # In case of multiple accounts
# $Mail = $Outlook.CreateItem(0)
# $null = $attachments.ForEach({$Mail.Attachments.Add($_, 1, 1, ([System.IO.Path]::GetFileNameWithoutExtension($_)))})
# $Mail.SendUsingAccount = $account
# $Mail.Subject = 'Have some meetings!'
# $Mail.Body = @"
# Hi there!

# We agreed on the attached meetings.

# Cheers!
# "@
# $mail.Display()