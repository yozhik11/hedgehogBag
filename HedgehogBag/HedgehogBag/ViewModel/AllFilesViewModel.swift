import UIKit
import CoreData

protocol AllFilesViewModelProtocol {
    var allFiles: Box<[FilesModelJSON]> { get }
    var allFilesCoreData: Box<[AllFilesModel]> { get }
    var isRootDir: String { get }
    var titleNavBar: String { get set }
    func getAllFilesFromYa(token: String, path: String, completion: @escaping ((Bool) -> Void))
    func getImage(token: String, stringUrl: String, completion: @escaping ((UIImage?) -> Void))
    func getAllFilesFromCoreData(path: String, completion: @escaping ((Bool) -> Void))
}

class AllFilesViewModel: AllFilesViewModelProtocol {
    
    var allFiles: Box<[FilesModelJSON]> = Box([])
    var allFilesCoreData: Box<[AllFilesModel]> = Box([])
    var isRootDir = ""
    var titleNavBar = Constants.Texts.navAllFiles

    func getAllFilesFromYa(token: String, path: String, completion: @escaping ((Bool) -> Void)) {
        let service = NetworkService.shared
        isRootDir = path
        
        service.getAllFilesList(token: token, path: path) { result in
            switch result {
            case .success(let files):
                guard let files = files else { return }
                self.allFiles.value = files.items
                self.saveAllFilesToCoreData(token: token, allFilesArray: files)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    func getImage(token: String, stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        NetworkService.shared.loadImage(token: token, stringUrl: stringUrl) { image in
            if let image = image {
                completion(image)
            } else {
                completion(Constants.Images.file)
            }
        }
    }
    
    func saveAllFilesToCoreData(token: String, allFilesArray: FilesModelJSONList) {
        let oneList = AllFilesModelList(entity: CoreDataManager.shared.entityDescription(entityName: "AllFilesModelList"),
                                        insertInto: CoreDataManager.shared.managedContext)
                        
        guard let total = allFilesArray.total,
                let limit = allFilesArray.limit,
                let offset = allFilesArray.offset else { return }
        
        oneList.path = allFilesArray.path
        oneList.total = total
        oneList.limit = limit
        oneList.offset = offset
        oneList.type = allFilesArray.type
        oneList.sort = allFilesArray.sort
        
//        allFilesArray.items.forEach { item in
//            print("files: \(item.path)")
//        }
        
//        print("allFilesArray.items.count", allFilesArray.items.count, self.allFilesCoreData.value.count)

        for file in allFilesArray.items {
            self.saveOneFileToCDModel(token: token, file: file) { result in
                oneList.addToItems(result)
                CoreDataManager.shared.saveContext()
            }
        }
    }
    
    func saveOneFileToCDModel(token: String, file: FilesModelJSON, completion: @escaping (AllFilesModel) -> Void) {
        let oneFile = AllFilesModel(entity: CoreDataManager.shared.entityDescription(entityName: "AllFilesModel"),
                                 insertInto: CoreDataManager.shared.managedContext)
        oneFile.name = file.name
        oneFile.size = file.size ?? 0
        oneFile.created = file.created
        oneFile.mime_type = file.mime_type
        oneFile.path = file.path
        oneFile.type = file.type
        oneFile.md5 = file.md5
        oneFile.file = file.file
        oneFile.media_type = file.media_type
        oneFile.modified = file.modified
        oneFile.public_key = file.public_key
        oneFile.public_url = file.public_url
        oneFile.revision = file.revision ?? 0
        oneFile.resource_id = file.resource_id
        
        if file.preview == nil {
            file.type == "dir" ? (oneFile.preview = Constants.Images.folder.pngData()) : (oneFile.preview = Constants.Images.file.pngData())
            completion(oneFile)
        } else {
            getImage(token: token,
                     stringUrl: file.preview ?? "",
                     completion: { image in
                oneFile.preview = image?.pngData()
                completion(oneFile)
            })
        }
    }
    
    func getAllFilesFromCoreData(path: String, completion: @escaping ((Bool) -> Void)) {
//        print("AFVM getAllFilesFromCoreData")
        isRootDir = path
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AllFilesModelList")
        fetchRequest.predicate = NSPredicate(format: "path = %@", path)

        do {
            let results = try CoreDataManager.shared.managedContext.fetch(fetchRequest) as? [AllFilesModelList]
            guard let results = results else { return completion(false) }
            guard !results.isEmpty else { return completion(false) }
            
            let items = results[0].items?.allObjects as? [AllFilesModel]
            guard let items = items else { return completion(false) }
            
            self.allFilesCoreData.value = items
            self.allFilesCoreData.value.sort(by: { $0.type! < $1.type! })
            completion(true)
        } catch {
            print("AFVM 134 getLastFilesFromCoreData ERROR", error)
            completion(false)
        }
    }
}

