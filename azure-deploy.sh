#!/bin/bash

# Simplified Azure deployment script
# This script builds locally and deploys to Azure Static Web Apps

set -e

echo "🚀 Azure Static Web Apps Deployment"

# Configuration
RESOURCE_GROUP="Kunaal"
APP_NAME="tigest-voice-ai-landing"
LOCATION="southindia"

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

# Step 2: Check if Static Web App exists
echo -e "${GREEN}✓${NC} Checking if Static Web App exists..."
APP_EXISTS=$(az staticwebapp list --resource-group "$RESOURCE_GROUP" --query "[?name=='$APP_NAME'].name" -o tsv 2>/dev/null || echo "")

if [ -z "$APP_EXISTS" ]; then
    echo -e "${YELLOW}⚠️  Creating Static Web App...${NC}"
    az staticwebapp create \
        --name "$APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Free \
        --output none
    echo -e "${GREEN}✅ Static Web App created!${NC}"
else
    echo -e "${GREEN}✅ Static Web App exists${NC}"
fi

# Step 3: Build project
echo -e "${GREEN}✓${NC} Building project..."
if [ ! -f .env.local ]; then
    echo -e "${YELLOW}⚠️  .env.local not found. Building without env vars (will use defaults)${NC}"
fi

npm run build

if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful${NC}"

# Step 4: Get deployment token
echo -e "${GREEN}✓${NC} Getting deployment token..."
DEPLOYMENT_TOKEN=$(az staticwebapp secrets list \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "properties.apiKey" \
    -o tsv 2>/dev/null || echo "")

if [ -z "$DEPLOYMENT_TOKEN" ]; then
    echo -e "${RED}❌ Could not get deployment token${NC}"
    echo -e "${YELLOW}   Get it manually from Azure Portal:${NC}"
    echo -e "${YELLOW}   Static Web Apps > $APP_NAME > Manage deployment token${NC}"
    exit 1
fi

# Step 5: Install SWA CLI if needed
if ! command -v swa &> /dev/null; then
    echo -e "${YELLOW}⚠️  Installing SWA CLI...${NC}"
    npm install -g @azure/static-web-apps-cli
fi

# Step 6: Deploy
echo -e "${GREEN}✓${NC} Deploying to Azure..."
swa deploy ./dist \
    --deployment-token "$DEPLOYMENT_TOKEN" \
    --env production

# Step 7: Get URL
APP_URL=$(az staticwebapp show \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "defaultHostname" \
    -o tsv 2>/dev/null || echo "")

echo ""
echo -e "${GREEN}🎉 Deployment complete!${NC}"
if [ ! -z "$APP_URL" ]; then
    echo -e "${GREEN}🌐 Your app is live at: https://$APP_URL${NC}"
fi
echo ""
echo -e "${YELLOW}💡 Remember to set environment variables in Azure Portal if needed:${NC}"
echo -e "${YELLOW}   Static Web Apps > $APP_NAME > Configuration > Application settings${NC}"

