import Foundation

struct Attempt: Identifiable, Codable, Equatable {
    let id: UUID
    var recipe: String
    var source: String
    var rating: Int
    var notes: String
    var createdAt: Date

    init(id: UUID = UUID(), recipe: String = "", source: String = "", rating: Int = 0, notes: String = "", createdAt: Date = Date()) {
        self.id = id
        self.recipe = recipe
        self.source = source
        self.rating = rating
        self.notes = notes
        self.createdAt = createdAt
    }
}
