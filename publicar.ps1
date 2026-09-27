param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Mensaje
)

$ErrorActionPreference = "Stop"
$raiz = $PSScriptRoot
Set-Location -LiteralPath $raiz

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git no esta disponible en esta PC. No se publico nada."
}

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "1/4 Validando la configuracion Docker..."
    docker compose -f compose.yaml -f compose.local.yaml config --quiet

    Write-Host "2/4 Construyendo la misma imagen que usara Dokploy..."
    docker compose -f compose.yaml -f compose.local.yaml build
}
else {
    Write-Warning "Docker no esta instalado en esta PC. Dokploy validara y construira la imagen al recibirla."
}

Write-Host "3/4 Cambios que se enviarian:"
git status --short

$confirmacion = Read-Host "Escribi PUBLICAR para enviar estos cambios a produccion"
if ($confirmacion -cne "PUBLICAR") {
    Write-Host "Publicacion cancelada. No se creo ningun commit ni se envio nada."
    exit 0
}

git add --all
git commit -m $Mensaje

Write-Host "4/4 Enviando la rama main. Dokploy iniciara el despliegue automatico..."
git push origin main

Write-Host "Envio completado. Verifica el despliegue y el healthcheck en Dokploy."
