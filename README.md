# macOS
macOS OffSec Work
- chrome_debug
- socks_proxy
- persistence


## chrome_debug

**Author:** Matthew Trautman
**Platform:** macOS  
**Language:** Swift  
**Agent:** Hermes

---

### Description

`chrome_debug` is a Hermes command that launches Google Chrome on the target macOS system with the **remote debugging port enabled**, allowing tools like [White Chocolate Macadamia Nut (WCMN)](https://github.com/outflanknl/WCMN) to access Chrome session data via the DevTools Protocol.

This enables cookie/session extraction without writing any payloads to disk on the target.

---

### Behavior

- Kills all existing instances of Chrome
- Waits briefly to ensure all processes are closed
- Relaunches Chrome with:
  - `--remote-debugging-port=9922`
  - `--restore-last-session`
  - `--user-data-dir` to persist login sessions
  - `--remote-allow-origins=*` for unrestricted DevTools access

---

### Example Mythic Tasking

```json
chrome_debug {}
```

---

### Typical Use Case

Used in combination with:
- [`socks_proxy`](../socks_proxy) to forward DevTools traffic from the operator box to the target
- `WCMN` or other DevTools-based session stealers running remotely

---

### Operational Flow

```text
[C2 Server]
 └─ WCMN (Go)
     └─ SOCKS5 proxy ➝ Hermes agent
             └─ localhost:9922 (target Chrome DevTools)
```

---

### Notes

- Ensure Chrome is installed in `/Applications`
- Verify Chrome was launched with the correct user data directory
- Confirm no pop-ups or restore dialogs interfere with session state
