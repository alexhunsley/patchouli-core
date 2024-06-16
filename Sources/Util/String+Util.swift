import Foundation

public extension String {
    func prefixing(_ match: String, with prefix: String) -> String {
        self.replacingOccurrences(of: match, with: prefix + match)
    }
}

public extension Data {
    func string() -> String {
        String(decoding: self, as: UTF8.self)
    }
}
