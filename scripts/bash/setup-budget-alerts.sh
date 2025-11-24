#!/bin/bash
# Setup Budget Alerts for Azure Subscription
# This script creates budget alerts to prevent unexpected costs

set -e

echo "🔔 Setting up budget alerts for your Azure subscription..."

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"

# Budget configuration
BUDGET_NAME="tesoro-monthly-budget"
BUDGET_AMOUNT=100  # $100/month limit
WARNING_THRESHOLD_1=50  # Alert at 50% ($50)
WARNING_THRESHOLD_2=75  # Alert at 75% ($75)
CRITICAL_THRESHOLD=90   # Alert at 90% ($90)

# Get your email for alerts
echo ""
echo "Enter your email address for budget alerts:"
read -p "Email: " USER_EMAIL

if [ -z "$USER_EMAIL" ]; then
    echo "❌ Email is required for budget alerts"
    exit 1
fi

echo ""
echo "📊 Budget Configuration:"
echo "  Monthly Budget: \$$BUDGET_AMOUNT"
echo "  Alerts at: 50% (\$50), 75% (\$75), 90% (\$90)"
echo "  Email: $USER_EMAIL"
echo ""

# Create action group for email notifications
echo "Creating action group for email notifications..."

ACTION_GROUP_NAME="budget-alert-email"
ACTION_GROUP_SHORT_NAME="BudgetAlert"

az monitor action-group create \
  --name "$ACTION_GROUP_NAME" \
  --resource-group "tesoro-dev-rg" \
  --short-name "$ACTION_GROUP_SHORT_NAME" \
  --action email budget-admin "$USER_EMAIL" \
  --output none 2>/dev/null || echo "Action group may already exist, continuing..."

ACTION_GROUP_ID=$(az monitor action-group show \
  --name "$ACTION_GROUP_NAME" \
  --resource-group "tesoro-dev-rg" \
  --query id -o tsv)

echo "✅ Action group created: $ACTION_GROUP_ID"

# Note: Budget creation via CLI requires specific API version
# Creating budget using REST API through az rest

echo ""
echo "Creating monthly budget with multiple thresholds..."

# Budget start and end dates
START_DATE=$(date -u +"%Y-%m-01T00:00:00Z")
# End date: 5 years from now
END_DATE=$(date -u -v+5y +"%Y-%m-01T00:00:00Z" 2>/dev/null || date -u -d "+5 years" +"%Y-%m-01T00:00:00Z")

# Create budget JSON
BUDGET_JSON=$(cat <<EOF
{
  "properties": {
    "category": "Cost",
    "amount": $BUDGET_AMOUNT,
    "timeGrain": "Monthly",
    "timePeriod": {
      "startDate": "$START_DATE",
      "endDate": "$END_DATE"
    },
    "notifications": {
      "Actual_GreaterThan_50_Percent": {
        "enabled": true,
        "operator": "GreaterThan",
        "threshold": $WARNING_THRESHOLD_1,
        "contactEmails": [
          "$USER_EMAIL"
        ],
        "thresholdType": "Actual"
      },
      "Actual_GreaterThan_75_Percent": {
        "enabled": true,
        "operator": "GreaterThan",
        "threshold": $WARNING_THRESHOLD_2,
        "contactEmails": [
          "$USER_EMAIL"
        ],
        "thresholdType": "Actual"
      },
      "Actual_GreaterThan_90_Percent": {
        "enabled": true,
        "operator": "GreaterThan",
        "threshold": $CRITICAL_THRESHOLD,
        "contactEmails": [
          "$USER_EMAIL"
        ],
        "thresholdType": "Actual"
      },
      "Forecasted_GreaterThan_100_Percent": {
        "enabled": true,
        "operator": "GreaterThan",
        "threshold": 100,
        "contactEmails": [
          "$USER_EMAIL"
        ],
        "thresholdType": "Forecasted"
      }
    }
  }
}
EOF
)

# Create the budget using REST API
az rest \
  --method put \
  --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Consumption/budgets/$BUDGET_NAME?api-version=2023-11-01" \
  --body "$BUDGET_JSON" \
  --output none

echo "✅ Budget created successfully!"
echo ""
echo "📧 You will receive email alerts when spending reaches:"
echo "   • 50% (\$50) - Warning"
echo "   • 75% (\$75) - Warning"
echo "   • 90% (\$90) - Critical"
echo "   • 100% (\$100) - Forecasted (prediction)"
echo ""
echo "💡 View your budget in Azure Portal:"
echo "   Cost Management + Billing → Budgets → $BUDGET_NAME"
echo ""
echo "✅ Budget alerts setup complete!"
