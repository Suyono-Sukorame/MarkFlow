# 🔧 Git Setup - Fix Permission Error 403

## ❌ Error yang Terjadi:
```
remote: Permission to Suyono-Sukorame/MarkFlow.git denied to suyono-ionstack.
fatal: unable to access 'https://github.com/Suyono-Sukorame/MarkFlow.git/': 
The requested URL returned error: 403
```

## 🔍 Penyebab:
1. Git credentials yang tersimpan (`suyono-ionstack`) berbeda dengan owner repository (`Suyono-Sukorame`)
2. Credentials lama masih tersimpan di macOS Keychain
3. Tidak ada authentication yang valid

---

## ✅ Solusi 1: Gunakan Personal Access Token (RECOMMENDED)

### Step 1: Generate Personal Access Token di GitHub

1. Buka: https://github.com/settings/tokens
2. Klik **"Generate new token"** → **"Generate new token (classic)"**
3. Beri nama: `MarkFlow Deployment`
4. Set expiration: **90 days** atau **No expiration**
5. Pilih scope/permissions:
   - ✅ `repo` (Full control of private repositories)
6. Klik **"Generate token"**
7. **COPY TOKEN** - Anda tidak akan bisa melihatnya lagi!

### Step 2: Hapus Credentials Lama dari Keychain

```bash
# Hapus credentials GitHub yang lama
git credential-osxkeychain erase
host=github.com
protocol=https
# Tekan Enter 2x
```

### Step 3: Setup Remote dengan Token

```bash
cd /Users/admin/Project/02.\ Fullstack\ Mobile\ App/2.\ Go\ \(Fiber\)\ +\ Flutter/markflow

# Tambah remote dengan format: https://TOKEN@github.com/USER/REPO.git
git remote add origin https://YOUR_PERSONAL_ACCESS_TOKEN@github.com/Suyono-Sukorame/MarkFlow.git

# Atau jika sudah ada origin:
git remote set-url origin https://YOUR_PERSONAL_ACCESS_TOKEN@github.com/Suyono-Sukorame/MarkFlow.git
```

### Step 4: Push ke GitHub

```bash
git push -u origin main
```

---

## ✅ Solusi 2: Gunakan SSH (ALTERNATIVE)

### Step 1: Generate SSH Key (jika belum punya)

```bash
# Generate SSH key baru
ssh-keygen -t ed25519 -C "suyono@aqj.or.id"
# Tekan Enter untuk default location
# Tekan Enter 2x untuk no passphrase (atau buat passphrase)

# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key ke agent
ssh-add ~/.ssh/id_ed25519
```

### Step 2: Copy SSH Public Key

```bash
# Copy public key ke clipboard
cat ~/.ssh/id_ed25519.pub | pbcopy

# Atau tampilkan untuk di-copy manual
cat ~/.ssh/id_ed25519.pub
```

### Step 3: Add SSH Key ke GitHub

1. Buka: https://github.com/settings/keys
2. Klik **"New SSH key"**
3. Title: `MacBook MarkFlow`
4. Paste public key yang sudah di-copy
5. Klik **"Add SSH key"**

### Step 4: Test SSH Connection

```bash
ssh -T git@github.com
# Should see: "Hi Suyono-Sukorame! You've successfully authenticated..."
```

### Step 5: Update Remote to SSH

```bash
cd /Users/admin/Project/02.\ Fullstack\ Mobile\ App/2.\ Go\ \(Fiber\)\ +\ Flutter/markflow

# Hapus remote lama
git remote remove origin

# Tambah remote dengan SSH
git remote add origin git@github.com:Suyono-Sukorame/MarkFlow.git

# Push
git push -u origin main
```

---

## ✅ Solusi 3: Gunakan GitHub CLI (EASIEST)

### Step 1: Install GitHub CLI

```bash
# Jika belum install
brew install gh
```

### Step 2: Login dengan GitHub CLI

```bash
# Login interaktively
gh auth login

# Pilih:
# - GitHub.com
# - HTTPS
# - Authenticate with web browser
```

### Step 3: Setup Remote & Push

```bash
cd /Users/admin/Project/02.\ Fullstack\ Mobile\ App/2.\ Go\ \(Fiber\)\ +\ Flutter/markflow

# Hapus remote lama
git remote remove origin

# Tambah remote
gh repo set-default Suyono-Sukorame/MarkFlow

# Push
git push -u origin main
```

---

## 🔧 Quick Fix Commands

### Option A: With Personal Access Token
```bash
cd /Users/admin/Project/02.\ Fullstack\ Mobile\ App/2.\ Go\ \(Fiber\)\ +\ Flutter/markflow

# Replace YOUR_TOKEN with actual token from GitHub
git remote add origin https://YOUR_TOKEN@github.com/Suyono-Sukorame/MarkFlow.git
git push -u origin main
```

### Option B: With SSH
```bash
cd /Users/admin/Project/02.\ Fullstack\ Mobile\ App/2.\ Go\ \(Fiber\)\ +\ Flutter/markflow

git remote add origin git@github.com:Suyono-Sukorame/MarkFlow.git
git push -u origin main
```

### Option C: With GitHub CLI
```bash
cd /Users/admin/Project/02.\ Fullstack\ Mobile\ App/2.\ Go\ \(Fiber\)\ +\ Flutter/markflow

gh auth login  # Follow prompts
git remote add origin https://github.com/Suyono-Sukorame/MarkFlow.git
git push -u origin main
```

---

## 🧹 Cleanup Keychain (if needed)

```bash
# Delete all GitHub credentials from Keychain
git credential-osxkeychain erase <<EOF
host=github.com
protocol=https

EOF

# Or open Keychain Access app
open -a "Keychain Access"
# Search for "github.com"
# Delete any github.com entries
```

---

## ⚠️ Important Notes

1. **NEVER commit Personal Access Token** to repository
2. **Add .gitignore** untuk sensitive files
3. **Use environment variables** untuk tokens
4. **Rotate tokens** regularly (every 90 days)

### Create .gitignore
```bash
cat > .gitignore << 'EOF'
# Credentials
*.key
*.pem
*.jks
.env
.env.local

# Build outputs
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# macOS
.DS_Store
EOF
```

---

## 📝 After Setup Success

Setelah berhasil push, Anda bisa:

```bash
# Check remote
git remote -v

# Check branch
git branch -a

# Check status
git status

# Future commits
git add .
git commit -m "Your commit message"
git push
```

---

## 🆘 Still Having Issues?

### Error: "Support for password authentication was removed"
→ **Use Personal Access Token**, not password!

### Error: "Permission denied (publickey)"
→ **SSH key** not added to GitHub or SSH agent

### Error: "Repository not found"
→ Check repository name and your access rights

### Error: "Authentication failed"
→ Clear keychain and use fresh token/SSH key

---

**Recommendation**: 🏆 **Use Personal Access Token (Solusi 1)**
- Paling mudah
- Tidak perlu setup SSH
- Works immediately
- Can be revoked easily

---

**Next Steps After Success**:
1. ✅ Push code ke GitHub
2. ✅ Setup GitHub Actions (optional)
3. ✅ Create releases
4. ✅ Enable GitHub Pages (for documentation)
5. ✅ Add README badges
