# 🚀 DevOps GitOps Journey — Environment & Foundation Setup

> **Goal:** Set up a production-grade Linux environment and master the foundational skills every DevOps engineer uses daily.
> **Approach:** First-Principle Thinking + Project-Based Learning

---

## 📋 Table of Contents

- [Phase 0 — Environment Setup](#phase-0--environment-setup)
- [Phase 1 — Linux Core Skills](#phase-1--linux-core-skills)
- [Phase 2 — SSH & Server Security](#phase-2--ssh--server-security)
- [Phase 3 — Git & GitHub Professional Workflow](#phase-3--git--github-professional-workflow)

---

## Phase 0 — Environment Setup

> **First Principle:** Before touching any DevOps tool, you need a real Linux environment.
> We'll use WSL2 on Windows or a local Ubuntu VM. This is where everything runs.

### Which option should I use?

| Option | Best For | Notes |
|--------|----------|-------|
| **WSL2** | Windows users who want to start fast | Real Linux kernel on Windows |
| **Ubuntu VM** (VirtualBox/Multipass) | Closer to a real server experience | Can switch from WSL2 later |

> 💡 **Recommendation:** Pick WSL2 if you just want to start fast — you can switch later.

---

### Step 0.1 — Install WSL2 + Ubuntu 22.04

WSL2 gives you a real Linux kernel on Windows. Ubuntu 22.04 LTS is the industry standard for DevOps work.

```powershell
# On Windows PowerShell (Run as Administrator):
wsl --install -d Ubuntu-22.04
wsl --set-default-version 2
```

```bash
# Or install Multipass (cross-platform VM):
# Download from: https://multipass.run

multipass launch 22.04 --name devops-lab --cpus 2 --memory 4G --disk 20G
multipass shell devops-lab
```

---

### Step 0.2 — Update Ubuntu and Install Essential Tools

> Always update before installing anything. These packages are your daily driver tools as a DevOps engineer.

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
  curl wget git vim nano tree \
  htop net-tools nmap unzip jq \
  build-essential software-properties-common \
  apt-transport-https

# Verify Git is installed
git --version
```

---

### Step 0.3 — Install and Configure Zsh + Oh-My-Zsh *(Optional but Recommended)*

> Zsh with autosuggestions saves hours over a month. Professional DevOps engineers use it universally.

```bash
# Install Zsh
sudo apt install -y zsh

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Edit `~/.zshrc` and update the plugins line:

```bash
# Find this line in ~/.zshrc and update it:
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

```bash
# Apply changes
source ~/.zshrc
```

---

## Phase 1 — Linux Core Skills

> **First Principle:** Linux treats everything as a file — your network interface, your processes,
> your hardware. Mastering the filesystem IS mastering Linux.
>
> Don't just memorize commands. Ask yourself: **WHY** does Linux have a filesystem hierarchy?
> **WHY** do permissions exist? Understanding the "why" means you can debug anything.

---

### Step 1.1 — Explore the Linux Filesystem Hierarchy (FHS)

> Every path in DevOps makes sense once you know FHS.
> `/etc` = config, `/var` = variable data/logs, `/opt` = optional software, `/proc` = live kernel data.

```bash
ls /          # root of the filesystem
ls /etc       # all system configuration files
ls /var/log   # system log files
ls /proc      # virtual filesystem — live kernel/process info

cat /proc/cpuinfo    # CPU information
cat /proc/meminfo    # Memory information

ls /opt       # where you'll install Docker, K8s tools etc.
```

**Key directories to know:**

| Directory | Purpose |
|-----------|---------|
| `/etc` | System configuration files |
| `/var/log` | Log files (syslog, auth.log, etc.) |
| `/opt` | Optional/third-party software |
| `/proc` | Live kernel and process data |
| `/home` | User home directories |
| `/tmp` | Temporary files (cleared on reboot) |
| `/usr/bin` | User-installed binaries |
| `/usr/local/bin` | Manually installed binaries |

---

### Step 1.2 — Master File Permissions and Ownership

> 90% of "permission denied" errors in DevOps come from not understanding this. Know it cold.

```bash
# Create a test file and inspect it
touch testfile.sh
ls -la testfile.sh
# Output: -rw-r--r-- 1 user group size date name
#          ↑↑↑ ↑↑↑ ↑↑↑
#          owner group others

# chmod: change permissions
chmod +x testfile.sh       # add execute for all
chmod 755 testfile.sh      # rwxr-xr-x (owner=7, group=5, others=5)
chmod 600 secret.txt       # rw------- (private file, like SSH keys)

# chown: change ownership
sudo chown root:root testfile.sh
sudo chown $USER:$USER testfile.sh
```

**Permission number reference:**

| Number | Permission | Meaning |
|--------|-----------|---------|
| `7` | `rwx` | Read + Write + Execute |
| `6` | `rw-` | Read + Write |
| `5` | `r-x` | Read + Execute |
| `4` | `r--` | Read only |
| `0` | `---` | No permissions |

> 💡 **Formula:** r=4, w=2, x=1 → add them together for each group (owner/group/others)

---

### Step 1.3 — Process Management

> When a container or service hangs, you need to find and kill processes. This is daily DevOps work.

```bash
ps aux                     # all running processes
ps aux | grep nginx        # find a specific process
top                        # interactive process monitor (press q to quit)
htop                       # better version of top

# Start a background job and manage it
sleep 300 &                # run in background
jobs                       # list background jobs
pgrep sleep                # get PID of sleep
kill -15 $(pgrep sleep)    # graceful stop (SIGTERM)
kill -9 <PID>              # force kill (SIGKILL) — last resort

# systemd service management
sudo systemctl status ssh
sudo systemctl start ssh
sudo systemctl enable ssh  # start on boot
sudo systemctl restart ssh
sudo systemctl stop ssh
```

**Signal reference:**

| Signal | Number | Use Case |
|--------|--------|----------|
| `SIGTERM` | 15 | Graceful shutdown (try this first) |
| `SIGKILL` | 9 | Force kill (last resort) |
| `SIGHUP` | 1 | Reload config without restart |

---

### Step 1.4 — Disk, Memory and Network Diagnostics

> These are the commands you run when a production server is acting up. Know them by heart.

```bash
# Disk
df -h                          # disk space (human-readable)
du -sh /var/log                # size of a directory
du -sh /* 2>/dev/null | sort -h  # find biggest directories

# Memory
free -h                        # RAM and swap usage
vmstat 1 5                     # CPU/memory stats every 1s, 5 times

# Network
ip addr                        # IP addresses (replaces ifconfig)
ip route                       # routing table
ss -tlnp                       # listening ports (replaces netstat)
curl -I https://google.com     # test HTTP connectivity
ping -c 4 8.8.8.8              # test network connectivity
```

---

### Step 1.5 — Text Processing with grep, awk, sed, cut

> Log analysis, config file editing, pipeline output parsing — these tools are used every single day in DevOps.

```bash
# grep: search for patterns
grep "error" /var/log/syslog
grep -i "failed" /var/log/auth.log   # case insensitive
grep -r "TODO" ./scripts/            # recursive search

# awk: process columns of text
ps aux | awk '{print $1, $2, $11}'        # user, PID, command
df -h | awk 'NR>1 {print $5, $6}'        # skip header, print use% + mount

# sed: stream editor — find and replace
sed 's/old/new/g' file.txt                # replace all occurrences
sed -i 's/localhost/0.0.0.0/g' app.conf  # edit file in-place

# cut: extract columns
cut -d':' -f1 /etc/passwd                # list all usernames
```

---

### Step 1.6 — User Management and Sudo

> DevOps engineers manage service accounts, CI runner users, and application users on servers constantly.

```bash
# Create a deploy user (like a CI/CD runner would use)
sudo useradd -m -s /bin/bash deployuser
sudo passwd deployuser
sudo usermod -aG sudo deployuser   # add to sudo group
id deployuser                      # verify groups

# Switch users
su - deployuser
exit

# View all real users
cat /etc/passwd | grep -v nologin | grep -v false
```

---

## Phase 2 — SSH & Server Security

> **Critical:** Never use password authentication in production. Always use SSH keys.
> GitHub, cloud servers, and all CI systems use key-based auth.
>
> SSH key authentication is the foundation of all automated DevOps work — CI/CD pipelines,
> Ansible, remote kubectl, everything. Get this right now.

---

### Step 2.1 — Generate an SSH Key Pair (Ed25519)

> Ed25519 is the modern, fast, and secure algorithm. RSA is legacy.
> You'll use this same key for GitHub, AWS EC2, and all remote servers.

```bash
# Generate Ed25519 key (replace with your actual email)
ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/id_ed25519

# View your public key (this is what you share)
cat ~/.ssh/id_ed25519.pub

# View private key file (NEVER share this — guard it like a password)
ls -la ~/.ssh/id_ed25519      # should be -rw------- (600)

# Fix permissions if needed
chmod 600 ~/.ssh/id_ed25519
chmod 700 ~/.ssh

# Start SSH agent and add your key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l                    # verify key is added
```

> ⚠️ **Rule:** Your private key (`id_ed25519`) NEVER leaves your machine.
> Your public key (`id_ed25519.pub`) is what you share with servers and GitHub.

---

### Step 2.2 — Add Your SSH Public Key to GitHub

> This lets you push/pull from GitHub without typing a password — essential for CI/CD automation.

```bash
# Copy your public key output
cat ~/.ssh/id_ed25519.pub
```

Then on GitHub:

```
1. GitHub.com → Settings (top right avatar)
2. SSH and GPG keys → New SSH key
3. Title: "DevOps Lab - WSL2" (or your machine name)
4. Key type: Authentication Key
5. Paste your public key content → Add SSH key
```

```bash
# Test the connection
ssh -T git@github.com
# Expected output: "Hi username! You've successfully authenticated..."
```

---

### Step 2.3 — Create and Configure `~/.ssh/config`

> When you have multiple GitHub accounts or multiple servers, SSH config lets you manage
> them cleanly without memorizing hostnames.

```bash
# Create SSH config file
nano ~/.ssh/config
```

Add these entries:

```
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes

# Your DevOps Lab VM (update IP to your actual VM IP)
Host devops-lab
    HostName 192.168.1.100
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519
    Port 22
```

```bash
# Secure the config file
chmod 600 ~/.ssh/config
```

Now you can SSH to your lab with just:

```bash
ssh devops-lab
# instead of: ssh -i ~/.ssh/id_ed25519 ubuntu@192.168.1.100
```

---

### Step 2.4 — Configure UFW Firewall on Ubuntu

> Every server you deploy will need a firewall. UFW is Ubuntu's simplified frontend for iptables.
> This pattern repeats on every EC2 instance you create in AWS.

```bash
sudo apt install -y ufw

# Set default policies — deny all incoming, allow all outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow only what you need
sudo ufw allow ssh        # port 22
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS

# Enable firewall
sudo ufw enable

# Verify status
sudo ufw status verbose
```

> 💡 **Production rule:** Only open the ports you actively need.
> On AWS, you'll do this with Security Groups instead of UFW, but the logic is identical.

---

## Phase 3 — Git & GitHub Professional Workflow

> **GitOps Principle:** Every change goes through a Pull Request — even when working alone.
> This is the habit that makes GitOps click later.
>
> Git is the backbone of GitOps. You need to know it beyond just "add, commit, push".
> We'll practice the exact workflow used in professional DevOps teams.

---

### Step 3.1 — Configure Git Identity and Global Settings

> Every commit is signed with your identity. Teams use this for accountability and code review attribution.

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global core.editor "vim"         # or nano
git config --global init.defaultBranch main
git config --global pull.rebase false

# Set up credential helper
git config --global credential.helper store

# Verify all settings
git config --list --global
```

---

### Step 3.2 — Create Your GitHub Repo and Clone It

> This will become your portfolio project. Name it clearly — recruiters will look at this.

On GitHub.com:

```
1. Click "+" → New repository
2. Name: devops-gitops-journey
3. Description: "4-month GitOps DevOps learning journey"
4. Visibility: Public (portfolio visibility)
5. ✓ Initialize with a README
6. Click "Create repository"
```

```bash
# Clone your new repo
git clone git@github.com:YOUR_USERNAME/devops-gitops-journey.git
cd devops-gitops-journey

# Create the full project folder structure
mkdir -p projects/01-linux-git/{scripts,docs,configs}
touch projects/01-linux-git/README.md
touch projects/01-linux-git/docs/learnings.md
touch projects/01-linux-git/configs/.gitkeep

# Verify the structure
ls -la projects/01-linux-git/
```

Your structure should look like:

```
devops-gitops-journey/
├── projects/
│   └── 01-linux-git/
│       ├── README.md
│       ├── scripts/
│       ├── docs/
│       │   └── learnings.md
│       └── configs/
│           └── .gitkeep
└── README.md
```

---

### Step 3.3 — Practice the Branch → Commit → PR Workflow

> You will do this workflow thousands of times. Building the muscle memory now is the goal.

```bash
# ALWAYS create a branch before making changes
git checkout -b feat/linux-scripts

# Write a health check script
cat > projects/01-linux-git/scripts/health-check.sh <<'EOF'
#!/bin/bash
set -euo pipefail

echo "=== System Health Report ==="
echo "Date:     $(date)"
echo "Hostname: $(hostname)"
echo "Uptime:   $(uptime -p)"
echo "CPU Load: $(cat /proc/loadavg | awk '{print $1,$2,$3}')"
echo "Memory:   $(free -h | awk '/^Mem:/ {print $3"/"$2}')"
echo "Disk:     $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5" used)"}')"
echo "==========================="
EOF

chmod +x projects/01-linux-git/scripts/health-check.sh

# Use conventional commit format: type(scope): message
git add .
git commit -m "feat(linux): add system health check script"
git push origin feat/linux-scripts
```

Then on GitHub:
```
1. You'll see "Compare & pull request" button — click it
2. Title: "feat(linux): add system health check script"
3. Description: what you changed and why
4. Click "Create pull request"
5. Click "Merge pull request" → "Confirm merge"
6. Delete the branch
```

```bash
# Back in terminal — sync your local main
git checkout main
git pull origin main
```

---

### Step 3.4 — Create a `.gitignore` File

> Committing secrets, credentials, or large binaries is one of the worst mistakes in DevOps.
> Build this habit now.

```bash
# Create a branch first (following the PR workflow)
git checkout -b chore/add-gitignore

# Create the .gitignore file
cat > .gitignore <<'EOF'
# ─── Secrets — NEVER commit these ────────────────────────────────
*.pem
*.key
*.env
.env*
secrets/
credentials/

# ─── OS files ─────────────────────────────────────────────────────
.DS_Store
Thumbs.db

# ─── Editors ──────────────────────────────────────────────────────
.vscode/
.idea/
*.swp
*.swo

# ─── Build artifacts ──────────────────────────────────────────────
node_modules/
__pycache__/
*.pyc
dist/
build/

# ─── Terraform state (contains secrets!) ──────────────────────────
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl
EOF

git add .gitignore
git commit -m "chore: add comprehensive .gitignore"
git push origin chore/add-gitignore
```

Open a PR on GitHub, merge it, then sync locally:

```bash
git checkout main
git pull origin main
```

---

### Step 3.5 — Set Up Branch Protection Rules on GitHub

> This enforces the PR workflow. No one can push directly to `main` — every change needs review.
> Start building this discipline solo.

On GitHub.com:

```
1. Your repo → Settings → Branches
2. Click "Add branch protection rule"
3. Branch name pattern: main
4. Enable these options:
   ✓ Require a pull request before merging
   ✓ Require at least 1 approval (skip for solo work)
   ✓ Do not allow bypassing the above settings
5. Click "Create"
```

Test that it's working:

```bash
# Try pushing directly to main (should be REJECTED)
git checkout main
echo "test direct push" >> README.md
git add .
git commit -m "test: direct push to main"
git push origin main
# Expected: ERROR — push rejected

# Undo that commit cleanly
git reset HEAD~1
git checkout -- README.md
```

---

## 🗂️ Conventional Commit Reference

Use this format for every commit throughout your journey:

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature or script | `feat(linux): add health check script` |
| `fix` | Bug fix | `fix(ssh): correct key permissions` |
| `chore` | Maintenance, configs | `chore: add .gitignore` |
| `docs` | Documentation only | `docs: update Phase 1 learnings` |
| `refactor` | Code restructure, no feature change | `refactor(scripts): extract functions` |
| `test` | Adding tests | `test: add health check unit test` |
| `ci` | CI/CD pipeline changes | `ci: add GitHub Actions workflow` |

---

## 📚 Key Resources

| Topic | Resource | Type |
|-------|----------|------|
| Linux fundamentals | [Missing Semester — MIT](https://missing.csail.mit.edu) | Free course |
| Interactive Linux | [Linux Journey](https://linuxjourney.com) | Interactive |
| Bash scripting | [Bash Guide](https://mywiki.wooledge.org/BashGuide) | Reference |
| Git internals | [Pro Git Book](https://git-scm.com/book/en/v2) | Free book |
| Visual Git | [Learn Git Branching](https://learngitbranching.js.org) | Interactive |
| SSH guide | [SSH Academy](https://www.ssh.com/academy/ssh) | Reference |

---

## ✅ Phase Completion Checklist

### Phase 0
- [ ] WSL2 or Ubuntu VM running
- [ ] Essential tools installed (`git --version` works)
- [ ] Zsh + Oh-My-Zsh configured (optional)

### Phase 1
- [ ] Can explain FHS without looking it up
- [ ] Can set file permissions from memory
- [ ] Can find and kill a process
- [ ] Can diagnose disk/memory/network issues
- [ ] Can use grep/awk/sed to parse log files

### Phase 2
- [ ] Ed25519 SSH key generated
- [ ] Public key added to GitHub
- [ ] `ssh -T git@github.com` returns success
- [ ] `~/.ssh/config` created and working
- [ ] UFW firewall configured and enabled

### Phase 3
- [ ] Git global config set
- [ ] Repo cloned via SSH (not HTTPS)
- [ ] First PR merged via branch workflow
- [ ] `.gitignore` in place with secrets patterns
- [ ] Branch protection enabled on `main`
- [ ] First commit pushed with conventional commit format

---

*Generated as part of the 4-Month DevOps GitOps Learning Journey*
*Repository: [devops-gitops-journey](https://github.com/YOUR_USERNAME/devops-gitops-journey)*