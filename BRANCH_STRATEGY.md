# Branch Strategy: Public vs Private

## ⚠️ Important: GitHub Limitation

**GitHub does NOT support per-branch privacy.** The entire repository is either public or private.

However, we can achieve the same effect using these strategies:

## 🎯 Recommended Approach: "Quiet" Production Branch

### How It Works:

```
main branch       → Public, documented, for community
production branch → "Quiet" (exists but not mentioned publicly)
```

**Strategy:**
- ✅ Keep `production` branch in the repo
- ✅ Don't document it in public README
- ✅ Don't mention it in public docs
- ✅ Use it for your personal deployments
- ✅ Most users won't notice it exists

**Pros:**
- ✅ Simple (same repo)
- ✅ Easy to sync changes
- ✅ No separate repo to manage

**Cons:**
- ⚠️ Branch is technically visible (but not obvious)
- ⚠️ Advanced users might find it

## 🔒 Alternative: Separate Private Repository

If you want TRUE privacy:

### Setup:

1. **Public Repo:** `landing-page-voice-ai` (public)
2. **Private Repo:** `landing-page-voice-ai-production` (private)

**Workflow:**
```bash
# Work in private repo
cd landing-page-voice-ai-production
# Make changes
git commit -m "Personal changes"
git push
npm run deploy

# Sync to public when ready
cd ../landing-page-voice-ai
git pull origin main
# Cherry-pick specific commits
git push origin main
```

**Pros:**
- ✅ Complete privacy
- ✅ Production code never visible

**Cons:**
- ❌ More complex
- ❌ Need to sync between repos

## 📋 Current Setup (Recommended)

We're using the **"Quiet Production Branch"** approach:

### Branches:

- **`main`** → Public, stable, for community
- **`production`** → Your personal version (exists but not documented publicly)

### Workflow:

**For Personal Changes:**
```bash
git checkout production
# Make changes
git commit -m "Personal: Description"
git push origin production
npm run deploy
```

**For Public Release:**
```bash
git checkout main
git merge production  # Or cherry-pick specific commits
git push origin main
```

### Making Production "Invisible":

1. ✅ Don't mention `production` branch in README
2. ✅ Default branch is `main` (users see that first)
3. ✅ Documentation only mentions `main`
4. ✅ Production branch exists but is "quiet"

## 🔍 How Visible Is Production Branch?

**To regular users:**
- ❌ Not mentioned in README
- ❌ Not the default branch
- ❌ Not in documentation
- ⚠️ Visible if they browse branches (but unlikely)

**To advanced users:**
- ⚠️ Can see it exists
- ⚠️ Can view commits (but not your `.env.local`)
- ✅ Can't see your secrets (those are local only)

## 💡 Best Practices

### 1. Commit Messages

**Production branch:**
```
Personal: Add custom analytics
Personal: Update branding
Personal: Custom integration
```

**Main branch:**
```
Add new feature
Fix bug
Update documentation
```

### 2. Keep Production Updated

```bash
# Sync public changes to production
git checkout production
git merge main
git push origin production
```

### 3. Selective Merging

```bash
# Only merge what you want public
git checkout main
git cherry-pick <commit-hash>  # Specific commit
git push origin main
```

## 🚀 Deployment

**Always deploy from production:**
```bash
git checkout production
npm run deploy
```

The deployment script now checks you're on production branch.

## 📝 Summary

**Current Setup:**
- ✅ `main` = Public branch (documented)
- ✅ `production` = Quiet branch (not documented publicly)
- ✅ Same repo, different branches
- ✅ Your secrets stay in `.env.local` (local only)

**This gives you:**
- ✅ Privacy for personal changes
- ✅ Public repo for community
- ✅ Simple workflow
- ✅ Easy to maintain

---

**Bottom Line:** Production branch exists but is "quiet" - not mentioned publicly. This is the best balance of simplicity and privacy! 🎯

