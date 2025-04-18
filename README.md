# macOS Offensive Toolkit

This repository contains modular components built to support macOS post-exploitation and red team operations. The focus is on minimal-touch, in-memory, and native approaches using Swift-based payloads and Mythic C2 integration.

---

## `chrome_debug`

**Author:** Matthew Trautman
**Platform:** macOS  
**Language:** Swift  
**Mythic Agent:** Hermes

### 🔍 Overview

Launches Google Chrome on the target with the **remote debugging port enabled**, allowing tools like [White Chocolate Macadamia Nut (WCMN)](https://github.com/slyd0g/WhiteChocolateMacademiaNut) to access Chrome session data using the DevTools Protocol. This enables high-value cookie/session theft without dropping payloads.

### 🧠 Behavior

- Kills any existing Chrome processes
- Waits a few seconds
- Relaunches Chrome with flags:
  - `--remote-debugging-port=9922`
  - `--restore-last-session`
  - `--user-data-dir=...`
  - `--remote-allow-origins=*`

### 🧪 Example Tasking
```json
chrome_debug {}
```

### ⚔️ Use Case
Use this to prep a macOS target for remote cookie/session extraction through:
- A `socks_proxy` Hermes command
- External tooling like WCMN (running from the C2 or dev box)

---

## `socks_proxy`

**Author:** Matthew Trautman
**Platform:** macOS  
**Language:** Swift  
**Mythic Agent:** Hermes

### 🔍 Overview

Creates a native **SOCKS5 proxy** listener on the target that routes connections from the operator through to the target machine. Used for post-exploitation tunneling (e.g. accessing Chrome DevTools at `127.0.0.1:9222`).

### 🧠 Behavior

- Starts a TCP listener (default port: `1080`, configurable)
- Implements SOCKS5 handshake and `CONNECT` handling
- Streams data bidirectionally between operator and internal target ports

### 🧪 Example Tasking
```json
socks_proxy {
  "port": "1080"
}
```

### ⚔️ Use Case
Use this to tunnel WCMN traffic or interact with internal-only macOS services without dropping payloads on disk.

---

## 🧱 Operational Flow

```text
[C2 Server]
 └─ WCMN (Go)
     └─ SOCKS5 ➝ Hermes agent (Swift)
             └─ 127.0.0.1:9222 (Chrome Debugging on Target)
```

---

## 📌 Notes

- Ensure Chrome is located in `/Applications`
- DevTools access only works while Chrome is running with the debug flag
- Use in conjunction with Mythic C2 for full visibility and chaining

---

## 📂 Coming Soon
- `launch_agent`: Persistent LaunchAgent installation

Stay tuned.
