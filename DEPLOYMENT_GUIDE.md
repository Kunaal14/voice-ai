# Deployment Guide - Azure Static Web Apps

This guide explains how to deploy the Tigest Voice AI Landing Page to Azure.

## 🎯 Deployment Approach

We're using **Azure Static Web Apps** which is perfect for React/Vite applications:
- ✅ Free tier available
- ✅ Automatic HTTPS
- ✅ Global CDN
- ✅ No server management
- ✅ Won't interfere with your existing App Services

## 📋 Prerequisites

1. **Azure CLI installed** (you already have it)
2. **Logged in to Azure** (`az login`)
3. **Node.js and npm** installed
4. **Build the project** (`npm run build`)

## 🚀 Quick Deployment

### Option 1: Using the Deployment Script (Recommended)

```bash
# Make script executable (first time only)
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

The script will:
1. Check if Static Web App exists (create if not)
2. Build your project
3. Deploy to Azure
4. Show you the live URL

### Option 2: Manual Deployment

#### Step 1: Create Static Web App (First Time Only)

```bash
az staticwebapp create \
  --name tigest-voice-ai-landing \
  --resource-group Kunaal \
  --location southindia \
  --sku Free
```

#### Step 2: Get Deployment Token

```bash
az staticwebapp secrets list \
  --name tigest-voice-ai-landing \
  --resource-group Kunaal \
  --query "properties.apiKey" \
  -o tsv
```

Save this token - you'll need it for deployment.

#### Step 3: Build Project

```bash
npm run build
```

#### Step 4: Deploy

Install SWA CLI (if not already installed):
```bash
npm install -g @azure/static-web-apps-cli
```

Deploy:
```bash
swa deploy ./dist \
  --deployment-token YOUR_DEPLOYMENT_TOKEN \
  --env production
```

## 🔧 Configuration

### ⚠️ Important: Environment Variables for Static Web Apps

**For Azure Static Web Apps, environment variables work differently:**

1. **During Build**: Vite needs env vars at build time
2. **Two Options**:
   - **Option A**: Build locally with `.env.local`, then deploy `dist/` folder
   - **Option B**: Set env vars in Azure Portal and use GitHub Actions (for automated builds)

**For manual deployment (current setup):**
- Build locally with your `.env.local` file
- The env vars are baked into the build
- Deploy the `dist/` folder

### Setting Environment Variables in Azure Portal (For Future Automation)

If you set up GitHub Actions later, you can set env vars in Azure Portal:

1. Go to Azure Portal
2. Navigate to: Static Web Apps > `tigest-voice-ai-landing` > Configuration
3. Add Application Settings:
   - `GEMINI_API_KEY` = Your Gemini API key
   - `FORM_WEBHOOK_URL` = Your form webhook URL
   - `TRANSCRIPT_WEBHOOK_URL` = Your transcript webhook URL
   - `CALENDAR_AVAILABILITY_URL` = Your calendar webhook URL (optional)

**Note**: For Static Web Apps, environment variables need to be set in Azure Portal, not in `.env.local` (that's only for local development).

### Update Deployment Script

Edit `deploy.sh` and update these variables if needed:

```bash
RESOURCE_GROUP="Kunaal"
STATIC_WEB_APP_NAME="tigest-voice-ai-landing"
LOCATION="southindia"
```

## 📝 Deployment Workflow

### Current Setup (Manual)

1. **Make changes** to your code
2. **Test locally** with `npm run dev`
3. **Commit and push** to GitHub main branch
4. **Run deployment script**:
   ```bash
   ./deploy.sh
   ```

### Future: Automated Deployment (Optional)

If you want to automate later, you can:
1. Set up GitHub Actions workflow
2. Deploy automatically on push to main
3. Use Azure Static Web Apps GitHub integration

For now, manual deployment gives you full control.

## 🔍 Verify Deployment

After deployment:

1. **Get the URL**:
   ```bash
   az staticwebapp show \
     --name tigest-voice-ai-landing \
     --resource-group Kunaal \
     --query "defaultHostname" \
     -o tsv
   ```

2. **Visit the URL** in your browser

3. **Test functionality**:
   - Contact form submission
   - Voice agent
   - ROI calculator sliders

## 🛠️ Troubleshooting

### Build Fails

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Deployment Fails

1. Check deployment token is correct
2. Verify Static Web App exists:
   ```bash
   az staticwebapp show --name tigest-voice-ai-landing --resource-group Kunaal
   ```
3. Check build output exists:
   ```bash
   ls -la dist/
   ```

### Environment Variables Not Working

- Static Web Apps need env vars set in Azure Portal
- They're injected at build time
- Restart the app after adding env vars

## 📊 Resource Information

- **Resource Group**: `Kunaal`
- **Location**: `southindia` (matches your existing resources)
- **Service**: Azure Static Web Apps (Free tier)
- **Won't interfere with**: Your existing App Services (analytics-worker, youtube-reply-api, etc.)

## 🔒 Security Notes

- Deployment token is sensitive - don't commit it
- Add `STATIC_WEB_APP_DEPLOYMENT_TOKEN` to `.env.local` (gitignored)
- Or use Azure Key Vault for production

## 📚 Additional Resources

- [Azure Static Web Apps Docs](https://docs.microsoft.com/azure/static-web-apps/)
- [SWA CLI Documentation](https://azure.github.io/static-web-apps-cli/)

---

**Ready to deploy?** Run `./deploy.sh` and follow the prompts!

