//
//  ResourceList+CoreDataProperties.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 25.01.2023.
//
//

import Foundation
import CoreData


extension ResourceList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ResourceList> {
        return NSFetchRequest<ResourceList>(entityName: "ResourceList")
    }

    @NSManaged public var limit: Int64
    @NSManaged public var offset: Int64
    @NSManaged public var path: String?
    @NSManaged public var sort: String?
    @NSManaged public var total: Int64
    @NSManaged public var items: FilesModel?

}

extension ResourceList : Identifiable {

}
