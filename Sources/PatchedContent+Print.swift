// MARK: - Pretty printing for PatchedContent

//public extension PatchedContent where A: CustomStringConvertible, Address: CustomStringConvertible {
//    func prettyPrint(callLevel: Int = 2) {
//
//        let spaces = String(repeating: " ", count: callLevel)
//
//        if callLevel == 2 { print("========================") }
//
//        func printPatchItems() {
//            if contentPatches.isEmpty {
//                print()
//                return
//            }
//            for item in contentPatches {
//                var addr: String = ""
//                var actionName: String = ""
//                if let patchSpec = item.patchSpec {
//                    switch patchSpec {
//                    case let .replace(address),
//                        let .delete(address),
//                        let .add(address):
//
//                        addr = "\(address)"
//
//                    case let .jsonPatch(op, address):
//                        addr = "[\(op) \(address) (JPatch)]"
//
//                    }
//                    actionName = "\(patchSpec)"
//                }
//                print("\(spaces)  At addr: |\(addr)| \(actionName):") // , terminator: "")
//                item.contentPatch?.prettyPrint(callLevel: callLevel + 4)
//            }
//        }
//
//        print("\(spaces)Content: |\(content)|", terminator: "")
//        printPatchItems()
//
//        if callLevel == 2 { print("========================\n\n") }
//    }
//}
