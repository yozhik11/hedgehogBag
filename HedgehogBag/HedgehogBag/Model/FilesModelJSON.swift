import UIKit

struct EmbeddedJS: Decodable {
    var _embedded: FilesModelJSONList
}

public struct FilesModelJSONList: Codable {
    public var sort:   String?
    public let items:  [FilesModelJSON]
    public var type:   String?
    public var limit:  Int64?
    public var offset: Int64?
    public var path:   String?
    public var total:  Int64?
}

public struct FilesModelJSON: Codable {
    public var resource_id: String?
    public var type: String?
    public var name: String?
    public var path: String?
    public var file: String?
    public var preview: String?
    public let created: String?
    public let modified: String?
    public var size: Int64?
    public var mime_type: String?
    public var media_type: String?
    public var md5: String?
    public var revision: Int64?
    public var public_key: String?
    public var public_url: String?
    
    public init (resource_id: String?,
                 type: String?,
                 name: String,
                 path: String,
                 file: String?,
                 preview: String,
                 created: String,
                 modified: String,
                 size: Int64,
                 mime_type: String?,
                 media_type: String?,
                 md5: String?,
                 revision: Int64?,
                 public_key: String?,
                 public_url: String?) {
        self.resource_id = resource_id
        self.type = type
        self.name = name
        self.path = path
        self.file = file
        self.preview = preview
        self.created = created
        self.modified = modified
        self.size = size
        self.mime_type = mime_type
        self.media_type = media_type
        self.md5 = md5
        self.revision = revision
        self.public_key = public_key
        self.public_url = public_url
    }
}

struct FileURLModel: Codable {
    public let imgUrl: String
    public let method: String
    public let templated: Bool
    
    enum CodingKeys: String, CodingKey {
        case imgUrl = "href"
        case method = "method"
        case templated = "templated"
    }
}

struct ProfileModel: Codable {
    public let totalSpace: Int64?
    public let usedSpace: Int64?
    public let trash: Int64?
    
    enum CodingKeys: String, CodingKey {
        case totalSpace = "total_space"
        case usedSpace = "used_space"
        case trash = "trash_size"
    }
}
