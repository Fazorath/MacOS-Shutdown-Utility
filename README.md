# macOS Shutdown Shortcut

A tiny utility to schedule an exact-time **shutdown** on macOS using either the **Shortcuts app** or the **command line**.

---

## ✨ Features
- Accepts both **12-hour** (`11:25 PM`, `7pm`) and **24-hour** (`23:25`, `7:05`) input.  
- Auto-rollover to **tomorrow** if the time already passed today.  
- Compensates for macOS’s **10-minute shutdown grace** so the machine powers off at the exact time you typed.  
- Includes a one-click **Cancel** shortcut to clear scheduled shutdowns.  
- Works silently (no password prompts) with a minimal `sudoers` entry.

---

## ⚙️ Installation

### 1. Clone the repo
```bash
git clone https://github.com/Fazorath/MacOS-Shutdown-Utility.git
cd MacOS-Shutdown-Utility
```

### 2. Allow passwordless `pmset`
Open `visudo`:
```bash
sudo visudo
```

Add one of the following (replace `yourusername`):

```text
# General (simplest)
yourusername ALL=(ALL) NOPASSWD: /usr/bin/pmset

# Or narrower (still works for this repo):
yourusername ALL=(ALL) NOPASSWD: /usr/bin/pmset schedule shutdown *, /usr/bin/pmset schedule cancelall
```

### 3. Test
```bash
sudo -n /usr/bin/pmset -g sched
```
→ Should **not** prompt for a password.

---

## 🚀 Usage

### Command line
```bash
# Schedule shutdown (auto-compensates 10 minutes early)
./scripts/schedule-shutdown.sh "11:25 PM"

# Exact shutdown (no compensation)
./scripts/schedule-shutdown.sh "23:10" --exact

# Cancel all scheduled events
./scripts/cancel-shutdown.sh

# View current schedules
./scripts/list-schedules.sh
```

### Developer tip
- From repo root:  
  ```bash
  ./scripts/schedule-shutdown.sh "11:25 PM"
  ```
- From inside `scripts/`:  
  ```bash
  ./schedule-shutdown.sh "11:25 PM"
  ```

If you see “permission denied”, you cloned before the exec bit was committed; run:
```bash
chmod +x scripts/*.sh
```

---

## 📱 Shortcuts app

You can also use this inside the macOS Shortcuts app for a friendly UI.

### Schedule Shutdown Shortcut
1. **Ask for Text**  
   - Prompt: `Shutdown time (e.g., 11:25 PM or 23:25)`  
   - *Allow Multiple Lines*: **Off**
2. **Run Shell Script**  
   - Shell: `bash`  
   - Script: `/absolute/path/to/repo/scripts/schedule-shutdown.sh`  
   - Input: **Ask for Text** (the blue token)  
   - Pass Input: **as arguments**
3. **Show Notification**  
   - Title: `Schedule Shutdown` (optional)  
   - Text: **Shell Script Result**

### Cancel Shutdown Shortcut
1. **Run Shell Script**  
   - Script: `/absolute/path/to/repo/scripts/cancel-shutdown.sh`
2. **Show Notification**  
   - Text: **Shell Script Result**

Export them as `.shortcut` files if you want to share.  
➡️ **After importing a Shortcut, edit the “Run Shell Script” block and point it to the path of your local repo’s script.**

---

## 📝 Why compensation?

On macOS, `pmset schedule shutdown "<datetime>"` starts a **10-minute countdown** at that time.  
This utility subtracts 10 minutes by default, so the machine powers off at the exact time you enter.  

Pass `--exact` if you want no compensation.

---

## 🔒 Safety

- This utility only uses `/usr/bin/pmset`.  
- The sudoers entry is minimal and cannot be abused to run other commands.  
- You can remove the entry anytime via `sudo visudo`.  
- Always test with:
  ```bash
  ./scripts/cancel-shutdown.sh
  ```

---

## ✅ Requirements
- macOS (with `/usr/bin/pmset`)  
- Admin user account (to edit `sudoers`)  
- Bash (macOS default is fine)

---

## 📜 License
MIT — see [`LICENSE`](LICENSE)

---

## 🤝 Contributing
PRs and issues welcome! Please include:
- macOS version
- What command/Shortcut you ran
- Output of `pmset -g sched`
