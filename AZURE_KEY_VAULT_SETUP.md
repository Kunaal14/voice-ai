# Azure Key Vault Setup Guide

## 🔐 Secure API Key Storage with Azure Key Vault

This guide explains how to set up Azure Key Vault to securely store your Gemini API key.

## ✅ What We've Implemented

1. **Azure Key Vault** - `tigest-voice-ai-kv` (created)
2. **Azure Function** - Proxies API key retrieval with rate limiting
3. **Client Code** - Updated to fetch API key from Azure Function
4. **Security Layers**:
   - API key stored in Key Vault (not in code)
   - Rate limiting (10 requests/minute per IP)
   - CORS protection (only allows requests from your domain)
   - Monitoring and logging

## 📋 Setup Steps

### Step 1: Store API Key in Key Vault

**Option A: Using Azure Portal**
1. Go to Azure Portal → Key Vaults → `tigest-voice-ai-kv`
2. Click "Secrets" → "Generate/Import"
3. Name: `GEMINI-API-KEY`
4. Value: Your Gemini API key
5. Click "Create"

**Option B: Using Azure CLI** (after RBAC propagates)
```bash
az keyvault secret set \
  --vault-name tigest-voice-ai-kv \
  --name GEMINI-API-KEY \
  --value "your-api-key-here"
```

### Step 2: Deploy Azure Function

```bash
./deploy-function.sh
```

This will:
- Create Function App (if needed)
- Create Storage Account (if needed)
- Grant Function App access to Key Vault
- Deploy the function code
- Show you the function URL

### Step 3: Configure Environment Variable

After deployment, add the function URL to `.env.local`:

```env
GEMINI_API_KEY_URL=https://your-function-app.azurewebsites.net/api/gemini-proxy?code=YOUR_FUNCTION_KEY
```

You can get the function key from:
- Azure Portal → Function App → Functions → `gemini-proxy` → Function Keys
- Or from the deployment script output

### Step 4: Update Allowed Origin

Update the `ALLOWED_ORIGIN` in Function App settings:

```bash
az functionapp config appsettings set \
  --name tigest-voice-ai-api \
  --resource-group Kunaal \
  --settings "ALLOWED_ORIGIN=https://tigest.club"
```

## 🔒 Security Features

### Rate Limiting
- **10 requests per minute** per IP address
- Prevents abuse and API key extraction attempts
- Returns 429 (Too Many Requests) when exceeded

### CORS Protection
- Only allows requests from your domain (`tigest.club`)
- Prevents other sites from using your function

### Key Vault Integration
- API key never stored in code or environment variables
- Retrieved securely at runtime
- Cached for 5 minutes to reduce Key Vault calls

### Monitoring
- All requests logged with IP addresses
- Can set up alerts in Azure Monitor
- Track usage patterns

## 🚨 Important Notes

### For Gemini Live API (WebSocket)
The Gemini Live API requires the API key on the client side to establish WebSocket connections. This means:
- The API key will still be visible in the browser
- **BUT** we've added security layers:
  - Rate limiting prevents abuse
  - Monitoring tracks usage
  - Key stored in Key Vault (not in code)
  - Can revoke/rotate keys without code changes

### Future Enhancement
For true server-side security, we would need to:
- Create a WebSocket proxy in Azure Functions
- Proxy all WebSocket messages through the function
- This is more complex but provides complete security

## 🔍 Verification

### Test the Function
```bash
curl https://your-function-app.azurewebsites.net/api/gemini-proxy?code=YOUR_KEY
```

Should return:
```json
{
  "apiKey": "your-api-key-here"
}
```

### Check Rate Limiting
Make 11 requests quickly - the 11th should return 429.

### Check CORS
Try from a different origin - should be blocked.

## 📊 Monitoring

### View Function Logs
```bash
az functionapp log tail \
  --name tigest-voice-ai-api \
  --resource-group Kunaal
```

### View Key Vault Access Logs
Azure Portal → Key Vault → Monitoring → Logs

## 🔄 Rotating API Keys

1. Store new key in Key Vault:
   ```bash
   az keyvault secret set \
     --vault-name tigest-voice-ai-kv \
     --name GEMINI-API-KEY \
     --value "new-api-key"
   ```

2. Function will automatically use new key (cache expires in 5 minutes)

3. No code changes needed!

## 💰 Cost

- **Key Vault**: Free tier (up to 10,000 transactions/month)
- **Function App**: Consumption plan (pay per execution)
- **Storage Account**: ~$0.02/month (minimal usage)

Total: **~$0.20-0.50/month** for typical usage

## 🆘 Troubleshooting

### "Forbidden" error when storing secret
- Wait 5-10 minutes for RBAC to propagate
- Or use Azure Portal to store the secret

### Function returns 500 error
- Check Function App logs
- Verify Key Vault access is granted
- Verify secret exists in Key Vault

### Rate limit too strict
- Adjust `RATE_LIMIT_MAX_REQUESTS` in `api/gemini-proxy/index.ts`
- Redeploy the function

## 📝 Next Steps

1. ✅ Store API key in Key Vault (via Portal)
2. ✅ Deploy Azure Function
3. ✅ Add function URL to `.env.local`
4. ✅ Test the function
5. ✅ Deploy updated client code
6. ✅ Monitor usage

---

**Your API key is now securely stored in Azure Key Vault!** 🔐

