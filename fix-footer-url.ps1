# ==========================================================
#  FIX FOOTER URL — Perbaiki URL yang kena prefix ../ salah
#  Hanya untuk file di subfolder (R-semester1, R-semester2, EP-semester2)
# ==========================================================

$rootPath = (Get-Location).Path
$q = [char]34

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  FIX FOOTER URL DI SUBFOLDER" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Hanya proses file di subfolder
$subfolders = @("R-semester1", "R-semester2", "EP-semester2")
$htmlFiles = @()

foreach ($folder in $subfolders) {
    $folderPath = Join-Path $rootPath $folder
    if (Test-Path $folderPath) {
        $htmlFiles += Get-ChildItem -Path $folderPath -Filter "*.html" -File
    }
}

Write-Host "Total file HTML di subfolder: $($htmlFiles.Count)" -ForegroundColor Yellow
Write-Host ""

$updated = 0
$failed = 0

foreach ($file in $htmlFiles) {
    $rel = $file.FullName.Replace($rootPath + "\", "")

    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction Stop

        # Perbaiki URL yang rusak
        # 1. src="../https://..." → src="https://..."
        $content = $content -replace 'src="\.\./(https?://)', 'src="$1'

        # 2. href="../https://..." → href="https://..."
        $content = $content -replace 'href="\.\./(https?://)', 'href="$1'

        # 3. href="../mailto:..." → href="mailto:..."
        $content = $content -replace 'href="\.\./(mailto:)', 'href="$1'

        # 4. href="../tel:..." → href="tel:..."
        $content = $content -replace 'href="\.\./(tel:)', 'href="$1'

        # 5. src="../data:..." → src="data:..."
        $content = $content -replace 'src="\.\./(data:)', 'src="$1'

        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
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
Write-Host "  Updated: $updated file" -ForegroundColor Green
Write-Host "  Failed:  $failed file" -ForegroundColor Red
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "Enter untuk menutup"