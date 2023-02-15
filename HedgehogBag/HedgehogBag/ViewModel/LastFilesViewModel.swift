import UIKit
import CoreData

protocol LastFilesViewModelProtocol {
    var lastFiles: Box<[FilesModelJSON]> { get }
    var lastFilesCoreData: Box<[FilesModel]> { get }
    func getLastFilesFromYa(token: String, completion: @escaping ((Bool) -> Void))
    func getImage(token: String, stringUrl: String, completion: @escaping ((UIImage?) -> Void))
    func getLastFilesFromCoreData(completion: @escaping ((Bool) -> Void))
}

class LastFilesViewModel: LastFilesViewModelProtocol {
    var lastFiles: Box<[FilesModelJSON]> = Box([])
    var lastFilesCoreData: Box<[FilesModel]> = Box([])

    func getLastFilesFromYa(token: String, completion: @escaping ((Bool) -> Void)) {
        let service = NetworkService.shared
        
        DispatchQueue.global(qos: .utility).async {
            service.getLastFilesList(token: token) { result in
                switch result {
                case .success(let files):
                    guard let files = files else { return }
                    self.lastFiles.value = files
                    self.saveLastFilesToCoreData(token: token, lastFilesArray: self.lastFiles.value)
                    completion(true)
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
        }
    }
    
    func getImage(token: String, stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.3) {
            NetworkService.shared.loadImage(token: token, stringUrl: stringUrl) { image in
                if let image = image {
                    completion(image)
                } else {
                    completion(Constants.Images.file)
                }
            }
        }
    }
    
    func saveLastFilesToCoreData(token: String, lastFilesArray: [FilesModelJSON]) {
        CoreDataManager.shared.deleteFromCoreData(entityName: "FilesModel")
        
        for file in lastFilesArray {
            let oneFile = FilesModel(entity: CoreDataManager.shared.entityDescription(entityName: "FilesModel"), insertInto: CoreDataManager.shared.managedContext)
            guard let previewFile = file.preview, let sizeFile = file.size else { return }
            getImage(token: token, stringUrl: previewFile, completion: { image in
                oneFile.preview = image?.pngData()
                oneFile.name = file.name
                oneFile.size = sizeFile
                oneFile.created = file.created
                oneFile.mime_type = file.mime_type
                oneFile.path = file.path
                oneFile.type = file.type

                CoreDataManager.shared.saveContext()
            })
        }
//        CoreDataManager.shared.saveContext()
    }
    
    func getLastFilesFromCoreData(completion: @escaping ((Bool) -> Void)) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FilesModel")
        
        do {
            let results = try CoreDataManager.shared.managedContext.fetch(fetchRequest) as! [FilesModel]
            self.lastFilesCoreData.value = results as [FilesModel]
            self.lastFilesCoreData.value.sort(by: { $0.created! > $1.created! })
            
            completion(true)
        } catch {
            print("LFVM getLastFilesFromCoreData ERROR", error)
            completion(false)
        }
    }
}
