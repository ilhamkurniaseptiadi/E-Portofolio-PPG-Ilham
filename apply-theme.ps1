# ============================================
# Tech-Theme Batch Apply
# ============================================

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  TECH THEME APPLY - 21 HTML FILES" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# === EDIT PATH DI BAWAH INI ===
$projectRoot = "C:\Users\acer\OneDrive\Documents\PPG CG 2026\E - Portoflio\e-porto ilham"
# ==============================

Write-Host "Path target: $projectRoot" -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path $projectRoot)) {
    Write-Host "X Folder TIDAK ditemukan!" -ForegroundColor Red
    Write-Host "  Cek path, pastikan folder e-porto20ilham ada." -ForegroundColor Red
    Write-Host ""
    Read-Host "Tekan Enter untuk keluar"
    exit
}

Set-Location $projectRoot

$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse -File
Write-Host "Ditemukan $($htmlFiles.Count) file HTML" -ForegroundColor Yellow
Write-Host ""

$updated = 0
$skipped = 0
$failed = 0

foreach ($file in $htmlFiles) {
    $relativePath = $file.FullName.Replace($projectRoot + "\", "")
    $depth = ($relativePath.Split("\").Count) - 1
    $cssPath = if ($depth -eq 0) { "CSS/tech-theme.css" } else { "../CSS/tech-theme.css" }
    
    $lines = Get-Content $file.FullName -ErrorAction SilentlyContinue
    if (-not $lines) { continue }
    
    $hasTech = $false
    foreach ($line in $lines) {
        if ($line -match 'tech-theme\.css') { $hasTech = $true; break }
    }
    
    if ($hasTech) {
        Write-Host "  [SKIP] $relativePath" -ForegroundColor DarkGray
        $skipped++
        continue
    }
    
    $newLines = @()
    $techAdded = $false
    
    foreach ($line in $lines) {
        if ($line -match 'family=Poppins') {
            $line = '    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />'
        }
        
        $newLines += $line
        
        if (-not $techAdded -and $line -match 'rel="stylesheet"\s+href="(?:\.\./)?CSS/[^"]+\.css"') {
            $newLines += "    <link rel=`"stylesheet`" href=`"$cssPath`" />"
            $techAdded = $true
        }
    }
    
    try {
        Set-Content -Path $file.FullName -Value $newLines -Encoding UTF8
        Write-Host "  [OK]   $relativePath" -ForegroundColor Green
        $updated++
    } catch {
        Write-Host "  [FAIL] $relativePath" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "SELESAI!" -ForegroundColor Green
Write-Host "  OK      : $updated file" -ForegroundColor Green
Write-Host "  Skipped : $skipped file" -ForegroundColor DarkGray
Write-Host "  Failed  : $failed file" -ForegroundColor Red
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "Tekan Enter untuk menutup"