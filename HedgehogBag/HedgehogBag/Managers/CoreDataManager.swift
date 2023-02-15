import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    lazy var managedContext: NSManagedObjectContext = self.persistentContainer.viewContext
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HedgehogBag")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func entityDescription(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
    }
    
    func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
//            print("CoreDataM: saveContext DONE")
        } catch let error as NSError {
            print("CoreDataM: Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func saveProfileData(profileData: ProfileModel) {
        CoreDataManager.shared.deleteFromCoreData(entityName: "ProfileData")
        
        let data = ProfileData(entity: CoreDataManager.shared.entityDescription(entityName: "ProfileData"),
                               insertInto: CoreDataManager.shared.managedContext)
        guard let total = profileData.totalSpace, let used = profileData.usedSpace else { return }
        data.totalSpace = total
        data.usedSpace = used
        
        CoreDataManager.shared.saveContext()
    }

    func getFilesModelCount(entityName: String) -> Int {
        let count = try? managedContext.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
        let rqst = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        print(rqst)
        return count ?? 0
    }
    
    func getFileFromCoreData(path: String) -> FilesModel? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FilesModel")
        fetchRequest.predicate = NSPredicate(format: "path = %@", path)
        
        do {
            let result = try CoreDataManager.shared.managedContext.fetch(fetchRequest) as! [FilesModel]
            if !result.isEmpty {
                return result[0]
            } else {
                print("По запросу ничего не найдено")
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func getAllFileFromCoreData(path: String) -> Embedded? {
        print("getAllFileFromCoreData")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Embedded")
        fetchRequest.predicate = NSPredicate(format: "path = %@", path)

        do {
            let result = try CoreDataManager.shared.managedContext.fetch(fetchRequest) as! [Embedded]
            if !result.isEmpty {
                return result[0]
            } else {
                print("По запросу ничего не найдено")
                return nil
            }

        } catch {
            print(error)
            return nil
        }
    }
    
    func getProfileData() -> ProfileData? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileData")
        
        do {
            let result = try CoreDataManager.shared.managedContext.fetch(fetchRequest) as! [ProfileData]
            if !result.isEmpty {
                return result[0]
            } else {
                print("По запросу ничего не найдено")
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func deleteFromCoreData(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let results = try CoreDataManager.shared.managedContext.fetch(fetchRequest)
            for result in results {
                CoreDataManager.shared.managedContext.delete(result as! NSManagedObject)
            }
        } catch {
            print(error)
        }
        CoreDataManager.shared.saveContext()
    }

}
