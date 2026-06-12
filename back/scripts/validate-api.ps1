$ErrorActionPreference = "Stop"

Write-Host "=== GET /api/v1/pia?risco=ALTO ==="
$list = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/pia?risco=ALTO&pagina=1&por_pagina=3"
Write-Host "Total ALTO: $($list.total)"

Write-Host "`n=== POST /api/v1/pia ==="
$postBody = @{
    descricaoAnonimizada = "Relato de fraude sem dados pessoais para validacao"
    tipoFraude = "PHISHING"
    titulo = "[VALIDACAO] Tentativa de phishing via e-mail"
} | ConvertTo-Json
try {
    $created = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/pia" -Method POST -Body $postBody -ContentType "application/json"
} catch {
    $resp = $_.Exception.Response
    if ($resp) {
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        Write-Host "POST erro $($resp.StatusCode): $($reader.ReadToEnd())"
    }
    throw
}
Write-Host "Criado id=$($created.id) status=$($created.status)"

Write-Host "`n=== PUT /api/v1/pia/$($created.id) ==="
$putBody = @{
    grauInteresse = "MEDIO"
    status = "SUSPEITO"
} | ConvertTo-Json
$updated = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/pia/$($created.id)" -Method PUT -Body $putBody -ContentType "application/json"
Write-Host "Atualizado grau=$($updated.grauInteresse) status=$($updated.status)"

Write-Host "`n=== GET /api/v1/pia/export ==="
$export = Invoke-WebRequest -Uri "http://localhost:8080/api/v1/pia/export" -UseBasicParsing -TimeoutSec 30
$lines = ($export.Content -split "`n").Count
Write-Host "CSV com $lines linhas (inclui cabecalho)"

Write-Host "`n=== DELETE /api/v1/pia/$($created.id) ==="
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/pia/$($created.id)" -Method DELETE
Write-Host "DELETE OK"

Write-Host "`n=== Auditoria pia_historico ==="
$hist = docker exec onac_pia_postgres psql -U onac -d onac_lista_pia -t -A -c "SELECT COUNT(*) FROM pia_historico WHERE pia_id = $($created.id);"
Write-Host "Registros em pia_historico para id $($created.id): $hist"

Write-Host "`nValidacao concluida com sucesso."
