# NexH4ck 🔥

**NexH4ck** is an **authorized Termux security lab terminal** — a curated,
ROE-first catalog of security tools (recon, scan, web, password, wireless)
that **lite-installs** them from the official Termux packages, pip and git on
demand. No 563MB bundled payload, no shell-command hijacking.

It merges the **i-Haklab** style tool-catalog menu with the **termuxvoid /
APT** lite-install model, wrapped in a **cyberpunk neon** interface.

> Crafted by [**@Daemon-018**](https://github.com/Daemon-018). MIT licensed.

![Shell](https://img.shields.io/badge/shell-bash-black.svg)
![Termux](https://img.shields.io/badge/platform-Termux%20(Android)-00897b.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

---

## ⚠️ ROE-FIRST — read this

```
Only test systems you OWN or are EXPLICITLY AUTHORIZED to test.
```

NexH4ck **never overrides** your core shell commands (`apt`, `ls`, `sudo`)
and ships **no** phishing / credential-harvesting / ransomware payloads.
Each tool listed is installed from its original upstream source. **Don't
trust, verify** — read a package's install script before running it.

---

## Install

The fastest way (via our own APT repo):

```bash
# 1. add the NexH4ck repo + signing key
curl -fsSL https://raw.githubusercontent.com/Daemon-018/nexh4ck-repo/main/install.sh | bash

# 2. install
pkg install nexh4ck
```

Or build + install from source:

```bash
git clone https://github.com/Daemon-018/NexH4ck.git
cd NexH4ck
bash build-deb.sh          # builds nexh4ck_<ver>_all.deb
dpkg -i nexh4ck_*.deb
```

---

## Usage

```
nexh4ck                 help
nexh4ck list            list all tools by category
nexh4ck search <name>   find a tool
nexh4ck info <tool>     show description + install source
nexh4ck install <tool>  lite-install from termux-main / pip / git
nexh4ck run <tool>      launch a tool
nexh4ck ssh             SSH server starter (tmxssh feature)
```

Example:

```bash
nexh4ck list                          # see everything
nexh4ck info sqlmap                   # what it is + how to install
nexh4ck install nmap                  # pkg install nmap -y
nexh4ck run nmap -sV 192.168.1.5      # scan your OWN host
```

## Tool categories

| Category  | Examples |
|-----------|----------|
| `recon`   | nmap, sherlock, amass, recon-ng, dnsrecon, theHarvester |
| `scan`    | sqlmap, nikto, nuclei, wpscan, gobuster |
| `web`     | thc-hydra, dirb, whatweb, wfuzz |
| `passwd`  | john, cewl, hashcat |
| `wireless`| aircrack-ng (own networks) |
| `util`    | metasploit-framework, hexmind, nexh4ck-ssh |

New tools are just one line in the catalog (`~/.nexh4ck/catalog.conf`).

---

## How it's built

- **`nexh4ck`** — the tool (bash, self-contained)
- **`build-deb.sh`** — builds the `.deb` package
- **`build-repo.sh`** — builds the signed APT repo (dists layout)
- **`nexh4ck-repo/`** — the generated APT repo (also hosted at
  [Daemon-018/nexh4ck-repo](https://github.com/Daemon-018/nexh4ck-repo))

## APT repo

Our own signed Termux APT repository, termuxvoid-style:

```
deb [arch=all] https://daemon-018.github.io/nexh4ck-repo nexh4ck main
```

See [Daemon-018/nexh4ck-repo](https://github.com/Daemon-018/nexh4ck-repo) for
details and the signing key.

---

## License

MIT — free to use, modify, and share.
