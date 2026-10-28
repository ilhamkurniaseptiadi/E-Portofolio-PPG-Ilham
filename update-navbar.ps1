# ==========================================================
#  UPDATE NAVBAR v4 — Tanpa quote escaping
#  Semua quote char dibangun dari [char]34
# ==========================================================

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  UPDATE NAVBAR - ALL HTML FILES" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$rootPath = (Get-Location).Path
Write-Host "Project path: $rootPath" -ForegroundColor Yellow
Write-Host ""

# Baca navbar dari index.html
$indexFile = Join-Path $rootPath "index.html"

if (-not (Test-Path $indexFile)) {
    Write-Host "ERROR: index.html tidak ditemukan!" -ForegroundColor Red
    Read-Host "Tekan Enter untuk keluar"
    exit
}

$indexContent = Get-Content $indexFile -Raw

# Bangun start tag dari chars
$q = [char]34
$startTag = "<header class=" + $q + "navbar"
$endTag = "</header>"

$startIndex = $indexContent.IndexOf($startTag)
if ($startIndex -lt 0) {
    Write-Host "ERROR: Navbar tidak ditemukan di index.html" -ForegroundColor Red
    Read-Host "Tekan Enter untuk keluar"
    exit
}

$endIndex = $indexContent.IndexOf($endTag, $startIndex) + $endTag.Length
$rootNavbar = $indexContent.Substring($startIndex, $endIndex - $startIndex)

Write-Host "Navbar dibaca: $($rootNavbar.Length) karakter" -ForegroundColor Green
Write-Host ""

# Scan semua HTML
$files = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse -File
Write-Host "Total file HTML: $($files.Count)" -ForegroundColor Yellow
Write-Host ""

$updated = 0
$skipped = 0
$failed = 0

foreach ($file in $files) {
    $rel = $file.FullName.Replace($rootPath + "\", "")
    
    # Skip rules
    if ($rel -eq "index.html") {
        Write-Host "  [SKIP] $rel" -ForegroundColor DarkGray
        $skipped++
        continue
    }
    if ($rel -like "*backup*" -or $rel -like "*COBA*" -or $rel -like "*.vscode*") {
        Write-Host "  [SKIP] $rel" -ForegroundColor DarkGray
        $skipped++
        continue
    }
    
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction Stop
        
        $fileStart = $content.IndexOf($startTag)
        if ($fileStart -lt 0) {
            Write-Host "  [WARN] $rel - tidak ada navbar" -ForegroundColor Yellow
            continue
        }
        $fileEnd = $content.IndexOf($endTag, $fileStart) + $endTag.Length
        
        $navbar = $rootNavbar
        $depth = ($rel.Split("\").Count) - 1
        
        if ($depth -gt 0) {
            $prefix = "../" * $depth
            
            # Bangun string search/replace menggunakan char
            $oldHref = "href=" + $q
            $newHref = "href=" + $q + $prefix
            
            $oldSrc = "src=" + $q
            $newSrc = "src=" + $q + $prefix
            
            $navbar = $navbar.Replace($oldHref, $newHref)
            $navbar = $navbar.Replace($oldSrc, $newSrc)
        }
        
        $newContent = $content.Substring(0, $fileStart) + $navbar + $content.Substring($fileEnd)
        Set-Content -Path $file.FullName -Value $newContent -NoNewline -Encoding UTF8
        
        Write-Host "  [OK]   $rel" -ForegroundColor Green
        $updated++
    }
    catch {
        Write-Host "  [FAIL] $rel - $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host " SELESAI!" -ForegroundColor Green
Write-Host "  Updated: $updated" -ForegroundColor Green
Write-Host "  Skipped: $skipped" -ForegroundColor DarkGray
Write-Host "  Failed:  $failed" -ForegroundColor Red
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

Read-Host "Tekan Enter untuk menutup"