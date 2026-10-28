$rootPath = (Get-Location).Path
$q = [char]34
$oldPattern = 'class=' + $q + 'nav-link active' + $q + '>Beranda'
$newPattern = 'class=' + $q + 'nav-link' + $q + '>Beranda'

$files = Get-ChildItem -Path $rootPath -Filter '*.html' -Recurse -File
Write-Host 'Total file: ' + $files.Count
Write-Host ''

$fixed = 0

foreach ($file in $files) {
    $rel = $file.FullName.Replace($rootPath + '\', '')
    
    if ($rel -eq 'index.html') { continue }
    if ($rel -like '*backup*') { continue }
    if ($rel -like '*COBA*') { continue }
    
    $content = Get-Content $file.FullName -Raw
    if ($content -and $content.Contains($oldPattern)) {
        $content = $content.Replace($oldPattern, $newPattern)
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        Write-Host 'OK: ' + $rel
        $fixed = $fixed + 1
    }
    else {
        Write-Host 'SKIP: ' + $rel
    }
}

Write-Host ''
Write-Host 'Fixed: ' + $fixed + ' file'
Write-Host ''
Read-Host 'Tekan Enter untuk menutup'