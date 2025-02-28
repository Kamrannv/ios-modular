//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImage: Equatable {
	public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = imageURL
    }
}
//
//MARK: Before u did that, but keep the module abstract and make the changes directly on your RemoteFeedLoader
//extension FeedItem: Decodable {
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case description
//        case location
//        case imageURL = "image"
//    }
//}
