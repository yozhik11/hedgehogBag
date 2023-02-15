//
//  AllFilesModel+CoreDataProperties.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 25.01.2023.
//
//

import Foundation
import CoreData


extension AllFilesModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AllFilesModel> {
        return NSFetchRequest<AllFilesModel>(entityName: "AllFilesModel")
    }

    @NSManaged public var created: String?
    @NSManaged public var file: String?
    @NSManaged public var md5: String?
    @NSManaged public var media_type: String?
    @NSManaged public var mime_type: String?
    @NSManaged public var modified: String?
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var preview: Data?
    @NSManaged public var public_key: String?
    @NSManaged public var public_url: String?
    @NSManaged public var resource_id: String?
    @NSManaged public var revision: Int64
    @NSManaged public var size: Int64
    @NSManaged public var type: String?
    @NSManaged public var toAllFilesList: AllFilesModelList?

}

extension AllFilesModel : Identifiable {

}
