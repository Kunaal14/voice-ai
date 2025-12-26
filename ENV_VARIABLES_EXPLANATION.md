# Environment Variables Storage - Current Approach

## 🔍 How We're Currently Storing Secrets

### Current Method: Build-Time Environment Variables

**Location**: `.env.local` file (local, gitignored)

**How it works:**
1. You create `.env.local` with your API keys and webhook URLs
2. Vite reads `.env.local` during `npm run build`
3. Values are **baked into the JavaScript bundle** using `vite.config.ts`:
   ```typescript
   define: {
     'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY),
     'process.env.FORM_WEBHOOK_URL': JSON.stringify(env.FORM_WEBHOOK_URL),
     // ... etc
   }
   ```
4. The built `dist/` folder contains JavaScript with these values hardcoded
5. When deployed, these values are visible in the browser's JavaScript

### ⚠️ Important Security Note

**For client-side applications (like this React app):**
- API keys and webhook URLs **will always be visible** in the browser
- This is because the JavaScript runs in the user's browser
- Even with Azure Key Vault, you'd need server-side code to fetch secrets

### ✅ Current Approach is Correct For:
- **Client-side React apps** (like this one)
- **Public webhooks** (intended to be called from browser)
- **Build-time configuration**

### 🔒 What We Should Do for Production

**Option 1: Continue Current Approach (Recommended for Static Sites)**
- Build locally with `.env.local`
- Deploy the `dist/` folder
- Secrets are in the build (acceptable for client-side apps)
- ✅ Simple, works for Static Web Apps
- ⚠️ Secrets visible in browser (unavoidable for client-side)

**Option 2: Azure Static Web Apps Environment Variables**
- Set env vars in Azure Portal
- Use Azure Functions (serverless) to proxy requests
- More complex, requires backend code
- ✅ Secrets stay on server
- ❌ Requires rewriting API calls to go through functions

**Option 3: Azure Key Vault + Serverless Functions**
- Store secrets in Azure Key Vault
- Create Azure Functions to proxy API calls
- Functions fetch secrets from Key Vault
- ✅ Most secure
- ❌ Requires significant code changes
- ❌ Adds latency and complexity

## 🎯 Recommended Approach for This Project

**For now**: Continue with Option 1 (current approach)
- It's appropriate for a client-side landing page
- Webhook URLs are meant to be called from the browser
- Gemini API key will be visible anyway (it's a client-side app)

**For future enhancement**: Consider Option 2 if you want to hide the Gemini API key
- Create Azure Functions to proxy Gemini API calls
- Store API key in Azure Key Vault
- Functions handle authentication server-side

## 📝 Current Files

- **`.env.local`** - Your actual secrets (gitignored, local only)
- **`.env.example`** - Template for public repository
- **`vite.config.ts`** - Reads `.env.local` and bakes values into build
- **`dist/`** - Built files with values hardcoded (deployed to Azure)

## 🔐 Security Best Practices Applied

✅ `.env.local` is in `.gitignore` (not committed)
✅ `.env.example` has placeholders (safe to commit)
✅ No secrets in source code
✅ Error handling for missing env vars
✅ Documentation for other builders

## 🚀 Deployment Process

1. **Local Build**: `npm run build` reads `.env.local` and creates `dist/`
2. **Deploy**: `dist/` folder is deployed to Azure Static Web Apps
3. **Result**: Built JavaScript contains the values (visible in browser)

This is the standard approach for client-side React applications.

