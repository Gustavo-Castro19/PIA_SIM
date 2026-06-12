$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "../..")

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Arquivo .env criado a partir de .env.example"
}

$envContent = Get-Content ".env" | Where-Object { $_ -match '^\s*[^#]' }
$vars = @{}
foreach ($line in $envContent) {
    if ($line -match '^([^=]+)=(.*)$') {
        $vars[$Matches[1].Trim()] = $Matches[2].Trim()
    }
}

$db = $vars['POSTGRES_DB']
$user = $vars['POSTGRES_USER']
$password = $vars['POSTGRES_PASSWORD']

if (-not $db -or -not $user -or -not $password) {
    throw "Variaveis POSTGRES_DB, POSTGRES_USER e POSTGRES_PASSWORD sao obrigatorias no .env"
}

$seedFile = Join-Path $PSScriptRoot "../database/seeds/dev_seed.sql"
if (-not (Test-Path $seedFile)) {
    throw "Arquivo de seed nao encontrado: $seedFile"
}

Write-Host "Aplicando seed de desenvolvimento em $db..."
$output = Get-Content $seedFile -Raw | docker exec -i onac_pia_postgres psql -U $user -d $db -v ON_ERROR_STOP=1 2>&1
$output | Write-Host
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao aplicar seed (exit code $LASTEXITCODE)"
}
Write-Host "Seed aplicado com sucesso."
