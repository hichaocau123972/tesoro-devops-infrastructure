# Deploy-Infrastructure.ps1
# PowerShell script to deploy Tesoro infrastructure to Azure

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev', 'staging', 'production')]
    [string]$Environment,

    [Parameter(Mandatory=$false)]
    [string]$Location = 'eastus',

    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Script variables
$AppName = 'tesoro'
$DeploymentName = "$AppName-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$TemplateFile = "$PSScriptRoot/../../infrastructure/bicep/main.bicep"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tesoro Infrastructure Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Location: $Location" -ForegroundColor Yellow
Write-Host "Deployment: $DeploymentName" -ForegroundColor Yellow
Write-Host ""

# Function to check prerequisites
function Test-Prerequisites {
    Write-Host "Checking prerequisites..." -ForegroundColor Cyan

    # Check Azure CLI
    try {
        $azVersion = az version --output json | ConvertFrom-Json
        Write-Host "✓ Azure CLI installed: $($azVersion.'azure-cli')" -ForegroundColor Green
    }
    catch {
        Write-Error "Azure CLI not found. Please install: https://aka.ms/installazurecli"
        exit 1
    }

    # Check Bicep
    try {
        az bicep version
        Write-Host "✓ Bicep installed" -ForegroundColor Green
    }
    catch {
        Write-Error "Bicep not found. Installing..."
        az bicep install
    }

    # Check template file exists
    if (-not (Test-Path $TemplateFile)) {
        Write-Error "Template file not found: $TemplateFile"
        exit 1
    }
    Write-Host "✓ Template file found" -ForegroundColor Green

    Write-Host ""
}

# Function to login to Azure
function Connect-AzureAccount {
    Write-Host "Checking Azure authentication..." -ForegroundColor Cyan

    try {
        $account = az account show --output json | ConvertFrom-Json
        Write-Host "✓ Authenticated as: $($account.user.name)" -ForegroundColor Green
        Write-Host "✓ Subscription: $($account.name)" -ForegroundColor Green

        if ($SubscriptionId -and $account.id -ne $SubscriptionId) {
            Write-Host "Switching to subscription: $SubscriptionId" -ForegroundColor Yellow
            az account set --subscription $SubscriptionId
        }
    }
    catch {
        Write-Host "Not authenticated. Logging in..." -ForegroundColor Yellow
        az login

        if ($SubscriptionId) {
            az account set --subscription $SubscriptionId
        }
    }

    Write-Host ""
}

# Function to validate template
function Test-BicepTemplate {
    Write-Host "Validating Bicep template..." -ForegroundColor Cyan

    try {
        az bicep build --file $TemplateFile
        Write-Host "✓ Template validation passed" -ForegroundColor Green
    }
    catch {
        Write-Error "Template validation failed: $_"
        exit 1
    }

    Write-Host ""
}

# Function to run what-if analysis
function Invoke-WhatIfAnalysis {
    Write-Host "Running What-If analysis..." -ForegroundColor Cyan
    Write-Host "(This shows what changes will be made without actually deploying)" -ForegroundColor Gray
    Write-Host ""

    $whatIfResult = az deployment sub what-if `
        --location $Location `
        --template-file $TemplateFile `
        --parameters environment=$Environment location=$Location appName=$AppName `
        --output json | ConvertFrom-Json

    # Display results
    Write-Host "Changes that will be deployed:" -ForegroundColor Yellow
    az deployment sub what-if `
        --location $Location `
        --template-file $TemplateFile `
        --parameters environment=$Environment location=$Location appName=$AppName

    Write-Host ""
}

# Function to deploy infrastructure
function Deploy-AzureInfrastructure {
    Write-Host "Deploying infrastructure..." -ForegroundColor Cyan
    Write-Host "Deployment name: $DeploymentName" -ForegroundColor Gray
    Write-Host ""

    try {
        az deployment sub create `
            --name $DeploymentName `
            --location $Location `
            --template-file $TemplateFile `
            --parameters environment=$Environment location=$Location appName=$AppName `
            --output json | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Out-File -FilePath "deployment-output-$Environment.json"

        Write-Host "✓ Deployment completed successfully" -ForegroundColor Green

        # Display outputs
        $deployment = Get-Content "deployment-output-$Environment.json" | ConvertFrom-Json

        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Deployment Outputs" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan

        if ($deployment.properties.outputs) {
            $deployment.properties.outputs.PSObject.Properties | ForEach-Object {
                Write-Host "$($_.Name): $($_.Value.value)" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Error "Deployment failed: $_"

        # Show deployment errors
        az deployment sub show `
            --name $DeploymentName `
            --query "properties.error" `
            --output json

        exit 1
    }

    Write-Host ""
}

# Function to verify deployment
function Test-Deployment {
    param(
        [string]$ResourceGroupName
    )

    Write-Host "Verifying deployment..." -ForegroundColor Cyan

    try {
        # Check resource group
        $rg = az group show --name $ResourceGroupName --output json | ConvertFrom-Json
        Write-Host "✓ Resource group exists: $($rg.name)" -ForegroundColor Green

        # List resources
        Write-Host ""
        Write-Host "Deployed resources:" -ForegroundColor Yellow
        az resource list --resource-group $ResourceGroupName --output table

        Write-Host ""
        Write-Host "✓ Deployment verification completed" -ForegroundColor Green
    }
    catch {
        Write-Warning "Verification failed: $_"
    }

    Write-Host ""
}

# Main execution
try {
    # Run prerequisite checks
    Test-Prerequisites

    # Connect to Azure
    Connect-AzureAccount

    # Validate template
    Test-BicepTemplate

    # Run what-if analysis
    Invoke-WhatIfAnalysis

    if ($WhatIf) {
        Write-Host "WhatIf mode - No changes were made" -ForegroundColor Yellow
        exit 0
    }

    # Confirm deployment
    if ($Environment -eq 'production') {
        Write-Host "⚠️  WARNING: You are about to deploy to PRODUCTION" -ForegroundColor Red
        $confirm = Read-Host "Type 'DEPLOY' to continue"

        if ($confirm -ne 'DEPLOY') {
            Write-Host "Deployment cancelled" -ForegroundColor Yellow
            exit 0
        }
    }

    # Deploy infrastructure
    Deploy-AzureInfrastructure

    # Verify deployment
    $rgName = "$AppName-$Environment-rg"
    Test-Deployment -ResourceGroupName $rgName

    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Deployment completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Review deployment outputs above" -ForegroundColor White
    Write-Host "2. Update Key Vault secrets" -ForegroundColor White
    Write-Host "3. Deploy application code" -ForegroundColor White
    Write-Host "4. Run smoke tests" -ForegroundColor White
    Write-Host ""
}
catch {
    Write-Error "Deployment script failed: $_"
    exit 1
}
