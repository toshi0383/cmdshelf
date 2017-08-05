import Foundation
import Reporter

func shellOutAndPrint(to: String, arguments: [String] = []) {
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

func shellOutAndGetResult(to: String, arguments: [String] = []) -> String? {
    let process = Process()
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", "\(to) \(arguments.joined(separator: " "))"]
    let outPipe = Pipe()
    var output = Data()
    outPipe.fileHandleForReading.readabilityHandler = { handler in
        output.append(handler.availableData)
    }
    process.standardOutput = outPipe
    process.launch()
    process.waitUntilExit()
    outPipe.fileHandleForReading.readabilityHandler = nil
    return String(data: output, encoding: .utf8)
}
