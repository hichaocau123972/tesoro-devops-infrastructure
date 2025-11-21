#!/bin/bash
# health-check.sh
# Comprehensive health check script for Tesoro infrastructure

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="${1:-production}"
RESOURCE_GROUP="tesoro-${ENVIRONMENT}-rg"
APP_NAME="tesoro-${ENVIRONMENT}-app"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Tesoro Health Check - ${ENVIRONMENT}${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print test result
print_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"

    if [ "$result" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} ${test_name}: ${message}"
        ((PASSED++))
    elif [ "$result" -eq 2 ]; then
        echo -e "${YELLOW}⚠${NC} ${test_name}: ${message}"
        ((WARNINGS++))
    else
        echo -e "${RED}✗${NC} ${test_name}: ${message}"
        ((FAILED++))
    fi
}

# Check Azure CLI authentication
check_auth() {
    echo -e "${BLUE}Checking Azure authentication...${NC}"
    if az account show &>/dev/null; then
        local account=$(az account show --query "name" -o tsv)
        print_result "Authentication" 0 "Authenticated to: $account"
    else
        print_result "Authentication" 1 "Not authenticated to Azure"
        exit 1
    fi
    echo ""
}

# Check resource group
check_resource_group() {
    echo -e "${BLUE}Checking resource group...${NC}"
    if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
        local location=$(az group show --name "$RESOURCE_GROUP" --query "location" -o tsv)
        print_result "Resource Group" 0 "Exists in $location"
    else
        print_result "Resource Group" 1 "Resource group not found"
    fi
    echo ""
}

# Check App Service
check_app_service() {
    echo -e "${BLUE}Checking App Service...${NC}"

    # Get App Service name (includes suffix)
    local app_service=$(az webapp list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)

    if [ -z "$app_service" ]; then
        print_result "App Service" 1 "App Service not found"
        return
    fi

    # Check state
    local state=$(az webapp show --name "$app_service" --resource-group "$RESOURCE_GROUP" --query "state" -o tsv)
    if [ "$state" == "Running" ]; then
        print_result "App Service State" 0 "Running"
    else
        print_result "App Service State" 1 "State: $state"
    fi

    # Check availability state
    local avail_state=$(az webapp show --name "$app_service" --resource-group "$RESOURCE_GROUP" --query "availabilityState" -o tsv)
    if [ "$avail_state" == "Normal" ]; then
        print_result "App Service Availability" 0 "Normal"
    else
        print_result "App Service Availability" 1 "State: $avail_state"
    fi

    # Check HTTPS only
    local https_only=$(az webapp show --name "$app_service" --resource-group "$RESOURCE_GROUP" --query "httpsOnly" -o tsv)
    if [ "$https_only" == "true" ]; then
        print_result "HTTPS Only" 0 "Enabled"
    else
        print_result "HTTPS Only" 1 "Not enforced"
    fi

    echo ""
}

# Check health endpoint
check_health_endpoint() {
    echo -e "${BLUE}Checking health endpoint...${NC}"

    local app_service=$(az webapp list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)
    if [ -z "$app_service" ]; then
        print_result "Health Endpoint" 1 "App Service not found"
        return
    fi

    local url="https://${app_service}.azurewebsites.net/health"

    # Check HTTP status
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10)

    if [ "$http_code" -eq 200 ]; then
        print_result "Health Endpoint" 0 "HTTP $http_code - Healthy"
    elif [ "$http_code" -eq 503 ]; then
        print_result "Health Endpoint" 1 "HTTP $http_code - Service Unavailable"
    else
        print_result "Health Endpoint" 1 "HTTP $http_code"
    fi

    # Check response time
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" "$url" --max-time 10)
    if (( $(echo "$response_time < 1.0" | bc -l) )); then
        print_result "Response Time" 0 "${response_time}s"
    elif (( $(echo "$response_time < 3.0" | bc -l) )); then
        print_result "Response Time" 2 "${response_time}s (slow)"
    else
        print_result "Response Time" 1 "${response_time}s (very slow)"
    fi

    echo ""
}

# Check SQL Database
check_sql_database() {
    echo -e "${BLUE}Checking SQL Database...${NC}"

    local sql_server=$(az sql server list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)

    if [ -z "$sql_server" ]; then
        print_result "SQL Server" 1 "SQL Server not found"
        return
    fi

    print_result "SQL Server" 0 "Found: $sql_server"

    # Check database
    local database=$(az sql db list --server "$sql_server" --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv)
    if [ -n "$database" ]; then
        print_result "SQL Database" 0 "Found: $database"

        # Check database status
        local status=$(az sql db show --server "$sql_server" --name "$database" --resource-group "$RESOURCE_GROUP" --query "status" -o tsv)
        if [ "$status" == "Online" ]; then
            print_result "Database Status" 0 "Online"
        else
            print_result "Database Status" 1 "Status: $status"
        fi
    else
        print_result "SQL Database" 1 "No database found"
    fi

    echo ""
}

