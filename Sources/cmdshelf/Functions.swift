import Foundation
import Poxis
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

/// TODO: improve error handling
@discardableResult
func spawnPager(cmdString: String) -> Int32 {
    errno = 0
    guard let fpin = poxis_popen(cmdString, "r") else {
        return 1
    }
    guard let fpout = poxis_popen("more", "w") else {
        return 1
    }
    var line: [Int8] = []
    while fgets(&line, 4096, fpin) != nil {
        fputs(&line, fpout)// == EOF then error
    }
    poxis_pclose(fpout)
    return poxis_pclose(fpin)
}
