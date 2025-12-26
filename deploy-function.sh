#!/bin/bash

# Deploy Azure Function for Gemini API Key Proxy
# This script creates and deploys the Azure Function that retrieves API keys from Key Vault

set -e

echo "🚀 Deploying Azure Function for Gemini API Key Proxy"

# Configuration
RESOURCE_GROUP="Kunaal"
FUNCTION_APP_NAME="tigest-voice-ai-api"
LOCATION="southindia"  # Function Apps support more regions
KEY_VAULT_NAME="tigest-voice-ai-kv"
STORAGE_ACCOUNT_NAME="tigestvoiceaistorage$(openssl rand -hex 4 | tr '[:upper:]' '[:lower:]')"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Step 1: Verify prerequisites
echo -e "${GREEN}✓${NC} Checking prerequisites..."

if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found${NC}"
    exit 1
fi

if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Logging in to Azure...${NC}"
    az login
fi

# Step 2: Create Storage Account (required for Function App)
echo -e "${GREEN}✓${NC} Creating storage account..."
STORAGE_EXISTS=$(az storage account list --resource-group "$RESOURCE_GROUP" --query "[?name=='$STORAGE_ACCOUNT_NAME'].name" -o tsv 2>/dev/null || echo "")

if [ -z "$STORAGE_EXISTS" ]; then
    az storage account create \
        --name "$STORAGE_ACCOUNT_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --output none
    echo -e "${GREEN}✅ Storage account created${NC}"
else
    echo -e "${GREEN}✅ Storage account exists${NC}"
fi

# Step 3: Create Function App
echo -e "${GREEN}✓${NC} Creating Function App..."
FUNCTION_EXISTS=$(az functionapp list --resource-group "$RESOURCE_GROUP" --query "[?name=='$FUNCTION_APP_NAME'].name" -o tsv 2>/dev/null || echo "")

if [ -z "$FUNCTION_EXISTS" ]; then
    # Get storage connection string
    STORAGE_CONNECTION=$(az storage account show-connection-string \
        --name "$STORAGE_ACCOUNT_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query connectionString \
        -o tsv)

    az functionapp create \
        --name "$FUNCTION_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --storage-account "$STORAGE_ACCOUNT_NAME" \
        --consumption-plan-location "$LOCATION" \
        --runtime "node" \
        --runtime-version "20" \
        --functions-version "4" \
        --output none

    echo -e "${GREEN}✅ Function App created${NC}"
else
    echo -e "${GREEN}✅ Function App exists${NC}"
fi

# Step 4: Configure Function App settings
echo -e "${GREEN}✓${NC} Configuring Function App settings..."

az functionapp config appsettings set \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
        "KEY_VAULT_NAME=$KEY_VAULT_NAME" \
        "ALLOWED_ORIGIN=https://tigest.club" \
    --output none

# Step 5: Grant Function App access to Key Vault
echo -e "${GREEN}✓${NC} Granting Key Vault access to Function App..."

FUNCTION_PRINCIPAL_ID=$(az functionapp identity show \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query principalId \
    -o tsv 2>/dev/null || echo "")

if [ -z "$FUNCTION_PRINCIPAL_ID" ]; then
    # Enable managed identity
    az functionapp identity assign \
        --name "$FUNCTION_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --output none
    
    FUNCTION_PRINCIPAL_ID=$(az functionapp identity show \
        --name "$FUNCTION_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query principalId \
        -o tsv)
fi

# Grant Key Vault access
az role assignment create \
    --role "Key Vault Secrets User" \
    --assignee "$FUNCTION_PRINCIPAL_ID" \
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME" \
    --output none 2>/dev/null || echo "Role assignment may already exist"

echo -e "${GREEN}✅ Key Vault access granted${NC}"

# Step 6: Build and deploy function
echo -e "${GREEN}✓${NC} Building and deploying function..."

cd api

if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}⚠️  Installing dependencies...${NC}"
    npm install
fi

echo -e "${YELLOW}⚠️  Building TypeScript...${NC}"
npm run build

# Deploy using Azure Functions Core Tools or zip deploy
if command -v func &> /dev/null; then
    echo -e "${YELLOW}⚠️  Deploying using Functions Core Tools...${NC}"
    func azure functionapp publish "$FUNCTION_APP_NAME"
else
    echo -e "${YELLOW}⚠️  Functions Core Tools not found. Using zip deploy...${NC}"
    # Create deployment package
    zip -r function-app.zip . -x "node_modules/*" "*.zip"
    
    # Deploy
    az functionapp deployment source config-zip \
        --resource-group "$RESOURCE_GROUP" \
        --name "$FUNCTION_APP_NAME" \
        --src function-app.zip \
        --output none
    
    rm function-app.zip
fi

cd ..

# Step 7: Get function URL
FUNCTION_URL=$(az functionapp show \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query defaultHostName \
    -o tsv)

FUNCTION_KEY=$(az functionapp keys list \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "functionKeys.default" \
    -o tsv)

FULL_URL="https://${FUNCTION_URL}/api/gemini-proxy?code=${FUNCTION_KEY}"

echo ""
echo -e "${GREEN}🎉 Function deployed successfully!${NC}"
echo -e "${GREEN}🌐 Function URL: https://${FUNCTION_URL}/api/gemini-proxy${NC}"
echo ""
echo -e "${YELLOW}💡 Add this to your .env.local:${NC}"
echo -e "${YELLOW}   GEMINI_API_KEY_URL=${FULL_URL}${NC}"
echo ""

