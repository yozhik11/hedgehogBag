//
//  ProfileData+CoreDataProperties.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 25.01.2023.
//
//

import Foundation
import CoreData


extension ProfileData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileData> {
        return NSFetchRequest<ProfileData>(entityName: "ProfileData")
    }

    @NSManaged public var totalSpace: Int64
    @NSManaged public var trash: Int64
    @NSManaged public var usedSpace: Int64

}

extension ProfileData : Identifiable {

}
