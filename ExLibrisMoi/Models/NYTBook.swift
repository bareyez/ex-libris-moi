import Foundation

struct NYTBook: Codable, Identifiable {
    let id = UUID()
    let rank: Int
    let title: String
    let author: String
    let bookImage: String
    let description: String
    let publisher: String
    let weeksOnList: Int
    let buyLinks: [BuyLink]

    enum CodingKeys: String, CodingKey {
        case rank
        case title = "title"
        case author = "author"
        case description = "description"
        case publisher = "publisher"
        case bookImage = "book_image"
        case weeksOnList = "weeks_on_list"
        case buyLinks = "buy_links"
    }
    
    // Custom init to handle the UUID which isn't part of the JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        rank = try container.decode(Int.self, forKey: .rank)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        bookImage = try container.decode(String.self, forKey: .bookImage)
        description = try container.decode(String.self, forKey: .description)
        publisher = try container.decode(String.self, forKey: .publisher)
        weeksOnList = try container.decode(Int.self, forKey: .weeksOnList)
        buyLinks = try container.decode([BuyLink].self, forKey: .buyLinks)
    }
}

struct BuyLink: Codable {
    let name: String
    let url: String
} 