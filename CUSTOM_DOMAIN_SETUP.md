# Custom Domain Setup: tigest.club

## 🎯 Goal
Configure `tigest.club` to point to your Azure Static Web App.

## 📋 Steps

### Step 1: Deploy Azure Function (if not done)
```bash
./deploy-function.sh
```

This creates the Function App that securely retrieves your API key from Key Vault.

### Step 2: Deploy Static Web App
```bash
npm run deploy
```

Or:
```bash
./azure-deploy.sh
```

### Step 3: Configure Custom Domain in Azure

#### Option A: Using Azure CLI
```bash
# Get your Static Web App default domain
APP_URL=$(az staticwebapp show \
  --name tigest-voice-ai-landing \
  --resource-group Kunaal \
  --query defaultHostname \
  -o tsv)

# Add custom domain
az staticwebapp hostname set \
  --name tigest-voice-ai-landing \
  --resource-group Kunaal \
  --hostname tigest.club \
  --validation-method cname-delegation
```

#### Option B: Using Azure Portal
1. Go to Azure Portal → Static Web Apps → `tigest-voice-ai-landing`
2. Click "Custom domains" in the left menu
3. Click "Add"
4. Enter: `tigest.club`
5. Choose validation method: **CNAME delegation** (recommended)
6. Azure will show you the validation record

### Step 4: Configure DNS in GoDaddy

1. **Log in to GoDaddy**
   - Go to https://www.godaddy.com
   - Sign in to your account
   - Go to "My Products" → "DNS"

2. **Add CNAME Record for Validation**
   - Azure will provide a validation record like:
     ```
     Type: CNAME
     Name: asuid.tigest.club
     Value: [validation-id].azurestaticapps.net
     ```
   - Add this CNAME record in GoDaddy

3. **Add Main CNAME Record**
   - Type: **CNAME**
   - Name: **@** (or leave blank for root domain)
   - Value: **tigest-voice-ai-landing.[region].azurestaticapps.net**
     - Example: `tigest-voice-ai-landing.eastus2.azurestaticapps.net`
   - TTL: **600** (or default)

4. **Wait for DNS Propagation**
   - Usually takes 5-30 minutes
   - Can check with: `nslookup tigest.club`

### Step 5: Verify Domain

```bash
# Check DNS propagation
nslookup tigest.club

# Check if domain is validated in Azure
az staticwebapp hostname show \
  --name tigest-voice-ai-landing \
  --resource-group Kunaal \
  --hostname tigest.club
```

### Step 6: Update Function App CORS

After custom domain is set up, update the Function App to allow your custom domain:

```bash
az functionapp config appsettings set \
  --name tigest-voice-ai-api \
  --resource-group Kunaal \
  --settings "ALLOWED_ORIGIN=https://tigest.club"
```

### Step 7: Update Environment Variables

Update `.env.local` with the custom domain:

```env
# Use custom domain for API key function
GEMINI_API_KEY_URL=https://tigest-voice-ai-api.azurewebsites.net/api/gemini-proxy?code=YOUR_KEY

# Or if you set up a custom domain for the function too:
# GEMINI_API_KEY_URL=https://api.tigest.club/api/gemini-proxy?code=YOUR_KEY
```

## 🔍 Troubleshooting

### DNS Not Propagating
- Wait 30-60 minutes
- Clear DNS cache: `sudo dscacheutil -flushcache` (Mac) or `ipconfig /flushdns` (Windows)
- Check with different DNS servers: `nslookup tigest.club 8.8.8.8`

### Domain Validation Failing
- Ensure the `asuid.tigest.club` CNAME record is correct
- Wait for DNS propagation
- Try "TXT record" validation method instead

### SSL Certificate Issues
- Azure automatically provisions SSL certificates for custom domains
- May take 24-48 hours after domain validation
- Check in Azure Portal → Custom domains → SSL certificate status

### CORS Errors
- Update Function App `ALLOWED_ORIGIN` setting
- Ensure it matches exactly: `https://tigest.club` (with https, no trailing slash)

## 📝 DNS Records Summary

In GoDaddy, you should have:

```
Type    Name              Value
----    ----              -----
CNAME   asuid             [validation-id].azurestaticapps.net
CNAME   @                 tigest-voice-ai-landing.eastus2.azurestaticapps.net
```

## ✅ Verification Checklist

- [ ] DNS records added in GoDaddy
- [ ] Domain validated in Azure Portal
- [ ] CNAME records propagated (check with nslookup)
- [ ] SSL certificate provisioned (may take 24-48 hours)
- [ ] Function App CORS updated
- [ ] Environment variables updated
- [ ] Site accessible at https://tigest.club
- [ ] Voice agent works with custom domain

## 🚀 Quick Commands

```bash
# Deploy everything
./deploy-function.sh
npm run deploy

# Check domain status
az staticwebapp hostname list \
  --name tigest-voice-ai-landing \
  --resource-group Kunaal

# Update CORS
az functionapp config appsettings set \
  --name tigest-voice-ai-api \
  --resource-group Kunaal \
  --settings "ALLOWED_ORIGIN=https://tigest.club"
```

---

**Once DNS propagates, your site will be live at https://tigest.club!** 🎉

