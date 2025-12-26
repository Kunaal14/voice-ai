import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import { SecretClient } from "@azure/keyvault-secrets";
import { DefaultAzureCredential } from "@azure/identity";

const KEY_VAULT_NAME = process.env.KEY_VAULT_NAME || "tigest-voice-ai-kv";
const KEY_VAULT_URI = `https://${KEY_VAULT_NAME}.vault.azure.net/`;
const ALLOWED_ORIGIN = process.env.ALLOWED_ORIGIN || "https://tigest.club";

// Simple rate limiting (in production, use Redis or Azure Cache)
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();
const RATE_LIMIT_WINDOW = 60 * 1000; // 1 minute
const RATE_LIMIT_MAX_REQUESTS = 10; // 10 requests per minute per IP

// Cache the API key to avoid repeated Key Vault calls
let cachedApiKey: string | null = null;
let cacheExpiry: number = 0;
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes

function checkRateLimit(clientIp: string): boolean {
  const now = Date.now();
  const record = rateLimitMap.get(clientIp);

  if (!record || now > record.resetTime) {
    rateLimitMap.set(clientIp, { count: 1, resetTime: now + RATE_LIMIT_WINDOW });
    return true;
  }

  if (record.count >= RATE_LIMIT_MAX_REQUESTS) {
    return false;
  }

  record.count++;
  return true;
}

function getClientIp(req: HttpRequest): string {
  return (
    req.headers["x-forwarded-for"]?.split(",")[0]?.trim() ||
    req.headers["x-client-ip"] ||
    "unknown"
  );
}

async function getApiKeyFromKeyVault(): Promise<string> {
  // Return cached key if still valid
  if (cachedApiKey && Date.now() < cacheExpiry) {
    return cachedApiKey;
  }

  try {
    const credential = new DefaultAzureCredential();
    const client = new SecretClient(KEY_VAULT_URI, credential);
    const secret = await client.getSecret("GEMINI-API-KEY");
    
    // Cache the key
    cachedApiKey = secret.value || "";
    cacheExpiry = Date.now() + CACHE_DURATION;
    
    return cachedApiKey;
  } catch (error) {
    console.error("Error retrieving API key from Key Vault:", error);
    throw new Error("Failed to retrieve API key from Key Vault");
  }
}

const httpTrigger: AzureFunction = async function (
  context: Context,
  req: HttpRequest
): Promise<void> {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    context.res = {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
        "Access-Control-Max-Age": "86400"
      }
    };
    return;
  }

  try {
    // Rate limiting
    const clientIp = getClientIp(req);
    if (!checkRateLimit(clientIp)) {
      context.res = {
        status: 429,
        body: {
          error: "Rate limit exceeded",
          message: "Too many requests. Please try again later."
        },
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
          "Retry-After": "60"
        }
      };
      return;
    }

    // Optional: Add authentication token check here
    // const authToken = req.headers["authorization"];
    // if (!isValidToken(authToken)) {
    //   context.res = { status: 401, body: { error: "Unauthorized" } };
    //   return;
    // }

    // Get API key from Key Vault
    const apiKey = await getApiKeyFromKeyVault();

    // Return the API key
    // Note: For Gemini Live API (WebSocket), the key still needs to be on client
    // But this adds security layers: rate limiting, monitoring, and Key Vault storage
    context.res = {
      status: 200,
      body: {
        apiKey: apiKey
      },
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization"
      }
    };

    // Log the request for monitoring
    context.log(`API key requested from IP: ${clientIp}`);
  } catch (error) {
    context.log.error("Error in gemini-proxy function:", error);
    context.res = {
      status: 500,
      body: {
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error"
      },
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": ALLOWED_ORIGIN
      }
    };
  }
};

export default httpTrigger;

