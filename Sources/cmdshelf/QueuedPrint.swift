import Dispatch
import Foundation

private let outputQueue: DispatchQueue = {
    let queue = DispatchQueue(
        label: "jp.toshi0383.cmdshelf.outputQueue",
        qos: .userInteractive,
        target: .global(qos: .userInteractive)
    )

    #if !os(Linux)
    atexit_b {
        queue.sync(flags: .barrier) {}
    }
    #endif

    return queue
}()

/**
 A thread-safe version of Swift's standard print().

 - parameter object: Object to print.
 */
public func queuedPrintln<T>(_ object: T) {
    outputQueue.async {
        print(object)
    }
}
public func queuedPrint<T>(_ object: T) {
    outputQueue.async {
        print(object, terminator: "")
    }
}

/**
 A thread-safe, newline-terminated version of fputs(..., stderr).

 - parameter string: String to print.
 */
public func queuedPrintlnError(_ string: String) {
    outputQueue.async {
        fflush(stdout)
        fputs(string + "\n", stderr)
    }
}
