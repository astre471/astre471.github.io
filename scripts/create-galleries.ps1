
$ErrorActionPreference = "stop"

# create an empty array of galleries
$galleries = [Ordered]@{} # name => array of relative file paths from pwd

# for each directory in "assets/images/sport-launches"
$galleriesDir = "assets\images\galleries"
Write-Verbose "Getting subdirectories of $galleriesDir"

# get the relative paths to each non-thumbnail image in the directory
$subdirNames = Get-ChildItem -Path $galleriesDir -Directory -Name | Sort-Object -Descending
foreach ($subdirName in $subdirNames) {
    $subdirPath = Join-Path $galleriesDir $subdirName
    
    $galleryImages = Get-ChildItem -Path $subdirPath -File -Name
      | Sort-Object `
      | Where-Object { ! ($_.Contains("_tn_")) }
      | ForEach-Object { Join-Path $subdirPath $_ }
    $galleryImages

    # capture list of image paths per gallery
    $galleries[$subdirName] = $galleryImages
}

# now write a simple YAML string for the gallery names
foreach ($galleryName in $galleries.Keys) {
    
    $imagePaths = $galleries[$galleryName]
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

        # builds on linux so use linux separators
        $imagePath = $imagePath.Replace("\", "/")
        $imageThumbnailPath = $imageThumbnailPath.Replace("\", "/")

        # find thumbnail image using convention
        # (could generate thumbnail using powershell, see https://mohundro.com/blog/2008/10/11/simple-powershell-script-to-generate-thumbnails)
        $imageThumbnailPath = $imagePath -replace '/([0-9]+)_', '/$1_tn_'

        $galleryYaml += " - url: `"$imagePath`"`n"
        $galleryYaml += "   image_path: `"$imageThumbnailPath`"`n"
        $galleryYaml += "   alt: `"Image $count of $total`"`n"
        $galleryYaml += "   title: `"Image $count of $total`"`n"  
    }

    $galleryMarkdownFile = "_posts/$galleryName-launch-event.md"
    Write-Output "---`ntitle: $galleryName Album`ncategories:`n - launch`ntags:`n - pictures" | Out-File -FilePath $galleryMarkdownFile
    Write-Output $galleryYaml | Out-File -Append -FilePath $galleryMarkdownFile
    Write-Output "---`n" | Out-File -Append -FilePath $galleryMarkdownFile
    Write-Output "{% include gallery layout=`"third`" caption=`"$galleryName`" %}" | Out-File -Append -FilePath $galleryMarkdownFile

    # append to pictures.md
    Write-Output "## $galleryName `n`n[$galleryName Launch Event]({{ site.baseurl }}{% post_url $galleryName-launch-event %})`n`n" | Out-File -Append -FilePath "_pages/pictures.md"
}
