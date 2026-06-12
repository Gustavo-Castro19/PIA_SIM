$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "../..")

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Arquivo .env criado a partir de .env.example"
}

docker compose up -d
Write-Host "PostgreSQL iniciado. Use 'docker compose ps' para verificar o status."
