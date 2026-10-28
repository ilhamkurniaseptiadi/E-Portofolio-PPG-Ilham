# ==========================================================
#  UPDATE FOOTER — Sebar Footer Baru ke Semua HTML
#  E-Portofolio Ilham Kurnia Septiadi
# ==========================================================

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  UPDATE FOOTER - ALL HTML FILES" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$rootPath = (Get-Location).Path
Write-Host "Project path: $rootPath" -ForegroundColor Yellow
Write-Host ""

# ---------- 1. Baca footer dari index.html ----------
$indexFile = Join-Path $rootPath "index.html"

if (-not (Test-Path $indexFile)) {
    Write-Host "X index.html tidak ditemukan!" -ForegroundColor Red
    Read-Host "Tekan Enter untuk keluar"
    exit
}

$indexContent = Get-Content $indexFile -Raw

$q = [char]34
$startTag = "<footer class=" + $q + "site-footer" + $q
$endTag = "</footer>"

$startIndex = $indexContent.IndexOf($startTag)
if ($startIndex -lt 0) {
    Write-Host "X Footer tidak ditemukan di index.html" -ForegroundColor Red
    Read-Host "Tekan Enter untuk keluar"
    exit
}

$endIndex = $indexContent.IndexOf($endTag, $startIndex) + $endTag.Length
$rootFooter = $indexContent.Substring($startIndex, $endIndex - $startIndex)

Write-Host "Footer dibaca: $($rootFooter.Length) karakter" -ForegroundColor Green
Write-Host ""

# ---------- 2. Scan semua HTML ----------
$htmlFiles = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse -File
Write-Host "Total file HTML: $($htmlFiles.Count)" -ForegroundColor Yellow
Write-Host ""

$updated = 0
$skipped = 0
$failed = 0

foreach ($file in $htmlFiles) {
    $rel = $file.FullName.Replace($rootPath + "\", "")

    # Skip index.html
    if ($rel -eq "index.html") {
        Write-Host "  [SKIP] $rel (index.html)" -ForegroundColor DarkGray
        $skipped++
        continue
    }

    # Skip backup/dummy
    if ($rel -like "*backup*" -or $rel -like "*COBA*" -or $rel -like "*.vscode*") {
        Write-Host "  [SKIP] $rel (backup/dummy)" -ForegroundColor DarkGray
        $skipped++
        continue
    }

    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction Stop

        $fileStart = $content.IndexOf($startTag)
        if ($fileStart -lt 0) {
            Write-Host "  [WARN] $rel - tidak ada footer" -ForegroundColor Yellow
            continue
        }

        $fileEnd = $content.IndexOf($endTag, $fileStart) + $endTag.Length

        $footer = $rootFooter
        $depth = ($rel.Split("\").Count) - 1

        if ($depth -gt 0) {
            $prefix = "../" * $depth

            # Bangun string search/replace menggunakan char
            $oldHref = "href=" + $q
            $newHref = "href=" + $q + $prefix

            $oldSrc = "src=" + $q
            $newSrc = "src=" + $q + $prefix

            $footer = $footer.Replace($oldHref, $newHref)
            $footer = $footer.Replace($oldSrc, $newSrc)
        }

        $newContent = $content.Substring(0, $fileStart) + $footer + $content.Substring($fileEnd)
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
Write-Host "  Updated : $updated file" -ForegroundColor Green
Write-Host "  Skipped : $skipped file" -ForegroundColor DarkGray
Write-Host "  Failed  : $failed file" -ForegroundColor Red
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

Read-Host "Tekan Enter untuk menutup"