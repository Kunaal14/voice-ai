#!/bin/bash

# Deployment script for Tigest Voice AI Landing Page
# This script builds and deploys to Azure Static Web Apps

set -e  # Exit on error

echo "🚀 Starting deployment to Azure..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration - Update these values
RESOURCE_GROUP="Kunaal"
STATIC_WEB_APP_NAME="tigest-voice-ai-landing"
LOCATION="southindia"  # Match your existing resources

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure. Logging in...${NC}"
    az login
fi

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo -e "${YELLOW}⚠️  .env.local not found. Creating from .env.example...${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env.local
        echo -e "${YELLOW}⚠️  Please update .env.local with your actual values before deploying!${NC}"
        exit 1
    else
        echo -e "${RED}❌ .env.example not found. Cannot proceed.${NC}"
        exit 1
    fi
fi

# Check if environment variables are set for build
echo -e "${GREEN}🔍 Checking environment variables...${NC}"
if [ ! -f .env.local ]; then
    echo -e "${RED}❌ .env.local not found!${NC}"
    echo -e "${YELLOW}   For local builds, create .env.local from .env.example${NC}"
    echo -e "${YELLOW}   For Azure deployment, set environment variables in Azure Portal${NC}"
    exit 1
fi

# Build the project
echo -e "${GREEN}📦 Building project...${NC}"
npm run build

if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Build failed. dist folder not found.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# Check if Static Web App exists
echo -e "${GREEN}🔍 Checking if Static Web App exists...${NC}"
STATIC_APP_EXISTS=$(az staticwebapp list --resource-group "$RESOURCE_GROUP" --query "[?name=='$STATIC_WEB_APP_NAME'].name" -o tsv 2>/dev/null || echo "")

if [ -z "$STATIC_APP_EXISTS" ]; then
    echo -e "${YELLOW}⚠️  Static Web App '$STATIC_WEB_APP_NAME' not found. Creating it...${NC}"
    
    # Create Static Web App
    az staticwebapp create \
        --name "$STATIC_WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Free \
        --output none
    
    echo -e "${GREEN}✅ Static Web App created!${NC}"
    
    # Get deployment token
    echo -e "${GREEN}🔑 Getting deployment token...${NC}"
    DEPLOYMENT_TOKEN=$(az staticwebapp secrets list --name "$STATIC_WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "properties.apiKey" -o tsv)
    
    if [ -z "$DEPLOYMENT_TOKEN" ]; then
        echo -e "${YELLOW}⚠️  Could not get deployment token automatically.${NC}"
        echo -e "${YELLOW}   Please get it manually from Azure Portal and set it in .env.local as STATIC_WEB_APP_DEPLOYMENT_TOKEN${NC}"
    else
        echo -e "${GREEN}✅ Deployment token retrieved.${NC}"
        echo -e "${YELLOW}💡 Save this token: $DEPLOYMENT_TOKEN${NC}"
    fi
else
    echo -e "${GREEN}✅ Static Web App '$STATIC_WEB_APP_NAME' exists.${NC}"
fi

# Deploy using Azure Static Web Apps CLI or direct upload
echo -e "${GREEN}📤 Deploying to Azure...${NC}"

# Check if deployment token is set
if [ -z "$STATIC_WEB_APP_DEPLOYMENT_TOKEN" ]; then
    # Try to get from .env.local
    if grep -q "STATIC_WEB_APP_DEPLOYMENT_TOKEN" .env.local 2>/dev/null; then
        export STATIC_WEB_APP_DEPLOYMENT_TOKEN=$(grep "STATIC_WEB_APP_DEPLOYMENT_TOKEN" .env.local | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    fi
fi

if [ -z "$STATIC_WEB_APP_DEPLOYMENT_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  Deployment token not found.${NC}"
    echo -e "${YELLOW}   Getting deployment token from Azure...${NC}"
    
    # Get deployment token
    DEPLOYMENT_TOKEN=$(az staticwebapp secrets list --name "$STATIC_WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "properties.apiKey" -o tsv 2>/dev/null || echo "")
    
    if [ -z "$DEPLOYMENT_TOKEN" ]; then
        echo -e "${RED}❌ Could not get deployment token.${NC}"
        echo -e "${YELLOW}   Please get it from Azure Portal:${NC}"
        echo -e "${YELLOW}   1. Go to Azure Portal > Static Web Apps > $STATIC_WEB_APP_NAME > Manage deployment token${NC}"
        echo -e "${YELLOW}   2. Copy the token and add it to .env.local as: STATIC_WEB_APP_DEPLOYMENT_TOKEN=your_token${NC}"
        exit 1
    else
        export STATIC_WEB_APP_DEPLOYMENT_TOKEN="$DEPLOYMENT_TOKEN"
    fi
fi

# Deploy using swa CLI if available, otherwise use REST API
if command -v swa &> /dev/null; then
    echo -e "${GREEN}📤 Deploying using SWA CLI...${NC}"
    swa deploy ./dist --deployment-token "$STATIC_WEB_APP_DEPLOYMENT_TOKEN" --env production
else
    echo -e "${YELLOW}⚠️  SWA CLI not installed. Installing...${NC}"
    npm install -g @azure/static-web-apps-cli
    
    echo -e "${GREEN}📤 Deploying using SWA CLI...${NC}"
    swa deploy ./dist --deployment-token "$STATIC_WEB_APP_DEPLOYMENT_TOKEN" --env production
fi

# Get the URL
STATIC_APP_URL=$(az staticwebapp show --name "$STATIC_WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "defaultHostname" -o tsv 2>/dev/null || echo "")

if [ ! -z "$STATIC_APP_URL" ]; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo -e "${GREEN}🌐 Your app is live at: https://$STATIC_APP_URL${NC}"
else
    echo -e "${GREEN}✅ Deployment initiated!${NC}"
    echo -e "${YELLOW}💡 Check Azure Portal for the deployment status and URL.${NC}"
fi

echo -e "${GREEN}🎉 Done!${NC}"

