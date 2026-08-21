import Foundation

extension Date {
    var abbreviated: String {
        formatted(date: .abbreviated, time: .omitted)
    }
}
