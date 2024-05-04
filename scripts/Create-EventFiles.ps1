<#
.SYNOPSIS
  Reads an events file in CSV format, and generates an event calendar in Markdown table format.

  The table format includes a Google calendar link and Apple Calendar (.ics) file link 
  for each event.
#>

[CmdletBinding()]
param (

  [string] $EventsFile = "..\events.csv",

  [string] $EventsOutputDirectory = "$PSScriptRoot\..\assets\event-files",
  
  [string] $IncludesOutputDirectory = "$PSScriptRoot\..\_includes"
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
        [timespan] $Duration,

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

function New-GoogleCalendarLink {
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
        [timespan] $Duration,

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
            $fileName = Join-Path -Path $Path -ChildPath "$($Date.ToString($icsDateFormat)).url"

            # should not require URL encoding
            $urlStartDate = $($Date.ToUniversalTime().ToString($icsDateFormat))
            $urlEndDate = $($Date.Add($Duration).ToUniversalTime().ToString($icsDateFormat))
            
            # encode name, start date, end date, description, location for URL
            $encodedSubject = [System.Web.HttpUtility]::UrlEncode($Subject)
            $encodedDescription = [System.Web.HttpUtility]::UrlEncode($EventDescription)
            $encodedLocation = [System.Web.HttpUtility]::UrlEncode($Location)

            $eventUrl = "https://www.google.com/calendar/render?action=TEMPLATE" `
                + "&text=" + $encodedSubject `
                + "&dates=" + $urlStartDate + "/" + $urlEndDate `
                + "&details=" + $encodedDescription `
                + "&location=" + $encodedLocation `
                + "&sf=true&output=xml"

            if ($PSCmdlet.ShouldProcess($fileName, 'Write URL file')) {
                $eventUrl | Out-File -FilePath $fileName -Encoding utf8 -Force
                if ($PassThru) {
                    Get-Item -Path $fileName
                }
            }
        }
    }
}

if (!$(Test-Path $EventsOutputDirectory)) {
    mkdir $EventsOutputDirectory
}

# import CSV file as PSObjects with named attributes
$events = Import-CSV -Path $EventsFile

# generate the markdown for the events calendar for include
$markdownTable = @"
| **Date**      | **Rain Date (only if primary date is canceled)** | **Hours**     |
|:-------------:|:------------------------------------------------:|:-------------:|
"@
  
# create each event
foreach ($event in $events) {
  
  # echo event details
  $event

  # create file and pass attributes
  $icsFileInfo = New-IcsEvent `
    -Path $EventsOutputDirectory `
    -Subject $event.Name `
    -Location $event.Location `
    -StartDate $event.StartDateTime `
    -Duration $event.DurationHMS `
    -EventDescription $event.Description `
    -PassThru `
    -ShowAs Busy

  # generate link file (not used except to read it back in)
  $urlFileInfo = New-GoogleCalendarLink `
    -Path $EventsOutputDirectory `
    -Subject $event.Name `
    -Location $event.Location `
    -StartDate $event.StartDateTime `
    -Duration $event.DurationHMS `
    -EventDescription $event.Description `
    -PassThru `
    -ShowAs Busy

  # get relative path from root dir to assets/event-files/name.ics
  $icsFilePathFromRoot = Get-ChildItem -Path "$PSScriptRoot\.." -Recurse -Name $icsFileInfo.Name
  $icsFilePathFromRoot = $icsFilePathFromRoot -replace '\\', '/'

  # read the google calendar link from the file
  $googleCalendarLink = Get-Content -Raw -LiteralPath $($urlFileInfo.FullName)
  $googleCalendarLink = $googleCalendarLink.Trim()

  # TODO format using "Dayofweek Month DayOfMonth starttime-endtime"
  $markdownLink = ""
  $event.StartDateTime
  $event.DurationHMS

  $dayofweekMonthDay = ""
  $markdownTable += "| Sat May 18 1-5pm [Google Calendar]($markdownLink) [iCal]({{ site.url }}/$icsFilePathFromRoot) | Sat May 25  + ""
  # create Jekyll include link via markdown
  $markdown = "[Google Calendar](" + $() + ")" `
     + " [iCal]({{ site.url }}/" + $icsFilePathFromRoot + ")"
  $markdown | Out-File -LiteralPath $markdownFilePath
  
  # get relative path from root dir to _includes/filename.md
  $markdownFilePathFromRoot = Get-ChildItem -Path "$PSScriptRoot\.." -Recurse -Name $icsFileInfo.Name
  $markdownFilePathFromRoot = $markdownFilePathFromRoot -replace '\\', '/'


# | Sat May 18 - {% include 20240518T130000Z.md %}  | Sat May 25 - [add to calendar]({{ site.url }}/assets/event-files/20240525T130000Z.ics) | 1pm - 5pm |
# | Sat June 22 (add to calendar)    | Sat June 29                                      | 1pm - 5pm     |
# | Sat July 13 (add to calendar)     | Sat July 20                                      | 1pm - 5pm     |
# | Sat August 10    | Sat Aug 17                                       | 1pm - 5pm     |
# | Sat September 14 | Sat September 21                                 | 1pm - 5pm     |
# | Sat October 12   | Sat October 19                                   | 1pm - 5pm     |

}

# write markdown table for inclusion
$markdown | Out-File -LiteralPath $markdownFilePath
$markdownFilePath = Join-Path $IncludesOutputDirectory "events-calendar.md"
