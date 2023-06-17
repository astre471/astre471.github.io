# Generates an image gallery markdown file, given an input directory with images.
#
# Usage:
# 1. Open Powershell (any windows 10 or later computer will have it, or it can be downloaded and installed on Windows or Linux)
# 2. Create the image gallery folder and copy image jpgs into it.
# 3. Run this script from the *root* of this repository, passing the image gallery folder path:
#     PS> .\create-gallery-markdown.ps1 -ImageGalleryDirectory assets\images\galleries\2020-05-30 -ImageGalleryBaseName 2020-05-30
# 4. Copy the resulting markdown file into the right directory.

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $ImageGalleryDirectory,
    
    [Parameter(Mandatory)]
    [string] $ImageGalleryBaseName,  
    
    [Parameter()]
    [string] $OutputMarkdownDirectory = "_launch_pictures"
)

$ErrorActionPreference = "stop"

# get all image files
$galleryImages = Get-ChildItem -Path $subdirPath -File -Name
    | Sort-Object `
    | Where-Object { ! ($_.Contains("_tn_")) }
    | ForEach-Object { Join-Path $subdirPath $_ }
    

# list each image and its thumbnail in the 'gallery' section of the YAML frontmatter
$galleryYaml = "gallery:`n"
    
$total = $imagePaths.Length
$count = 0

foreach ($imagePath in $imagePaths) {
    $count += 1

    # find thumbnail image using convention
    # (could generate thumbnail using powershell, see https://mohundro.com/blog/2008/10/11/simple-powershell-script-to-generate-thumbnails)
    $imageThumbnailPath = $imagePath -replace '\\([0-9]+)_', '\$1_tn_'
    if (!(Test-Path -Path $imageThumbnailPath -PathType leaf)) {
      throw "Expected thumbnail path '$imageThumbnailPath' doesnt exist!"
    }

    # GitHub Actions runs Jekyll on linux, so use linux folder separators
    $imagePath = $imagePath.Replace("\", "/")
    $imageThumbnailPath = $imageThumbnailPath.Replace("\", "/")

    # find thumbnail image using convention
    # (could generate thumbnail using powershell, see https://mohundro.com/blog/2008/10/11/simple-powershell-script-to-generate-thumbnails)
    $imageThumbnailPath = $imagePath -replace '/([0-9]+)_', '/$1_tn_'

    # append to string
    $galleryYaml += " - url: `"$imagePath`"`n"
    $galleryYaml += "   image_path: `"$imageThumbnailPath`"`n"
    $galleryYaml += "   alt: `"Image $count of $total`"`n"
    $galleryYaml += "   title: `"Image $count of $total`"`n"  
}

# write the file
$galleryMarkdownFile = "($OutputMarkdownDirectory)/($ImageGalleryBaseName)-launch-event.md"
Write-Output "---`n"                       | Out-File -FilePath $galleryMarkdownFile
Write-Output "title: $galleryName Album`n" | Out-File -Append -FilePath $galleryMarkdownFil
Write-Output "categories:`n"               | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output " - launch`n"                 | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output "tags:`n"                     | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output " - pictures`n"               | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output $galleryYaml                  | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output "---`n"                       | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output "{% include gallery layout=`"third`" caption=`"$ImageGalleryBaseName`" %}" | Out-File -Append -FilePath $galleryMarkdownFile
