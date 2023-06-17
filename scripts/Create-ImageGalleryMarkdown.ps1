# Generates an image gallery markdown file, given an input directory with images.
#
# Usage:
# 1. Open Powershell (any windows 10 or later computer will have it, or it can be downloaded and installed on Windows or Linux)
#    Windows+R to open Run dialog > type Powershell and hit Enter
#
# 2. Create the image gallery folder and copy image jpgs into it. The image files should already be at "web" sizes of less than 1 MB per image.
#     PS> mkdir assets\images\galleries\2099-01-01
#
# 3. Run this script from the *root* of this repository, passing the image gallery folder path:
#     PS> .\scripts\Create-ImageGalleryMarkdown.ps1 -ImageDirectory assets\images\galleries\2099-01-01 -ImageGalleryBaseName 2099-01-01
#
# 4. The markdown file is generated in the default _launch_pictures location.  Add the file and all images, commit the changes, and push to the 
#    GitHub.com repository, and creat a Pull Request.
 

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $ImageDirectory,
    
    [Parameter(Mandatory)]
    [string] $ImageGalleryBaseName,  
    
    [Parameter()]
    [string] $OutputMarkdownDirectory = "_launch_pictures"
)

$ErrorActionPreference = "stop"

# list all non-thumbnail image files
$galleryImages = Get-ChildItem -Path $ImageDirectory -File -Name
    | Sort-Object `
    | Where-Object { ! ($_.Contains("_tn_")) }
    | ForEach-Object { Join-Path $ImageDirectory $_ }
    
# list each image and its thumbnail in the 'gallery' section of the YAML frontmatter
$galleryYaml = "gallery:`n"

$count = 0
$total = $galleryImages.Length

foreach ($imagePath in $galleryImages) {
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
$galleryMarkdownFile = "$OutputMarkdownDirectory/$ImageGalleryBaseName-launch-event.md"
Write-Output "---"                                | Out-File -FilePath $galleryMarkdownFile
Write-Output "title: $ImageGalleryBaseName Album ($($galleryImages.Length) images)" | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output "categories:"                        | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output " - launch"                          | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output "tags:"                              | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output " - pictures"                        | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output $galleryYaml                         | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output "---"                                | Out-File -Append -FilePath $galleryMarkdownFile
Write-Output "{% include gallery layout=`"third`" caption=`"$ImageGalleryBaseName`" %}" | Out-File -Append -FilePath $galleryMarkdownFile

Write-Output "Finished writing $galleryMarkdownFile based on $($galleryImages.Length) images in $ImageDirectory"
