$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "../..")

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Arquivo .env criado a partir de .env.example"
}

Write-Host "Removendo containers e volume onac_pia_data (reexecuta scripts de init na proxima subida)..."
docker compose down -v
docker compose up -d
Write-Host "Banco recriado. Scripts em back/database/init/ serao aplicados na primeira inicializacao do volume."
