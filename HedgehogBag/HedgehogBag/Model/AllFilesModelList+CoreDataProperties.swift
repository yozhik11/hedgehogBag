//
//  AllFilesModelList+CoreDataProperties.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 25.01.2023.
//
//

import Foundation
import CoreData


extension AllFilesModelList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AllFilesModelList> {
        return NSFetchRequest<AllFilesModelList>(entityName: "AllFilesModelList")
    }

    @NSManaged public var limit: Int64
    @NSManaged public var offset: Int64
    @NSManaged public var path: String?
    @NSManaged public var sort: String?
    @NSManaged public var total: Int64
    @NSManaged public var type: String?
    @NSManaged public var items: NSSet?
    @NSManaged public var toEmbedded: Embedded?

}

// MARK: Generated accessors for items
extension AllFilesModelList {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: AllFilesModel)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: AllFilesModel)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension AllFilesModelList : Identifiable {

}
