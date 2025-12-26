# Repository Structure Guide for Open Source

## 🎯 Recommended Approach: **Single Public Repository**

### ✅ Make THIS Repository Public

**Why this approach:**
- ✅ Standard open source pattern
- ✅ Easy for others to fork and use
- ✅ All sensitive data already in environment variables
- ✅ `.env.local` is gitignored (safe)
- ✅ `.env.example` provides template (safe for public)

### 📁 Repository Structure

```
landing-page-voice-ai/          # PUBLIC REPOSITORY
├── .env.example                 # ✅ Safe template (committed)
├── .env.local                   # ❌ Your secrets (gitignored)
├── .gitignore                   # ✅ Excludes .env.local
├── README.md                    # ✅ Public documentation
├── SETUP_GUIDE.md               # ✅ Setup instructions
├── components/                  # ✅ All code (public)
├── api/                         # ✅ Azure Function code (public)
└── ...                          # ✅ All other files (public)
```

## 🔒 Security Model

### What's Public (Safe):
- ✅ All source code
- ✅ `.env.example` (placeholders only)
- ✅ Documentation
- ✅ Deployment scripts
- ✅ Azure Function code (no secrets)

### What's Private (Never Committed):
- ❌ `.env.local` (your actual secrets)
- ❌ API keys
- ❌ Webhook URLs
- ❌ Cal.com links
- ❌ Any personal identifiers

## 🔧 What Needs to Be Fixed

### Issue Found: Hardcoded Cal.com Link

**Current (in `App.tsx`):**
```typescript
calLink: "kunaal/call-30-minute",  // ❌ Your personal link
```

**Should be:**
```typescript
calLink: process.env.CAL_COM_LINK || "",  // ✅ Environment variable
```

## 📋 Action Items Before Making Public

### 1. Move Cal.com Link to Environment Variable

**Update `App.tsx`:**
- Replace hardcoded `"kunaal/call-30-minute"` with `process.env.CAL_COM_LINK`
- Add to `vite.config.ts` environment variable mapping
- Add to `.env.example` as placeholder

### 2. Store Cal.com Link in Azure Key Vault (Optional but Recommended)

Since you're using Key Vault for API keys, you can also store:
- Cal.com link
- Any other personal identifiers

### 3. Verify No Other Hardcoded Secrets

Run these checks:
```bash
# Check for hardcoded webhook URLs
grep -r "https://.*webhook" --exclude-dir=node_modules --exclude="*.md" .

# Check for hardcoded API keys
grep -r "AIzaSy\|sk-\|api_key" --exclude-dir=node_modules --exclude="*.md" .

# Check for personal identifiers
grep -r "kunaal\|@.*\.com" --exclude-dir=node_modules --exclude="*.md" .
```

## 🌟 How Open Source Projects with Hosting Work

### Common Patterns:

#### Pattern 1: Single Public Repo (Recommended for You)
```
Public Repo (GitHub)
├── Code (public)
├── .env.example (public template)
└── .env.local (gitignored, private)
```

**How it works:**
- Users fork/clone the repo
- They create their own `.env.local`
- They deploy to their own hosting
- Each user has their own secrets

**Examples:** Next.js, Vercel templates, Create React App

#### Pattern 2: Separate Private/Public Repos
```
Private Repo (your production)
├── .env.local (your secrets)
└── Code

Public Repo (open source)
├── Code (same)
├── .env.example (template)
└── No secrets
```

**When to use:**
- If you have proprietary code you don't want to share
- If you want to keep production config completely separate

#### Pattern 3: Monorepo with Private Config
```
Monorepo
├── packages/
│   ├── landing-page/ (public)
│   └── config/ (private, separate repo)
```

**When to use:**
- Large projects with multiple packages
- Enterprise setups

## 🎯 Recommended Structure for You

### Option A: Single Public Repo (Best for You)

**Structure:**
```
landing-page-voice-ai/ (PUBLIC)
├── .env.example          # Template
├── .env.local            # Your secrets (gitignored)
├── All code              # Public
└── Documentation         # Public
```

**Workflow:**
1. Make repo public on GitHub
2. Users fork/clone
3. They add their own `.env.local`
4. They deploy to their own Azure/hosting
5. You can still update the repo and deploy your version

**Pros:**
- ✅ Simple
- ✅ Standard open source pattern
- ✅ Easy for others to use
- ✅ You can still maintain your production version

**Cons:**
- ⚠️ Your production secrets stay in `.env.local` (local only, safe)

### Option B: Two Repos (If You Want Separation)

**Structure:**
```
landing-page-voice-ai/ (PUBLIC)
└── All code and docs

landing-page-voice-ai-private/ (PRIVATE)
└── .env.local (your production secrets)
```

**Workflow:**
1. Public repo: Open source version
2. Private repo: Your production config only
3. Sync code changes from public to private when needed

**Pros:**
- ✅ Complete separation
- ✅ Production secrets never in public repo

**Cons:**
- ❌ More complex
- ❌ Need to sync changes between repos
- ❌ Overkill for this use case

## 💡 My Recommendation

**Use Option A: Single Public Repo**

**Why:**
1. Your `.env.local` is already gitignored (safe)
2. All secrets are in environment variables (good practice)
3. Standard open source pattern
4. Easy for others to fork and use
5. You can still maintain your production version

**What to do:**
1. ✅ Fix Cal.com link (move to env var)
2. ✅ Verify no other hardcoded secrets
3. ✅ Make repo public
4. ✅ Update README with setup instructions

## 🔄 Maintenance Workflow

### For You (Maintainer):
```bash
# Make changes
git checkout -b feature/new-feature
# ... make changes ...
git commit -m "Add new feature"
git push origin feature/new-feature
# Create PR, merge to main
npm run deploy  # Deploy your production version
```

### For Users (Forkers):
```bash
# Fork your repo
git clone https://github.com/their-username/landing-page-voice-ai.git
cd landing-page-voice-ai
cp .env.example .env.local
# Edit .env.local with their own secrets
npm install
npm run dev
# Deploy to their own hosting
```

## 📝 Checklist Before Making Public

- [ ] Move Cal.com link to environment variable
- [ ] Verify `.env.local` is in `.gitignore`
- [ ] Check `.env.example` has all placeholders
- [ ] Run security checks (grep for secrets)
- [ ] Update README with clear setup instructions
- [ ] Add LICENSE file (MIT, Apache, etc.)
- [ ] Add CONTRIBUTING.md (optional)
- [ ] Test that users can fork and set up easily
- [ ] Make repository public on GitHub

## 🚀 Next Steps

1. **Fix Cal.com link** (I'll do this now)
2. **Run security verification**
3. **Make repo public**
4. **Share with the community!**

---

**Bottom line:** Make THIS repo public. It's already set up correctly with environment variables. Just need to fix the Cal.com link and you're good to go! 🎉

