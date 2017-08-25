import Foundation
import Reporter

@discardableResult
func silentShellOut(to: String, arguments: [String] = []) -> Int32 {
    return shellOut(to: to, arguments: arguments, shouldPrintStdout: false, shouldPrintError: false)
}

@discardableResult
func shellOut(to: String, arguments: [String] = [], shouldPrintStdout: Bool = true, shouldPrintError: Bool = true) -> Int32 {
    let process = Process()
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", "\(to) \(arguments.joined(separator: " "))"]
    #if !os(Linux)
    let inPipe = Pipe()
    inPipe.fileHandleForWriting.writeabilityHandler = { handler in
        if let d = readLine(strippingNewline: false)?.data(using: .utf8) {
            handler.write(d)
        } else {
            handler.closeFile()
        }
    }
    process.standardInput = inPipe
    #endif

    if !shouldPrintError {
        let pipe = Pipe()
        process.standardError = pipe
    }
    if !shouldPrintStdout {
        let pipe = Pipe()
        process.standardOutput = pipe
    }
    process.launch()
    process.waitUntilExit()
    #if !os(Linux)
    inPipe.fileHandleForWriting.writeabilityHandler = nil
    #endif
    return process.terminationStatus
}