# Check Key Vault
check_key_vault() {
    echo -e "${BLUE}Checking Key Vault...${NC}"

    local key_vault=$(az keyvault list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)

    if [ -z "$key_vault" ]; then
        print_result "Key Vault" 1 "Key Vault not found"
        return
    fi

    print_result "Key Vault" 0 "Found: $key_vault"

    # Check soft delete
    local soft_delete=$(az keyvault show --name "$key_vault" --query "properties.enableSoftDelete" -o tsv)
    if [ "$soft_delete" == "true" ]; then
        print_result "Soft Delete" 0 "Enabled"
    else
        print_result "Soft Delete" 2 "Not enabled (recommended for production)"
    fi

    # Check purge protection
    local purge_protection=$(az keyvault show --name "$key_vault" --query "properties.enablePurgeProtection" -o tsv)
    if [ "$purge_protection" == "true" ]; then
        print_result "Purge Protection" 0 "Enabled"
    else
        if [ "$ENVIRONMENT" == "production" ]; then
            print_result "Purge Protection" 2 "Not enabled (recommended for production)"
        else
            print_result "Purge Protection" 0 "Not enabled (OK for non-prod)"
        fi
    fi

    echo ""
}

# Check Storage Account
check_storage() {
    echo -e "${BLUE}Checking Storage Account...${NC}"

    local storage=$(az storage account list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)

    if [ -z "$storage" ]; then
        print_result "Storage Account" 1 "Storage account not found"
        return
    fi

    print_result "Storage Account" 0 "Found: $storage"

    # Check HTTPS only
    local https_only=$(az storage account show --name "$storage" --query "enableHttpsTrafficOnly" -o tsv)
    if [ "$https_only" == "true" ]; then
        print_result "Storage HTTPS Only" 0 "Enabled"
    else
        print_result "Storage HTTPS Only" 1 "Not enforced"
    fi

    # Check minimum TLS version
    local min_tls=$(az storage account show --name "$storage" --query "minimumTlsVersion" -o tsv)
    if [ "$min_tls" == "TLS1_2" ]; then
        print_result "Minimum TLS Version" 0 "TLS 1.2"
    else
        print_result "Minimum TLS Version" 2 "Version: $min_tls (TLS 1.2 recommended)"
    fi

    echo ""
}

# Check Application Insights
check_app_insights() {
    echo -e "${BLUE}Checking Application Insights...${NC}"

    local app_insights=$(az monitor app-insights component show --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)

    if [ -z "$app_insights" ]; then
        print_result "Application Insights" 1 "Application Insights not found"
        return
    fi

    print_result "Application Insights" 0 "Found: $app_insights"

    # Check if data is flowing (requests in last hour)
    local request_count=$(az monitor app-insights metrics show \
        --app "$app_insights" \
        --resource-group "$RESOURCE_GROUP" \
        --metric "requests/count" \
        --start-time "$(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S')" \
        --interval PT1H \
        --aggregation count \
        --query "value.segments[0].sum" -o tsv 2>/dev/null || echo "0")

    if [ "$request_count" -gt 0 ]; then
        print_result "Telemetry Flow" 0 "$request_count requests in last hour"
    else
        print_result "Telemetry Flow" 2 "No requests in last hour"
    fi

    echo ""
}

# Check recent errors
check_recent_errors() {
    echo -e "${BLUE}Checking recent errors...${NC}"

    local app_insights=$(az monitor app-insights component show --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)

    if [ -z "$app_insights" ]; then
        print_result "Error Check" 2 "Cannot check - App Insights not found"
        return
    fi

    local error_count=$(az monitor app-insights metrics show \
        --app "$app_insights" \
        --resource-group "$RESOURCE_GROUP" \
        --metric "exceptions/count" \
        --start-time "$(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S')" \
        --interval PT1H \
        --aggregation count \
        --query "value.segments[0].sum" -o tsv 2>/dev/null || echo "0")

    if [ "$error_count" -eq 0 ]; then
        print_result "Recent Errors" 0 "No exceptions in last hour"
    elif [ "$error_count" -lt 10 ]; then
        print_result "Recent Errors" 2 "$error_count exceptions in last hour"
    else
        print_result "Recent Errors" 1 "$error_count exceptions in last hour"
    fi

    echo ""
}

# Main execution
check_auth
check_resource_group
check_app_service
check_health_endpoint
check_sql_database
check_key_vault
check_storage
check_app_insights
check_recent_errors

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Health Check Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

# Exit code
if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}Health check FAILED${NC}"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}Health check passed with warnings${NC}"
    exit 0
else
    echo -e "${GREEN}Health check PASSED${NC}"
    exit 0
fi
