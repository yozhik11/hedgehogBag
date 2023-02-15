import Foundation

class Functions {
    func spaceInString(size: Int64) -> String {
        var space = ""
        switch size {
        case 0...((2 << 19) - 1):
            space = String(format: "%.2f", (Double(size) / Double(2 << 9))) + Constants.Texts.sizeKB
        case (2 << 19)...((2 << 29) - 1):
            space = String(format: "%.2f", (Double(size) / Double(2 << 19))) + Constants.Texts.sizeMB
        default:
            space = String(format: "%.2f", (Double(size) / Double(2 << 29))) + Constants.Texts.sizeGB
        }
        return space
    }
}
