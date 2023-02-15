//
//  Embedded+CoreDataProperties.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 25.01.2023.
//
//

import Foundation
import CoreData


extension Embedded {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Embedded> {
        return NSFetchRequest<Embedded>(entityName: "Embedded")
    }

    @NSManaged public var toAllList: AllFilesModelList?

}

extension Embedded : Identifiable {

}
