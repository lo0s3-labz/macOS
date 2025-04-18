# Tips n' Tricks

Target User-Installed, Non-Hardened Apps:
find /Applications -type d -name "*.app" -exec codesign -dv --entitlements :- {} 2>/dev/null \; | grep -B 2 'com.apple.security.get-task-allow'
