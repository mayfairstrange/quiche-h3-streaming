# Attempt to find Chrome SxS (Canary)
$chromePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome SxS\Application\chrome.exe",
    "$env:PROGRAMFILES\Google\Chrome\Application\chrome.exe",
    "$env:PROGRAMFILES(X86)\Google\Chrome\Application\chrome.exe"
)

$chrome = $chromePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $chrome) {
    Write-Host "Chrome not found. Please install Chrome Canary."
    exit 1
}

# Exact argument string, as in the working .bat file
$chromeArgs = '--origin-to-force-quic-on=localhost:4433 --host-resolver-rules="MAP localhost:4433 127.0.0.1:4433" --ignore-certificate-errors --ignore-certificate-errors-spki-list=MCFtYhgL/+T4kkcV64TQTTAw0Q5Gq2360530xEr9lFs= --ignore-urlfetcher-cert-requests --disable-proxy-certificate-handler --disable-test-root-certs --disable-content-security-policy --disable-web-security --allow-insecure-localhost --allow-running-insecure-content --disable_certificate_verification --allow_unknown_root_cert https://localhost:4433/test.html'

# Launch Chrome using raw string (not array)
Start-Process -FilePath $chrome -ArgumentList $chromeArgs
