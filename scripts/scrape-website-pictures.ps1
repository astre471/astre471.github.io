#
# Temporary script to download photos and thumbnails from the old website
# to local disk.
#
# 1. List all "albums" at https://www.astre471.org/Pictures/
# 2. For each album, download pictures and thumbnails to `assets/images/[album-type]/[album-name]`
#
# Isn't there a webcrawler to do this?
#
# 220917/02_220917.JPG

$ErrorActionPreference = "stop"

# dont show progress bars for Invoke-WebRequest
$global:ProgressPreference = 'SilentlyContinue'

$outputDir = "temp-output" # "assets/images/sport-launches"
mkdir -Force $outputDir

$webpage = "https://www.astre471.org/Pictures/"
$WebResponse = Invoke-WebRequest $webpage

foreach ($link in $WebResponse.Links) {

    # skip links that don't connect to the picture pages
    $linkHref = $link.href
    if (!($linkHref.Contains("/Pics/"))) {
        continue
    }

    # remove "<a href=...>" and "</a", number of photos, leading/trailing spaces
    $linkText = $link.outerHtml -replace "<a [^>]+>", "" -replace "</a>", ""

    # get number of images
    $success = $linkText -match "\[([0-9]+)\]"
    if (!$success) {
        throw "Cnanot parse number of images from '$linkText'"
    }
    $numImages = [int] $matches[1]

    # remove number of images from link text to get album name
    $albumName = $linkText -replace "\[([0-9]+)\]", ""
    $albumName = $albumName.trim()

    # format gallery name
    $success = $linkHref -match '\?f=(.+)$'
    if (!$success) {
        throw "Unable to find gallery name match in $linkHref"
    }
    $folderName = $matches[1] # e.g. '220917'

    # create new directory if not already present
    Write-Host "Album name: $folderName with $numImages images"

    # parse to get new gallery name
    $galleryYear = $folderName.substring(0, 2)
    $galleryMonth = $folderName.substring(2, 2)  
    $galleryDay = $folderName.substring(4, 2)
    $galleryName = "20$galleryYear-$galleryMonth-$galleryDay" # e.g. '2022-09-17'
    $galleryPath = "$outputDir\$galleryName"
    mkdir -Force $galleryPath | Out-Null

    # javascript image listing function is not called by Invoke-WebRequest,
    # so only images from one event in 2019 are returned as links (default behavior)
    
    # download each image based on format and number
    for ($i = 1; $i -le $numImages; $i += 1) {
        $paddedIndex = '{0:d2}' -f $i

        # download thumbnail
        $thumbnailName = "$($paddedIndex)_tn_$($folderName).JPG"
        $thumbnailFilePath = "$galleryPath\$thumbnailName"
        $thumbnailHref = "https://www.astre471.org/Pics/$folderName/$thumbnailName"
        if (Test-Path $thumbnailFilePath) {
            Write-Output "`tThumbnail: $thumbnailHref (already exists)"
        } else {
            Write-Output "`tThumbnail: $thumbnailHref"
            try {
                Invoke-WebRequest $thumbnailHref -OutFile $thumbnailFilePath | Out-Null
            } catch {
                Write-Warning "Error downloading $thumbnailHref - try again later."
            }
        }

        # download image
        $imageName = "$($paddedIndex)_$($folderName).JPG"
        $imageFilePath = "$galleryPath\$imageName"
        $imageHref = "https://www.astre471.org/Pics/$folderName/$imageName"
        if (Test-Path $imageFilePath) {
            Write-Output "`tImage: $imageHref (already exists)"
        } else {
            Write-Output "`tImage: $imageHref"
            try {
                Invoke-WebRequest $imageHref -OutFile $imageFilePath | Out-Null
            } catch {
                Write-Warning "Error downloading $imageHref - try again later."
            }
        }
    }
}
