# Tips n' Tricks

Target User-Installed, Non-Hardened Apps:
```
find /Applications -type d -name "*.app" -exec codesign -dv --entitlements :- {} 2>/dev/null \; | grep -B 2 'com.apple.security.get-task-allow'
``` 

Check ALL /usr/local/bin for unsigned, non-hardened binaries
```
find /usr/local/bin -type f -perm +111 -exec sh -c \
'echo -n "{}: "; codesign -dv "{}" 2>&1 | grep -q "code object is not signed" && echo "NOT SIGNED" || echo "SIGNED"' \;
```

Scanner to find unsigned, non-hardened binaries:
```
find /Applications /usr/local/bin /opt/homebrew/bin ~/Applications ~/Downloads ~/go/bin -type f -perm +111 2>/dev/null | while read f; do
  if codesign -dv "$f" 2>&1 | grep -q "code object is not signed"; then
    echo "[UNSIGNED] $f"
  fi
done
```
