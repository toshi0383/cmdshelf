import Foundation

// FIXME: Not working really.
func validURL(_ string: String) throws -> String {
    guard let _ = URL(string: string) else {
        throw CmdshelfError("Invalid URL.")
    }
    return string
}
