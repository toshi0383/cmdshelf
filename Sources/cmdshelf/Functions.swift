import Foundation
import Reporter

@discardableResult
func silentShellOut(to: String, argument: String? = nil) -> Int32 {
    return shellOut(to: to, argument: argument, shouldPrintStdout: false, shouldPrintError: false)
}

@discardableResult
func shellOut(to: String, argument: String? = nil, shouldPrintStdout: Bool = true, shouldPrintError: Bool = true) -> Int32 {
    let process = Process()
    process.launchPath = "/bin/bash"
    if let arg = argument {
        process.arguments = ["-c", "\(to) \(arg)"]
    } else {
        process.arguments = ["-c", "\(to)"]
    }
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
