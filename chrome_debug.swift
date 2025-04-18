import Foundation

func launchChromeWithDebugging() {
    let chromePath = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    let userDataDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/Google/Chrome")
        .path
    // Step 1: Kill existing Chrome
    let kill = Process()
    kill.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
    kill.arguments = ["Google Chrome"]
    // Step 2: Wait a bit (Chrome needs time to release files)
    let waitTime: UInt32 = 4
    // Step 3: Launch Chrome with debugging flags
    let launch = Process()
    launch.executableURL = URL(fileURLWithPath: chromePath)
    launch.arguments = [
        "--remote-debugging-port=9922",
        "--force-happiness-tracking-system",
        "--user-data-dir=\(userDataDir)",
        "--remote-allow-origins=*",
        "--restore-last-session"
    ]

    do {
        try kill.run()
        kill.waitUntilExit()
        print("[+] Killed Chrome, waiting \(waitTime) seconds...")
        sleep(waitTime)
        try launch.run()
        print("[+] Launched Chrome with remote debugging enabled.")
    } catch {
        print("[-] Failed to launch Chrome: \(error)")
    }
}

launchChromeWithDebugging()
