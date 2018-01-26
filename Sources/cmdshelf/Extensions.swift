//
//  Extensions.swift
//  cmdshelf
//
//  Created by Toshihiro Suzuki on 2018/01/25.
//

import Foundation
import ObjectiveC

extension String {
    var standardizingPath: String {
        return NSString(string: self).standardizingPath as String
    }
}

extension FileManager {
    func isDirectory(_ path: String) -> Bool {
        var directory = ObjCBool(false)
        guard fm.fileExists(atPath: path, isDirectory: &directory) else {
            return false
        }
        #if os(Linux)
            return directory
        #else
            return directory.boolValue
        #endif
    }

}
