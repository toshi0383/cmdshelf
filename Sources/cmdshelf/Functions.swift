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
    let stdoutHandler: (FileHandle) -> Void = { handler in
        let data = handler.availableData
        if let str = String(data: data, encoding: .utf8) {
            queuedPrint(str)
        }
    }
    let stdout = Pipe()
    stdout.fileHandleForReading.readabilityHandler = stdoutHandler
    try shellOut(to: to, arguments: arguments, outputHandle: stdout.fileHandleForWriting)
    queuedPrintln("")
}
