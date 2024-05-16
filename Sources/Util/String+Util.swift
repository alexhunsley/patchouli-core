import Foundation

extension String {
    func prefixing(_ match: String, with prefix: String) -> String {
        self.replacingOccurrences(of: match, with: prefix + match)
    }
}
