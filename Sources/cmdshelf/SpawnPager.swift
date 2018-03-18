import Foundation
import Poxis

/// TODO: improve error handling
@discardableResult
func spawnPager(cmdString: String) -> Int32 {
    errno = 0
    guard let fpin = poxis_popen(cmdString, "r") else {
        return 1
    }
    guard let fpout = poxis_popen("${PAGER:-more}", "w") else {
        return 1
    }
    var line: [Int8] = []
    while fgets(&line, 4096, fpin) != nil {
        fputs(&line, fpout)// == EOF then error
    }
    poxis_pclose(fpout)
    return poxis_pclose(fpin)
}
