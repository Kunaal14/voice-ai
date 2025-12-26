# Maintainer Workflow: Public Repo + Personal Changes

## 🎯 The Problem

You want to:
- ✅ Keep a public repo for the community
- ✅ Make personal/production changes without affecting public repo
- ✅ Control when changes go public
- ✅ Test changes before making them public

## 💡 Solution: **Branch Strategy** (Recommended)

### Structure:

```
main branch          → Public/stable version (for community)
production branch    → Your personal/production version
feature branches     → New features (merge to both when ready)
```

## 🔄 Workflow Options

### Option 1: Separate Production Branch (Best for You)

**How it works:**
- `main` = Public, stable version
- `production` = Your personal version with custom changes
- You make changes on `production`, deploy from there
- When ready, merge to `main` for public release

**Setup:**
```bash
# Create production branch from main
git checkout -b production
git push origin production

# Keep production branch private (or just don't mention it publicly)
```

**Daily Workflow:**
```bash
# Make personal changes
git checkout production
# ... make changes ...
git commit -m "Personal: Add custom feature"
git push origin production
npm run deploy  # Deploy from production branch

# When ready to share with public
git checkout main
git merge production  # Or cherry-pick specific commits
git push origin main
```

**Pros:**
- ✅ Simple
- ✅ Same repo, different branches
- ✅ Easy to sync changes
- ✅ Can test before making public

**Cons:**
- ⚠️ Production branch is visible (but you can keep it quiet)

### Option 2: Separate Private Repository (Maximum Privacy)

**How it works:**
- Public repo: `landing-page-voice-ai` (public)
- Private repo: `landing-page-voice-ai-production` (private)
- You develop in private repo
- Sync to public repo when ready

**Setup:**
```bash
# Clone your public repo
git clone https://github.com/Kunaal14/landing-page-voice-ai.git
cd landing-page-voice-ai

# Create private repo on GitHub
# Then add it as a remote
git remote add production https://github.com/Kunaal14/landing-page-voice-ai-production.git
```

**Daily Workflow:**
```bash
# Work in private repo
cd landing-page-voice-ai-production
# ... make changes ...
git commit -m "Personal: Add custom feature"
git push origin main
npm run deploy

# When ready to share, sync to public repo
cd ../landing-page-voice-ai
git pull origin main  # Get latest from public
# Cherry-pick or merge specific commits from private
git push origin main
```

**Pros:**
- ✅ Complete privacy
- ✅ Production code never visible
- ✅ Full control

**Cons:**
- ❌ More complex
- ❌ Need to sync between repos
- ❌ More maintenance

### Option 3: Feature Branches + Selective Merging (Recommended)

**How it works:**
- `main` = Public version
- Feature branches for everything
- Merge to `main` only when ready for public
- Keep a local `production` branch for deployment

**Setup:**
```bash
# Create production branch (local only, or push but don't document)
git checkout -b production
git push origin production --set-upstream
```

**Daily Workflow:**
```bash
# For personal changes (not for public)
git checkout production
git checkout -b personal/custom-feature
# ... make changes ...
git commit -m "Personal: Custom feature"
git checkout production
git merge personal/custom-feature
git push origin production
npm run deploy  # Deploy from production

# For public features
git checkout main
git checkout -b feature/public-feature
# ... make changes ...
git commit -m "Add public feature"
# Test, review, then merge
git checkout main
git merge feature/public-feature
git push origin main
```

**Pros:**
- ✅ Clean separation
- ✅ Easy to track what's public vs private
- ✅ Can merge selectively

**Cons:**
- ⚠️ Need discipline to keep branches separate

## 🎯 My Recommendation: **Option 1 (Production Branch)**

### Why:
1. **Simple** - Same repo, just different branch
2. **Flexible** - Easy to merge when ready
3. **Standard** - Common pattern in open source
4. **Low maintenance** - No syncing between repos

### Setup Steps:

```bash
# 1. Create production branch
git checkout -b production
git push origin production

# 2. Set up deployment from production branch
# Update your deployment script or use:
git checkout production
npm run deploy

# 3. Keep main as public/stable
git checkout main
# Only merge to main when ready for public release
```

### Workflow Example:

**Scenario: You want to add a custom analytics script (not for public)**

```bash
# Work on production branch
git checkout production
# Add analytics script
git add .
git commit -m "Add custom analytics"
git push origin production
npm run deploy  # Deploy your version

# Main branch stays unchanged (public doesn't see it)
```

**Scenario: You want to add a new feature for public**

```bash
# Work on feature branch
git checkout main
git checkout -b feature/new-calculator
# Add feature
git commit -m "Add new ROI calculator"
git push origin feature/new-calculator

# Test, then merge to main
git checkout main
git merge feature/new-calculator
git push origin main

# Also merge to production to keep it in sync
git checkout production
git merge main
git push origin production
```

## 📋 Best Practices

### 1. Commit Messages

**For personal changes:**
```
Personal: Add custom analytics
Personal: Update branding
Personal: Custom webhook integration
```

**For public changes:**
```
Add new ROI calculator
Fix slider drag issue
Update documentation
```

### 2. Branch Naming

```
main              → Public/stable
production        → Your production version
feature/xxx       → Public features
personal/xxx      → Private changes
hotfix/xxx        → Urgent fixes
```

### 3. When to Merge to Main

- ✅ Feature is complete and tested
- ✅ Documentation is updated
- ✅ No sensitive data included
- ✅ Ready for community use

### 4. Deployment Strategy

```bash
# Deploy production version (your live site)
git checkout production
npm run deploy

# Deploy public version (if you want a demo)
git checkout main
npm run deploy -- --env demo
```

## 🔐 Keeping Secrets Safe

### Your `.env.local` stays local:
- ✅ Never committed (gitignored)
- ✅ Different values for production vs public
- ✅ Production branch uses your `.env.local`
- ✅ Public users use their own `.env.local`

### Example `.env.local` for Production:
```env
GEMINI_API_KEY=your-production-key
FORM_WEBHOOK_URL=your-production-webhook
CAL_COM_LINK=your-personal-cal-link
```

### Public users will have:
```env
GEMINI_API_KEY=their-key
FORM_WEBHOOK_URL=their-webhook
CAL_COM_LINK=their-cal-link
```

## 🚀 Quick Reference

### Daily Personal Changes:
```bash
git checkout production
# Make changes
git commit -m "Personal: Description"
git push origin production
npm run deploy
```

### Public Release:
```bash
git checkout main
git merge production  # Or cherry-pick specific commits
git push origin main
```

### Keep Production Updated:
```bash
git checkout production
git merge main  # Get public updates
git push origin production
```

## 💡 Pro Tips

1. **Use tags for releases:**
   ```bash
   git tag -a v1.0.0 -m "Public release v1.0.0"
   git push origin v1.0.0
   ```

2. **Document your workflow:**
   - Add to README: "Maintainers: See MAINTAINER_WORKFLOW.md"

3. **Automate deployment:**
   - Set up GitHub Actions to auto-deploy `production` branch
   - Keep `main` for manual releases

4. **Use `.gitattributes` for branch-specific files:**
   ```gitattributes
   # Production-only files
   production-config.json merge=ours
   ```

---

**Bottom Line:** Use a `production` branch for your personal changes, keep `main` as the public stable version. Simple, flexible, and standard practice! 🎯

