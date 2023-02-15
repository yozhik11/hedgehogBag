//
//  LastFilesItems+CoreDataProperties.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 25.01.2023.
//
//

import Foundation
import CoreData


extension LastFilesItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastFilesItems> {
        return NSFetchRequest<LastFilesItems>(entityName: "LastFilesItems")
    }

    @NSManaged public var items: FilesModel?

}

extension LastFilesItems : Identifiable {

}
