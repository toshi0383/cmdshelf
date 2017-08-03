import Foundation
import Reporter
import ShellOut

func safeShellOutAndPrint(to: String, arguments: [String] = []) {
    do {
        try shellOutAndPrint(to: to, arguments: arguments)
    } catch {
        let error = error as! ShellOutError
        queuedPrintlnError(error.message) // Prints STDERR
        queuedPrintln(error.output) // Prints STDOUT
    }
}

func shellOutAndPrint(to: String, arguments: [String] = []) throws {
    let process = Process()
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", "\(to) \(arguments.joined(separator: " "))"]
    let inPipe = Pipe()
    inPipe.fileHandleForWriting.writeabilityHandler = { handler in
        if let d = readLine(strippingNewline: false)?.data(using: .utf8) {
            handler.write(d)
        } else {
            handler.closeFile()
        }
    }

    process.standardInput = inPipe
    process.launch()
    process.waitUntilExit()
    inPipe.fileHandleForWriting.writeabilityHandler = nil
}
