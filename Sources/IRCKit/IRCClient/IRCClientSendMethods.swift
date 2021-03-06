/*
 Copyright 2020 The Fuel Rats Mischief
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
 disclaimer in the documentation and/or other materials provided with the distribution.
 
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote
 products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

extension IRCClient {
    func sendRegistration () {
        if let password = self.configuration.serverPassword {
            self.send(command: .PASS, parameters: [password])
        }
        self.send(command: .USER, parameters: [self.configuration.username, "0", "*", self.configuration.realName])
        self.sendNicknameChange(nickname: self.configuration.nickname)
        self.send(command: .CAP, parameters: ["LS", "302"])
        if self.monitor.count > 0 && self.serverInfo.supportsMonitor {
            self.sendMonitor(addTargets: self.monitor)
        }
    }

    public func sendJoin (channels: [String]) {
        var channels = channels
        while channels.count > 0 {
            let chunkSize = min(channels.count, 10)
            let joinChunk = Array(channels[0 ..< chunkSize])
            channels.removeFirst(chunkSize)
            self.send(command: .JOIN, parameters: joinChunk.joined(separator: ","))
        }
    }

    public func sendJoin (channelName: String) {
        self.send(command: .JOIN, parameters: [channelName])
    }

    public func sendNicknameChange (nickname: String) {
        self.send(command: .NICK, parameters: [nickname])
    }

    public func sendPart (channel: IRCChannel, message: String = "") {
        self.sendPart(channelName: channel.name)
    }

    public func sendPart (channelName: String, message: String = "") {
        self.send(command: .PART, parameters: [channelName, message])
    }

    public func sendQuit (message: String = "") {
        self.send(command: .QUIT, parameters: [message])
    }

    public func requestIRCv3Capabilities (capabilities: [IRCv3Capability]) {
        guard capabilities.count > 0 else {
            return
        }
        let capString = capabilities.map({
            $0.rawValue
        }).joined(separator: " ")

        self.send(command: .CAP, parameters: ["REQ", capString])
    }

    public func sendAuthenticate (message: String) {
        self.send(command: .AUTHENTICATE, parameters: [message])
    }

    public func sendMessage (toChannel channel: IRCChannel, contents: String) {
        self.sendMessage(toChannelName: channel.name, contents: contents)
    }

    public func sendMessage (toChannelName channelName: String, contents: String) {
        if self.hasIRCv3Capability(.labeledResponses) {
            self.send(command: .PRIVMSG, parameters: [channelName, contents])
        } else {
            self.send(command: .PRIVMSG, parameters: [channelName, contents])
        }
    }

    public func sendActionMessage(toChannel channel: IRCChannel, contents: String) {
        self.sendActionMessage(toChannelName: channel.name, contents: contents)
    }

    public func sendActionMessage(toChannelName channelName: String, contents: String) {
        self.send(command: .PRIVMSG, parameters: [channelName, "\u{001}ACTION \(contents)\u{001}"])
    }

    public func sendCTCPRequest(toChannel channel: IRCChannel, contents: String) {
        self.send(command: .PRIVMSG, parameters: [channel.name, "\u{001}\(contents)\u{001}"])
    }

    public func sendNotice (toTarget target: String, contents: String) {
        self.send(command: .NOTICE, parameters: [target, contents])
    }

    public func sendMonitor (addTargets targets: Set<String>) {
        self.send(command: .MONITOR, parameters: "+", targets.joined(separator: ","))
    }

    public func sendMonitor (removeTargets targets: Set<String>) {
        self.send(command: .MONITOR, parameters: "-", targets.joined(separator: ","))
    }

   public func sendMonitorClear () {
        self.send(command: .MONITOR, parameters: "C")
    }

    public func sendMonitorListRequest () {
        self.send(command: .MONITOR, parameters: "L")
    }

    public func sendMonitorStatusRequest () {
        self.send(command: .MONITOR, parameters: "S")
    }
}
