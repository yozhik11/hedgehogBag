import Foundation
import CoreData

protocol ProfileViewModelProtocol {
    var profileInfo: Box<ProfileModel?> { get }
    var profileInfoCoreData: Box<ProfileData?> { get }
    func getProfileInfo(token: String, completion: @escaping ((Bool) -> Void))
    func getProfileInfoFromCoreData(completion: @escaping ((Bool) -> Void))
}

protocol PublicViewModelProtocol{
    var publicFiles: Box<[FilesModelJSON]> { get }
    var publicFilesCoreData: Box<[AllFilesModel]> { get }
    var isRootDir: String { get }
    var titleNavBar: String { get set }
    func getPublicFiles(token: String, path: String, completion: @escaping ((Bool?) -> Void))
    func getPublicFilesFromCoreData(path: String, completion: @escaping ((Bool) -> Void))
    func deleteFileFromPublic(token: String, path: String, completion: @escaping ((Bool) -> Void))
}

class ProfileViewModel: ProfileViewModelProtocol, PublicViewModelProtocol {
    let service = NetworkService.shared
    let coreData = CoreDataManager.shared
    var profileInfo: Box<ProfileModel?> = Box(nil)
    var profileInfoCoreData: Box<ProfileData?> = Box(nil)
    
    var publicFiles: Box<[FilesModelJSON]> = Box([])
    var publicFilesCoreData: Box<[AllFilesModel]> = Box([])
    var isRootDir = ""
    var titleNavBar = "Публичные файлы"
    
    func getProfileInfo(token: String, completion: @escaping ((Bool) -> Void)) {
        self.service.profileInfo(token: token) { result in
            switch result {
            case .success(let info):
                self.profileInfo.value = info
                guard let info = info else { return }
                self.coreData.saveProfileData(profileData: info)
                completion(true)
            case .failure(let error):
                print("PVM ERROR", error)
                completion(false)
            }
        }
    }

    func getProfileInfoFromCoreData(completion: @escaping ((Bool) -> Void)) {
        guard let data = coreData.getProfileData() else {
            completion(false)
            return }
        self.profileInfoCoreData.value = data as ProfileData
            completion(true)
    }
        
    func getPublicFiles(token: String, path: String, completion: @escaping ((Bool?) -> Void)) {
        isRootDir = path
        self.service.getPublicFilesList(token: token, path: path) { result in
            switch result {
            case .success(let files):
                guard let files = files, files.items.count != 0 else {
                    completion(.none)
                    return }
                self.publicFiles.value = files.items
                print("PVM files.path", files.path)
                completion(.some(true))
            case .failure(let error):
                print("PVM ERROR", error)
                completion(.some(false))
            }
        }
    }
        
    func getPublicFilesFromCoreData(path: String, completion: @escaping ((Bool) -> Void)) {
        print("PVM getAllFilesFromCoreData")
        isRootDir = path
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AllFilesModelList")
        fetchRequest.predicate = NSPredicate(format: "path = %@", path)

        do {
            let results = try CoreDataManager.shared.managedContext.fetch(fetchRequest) as? [AllFilesModelList]
            guard let results = results else { return completion(false) }
            guard !results.isEmpty else { return completion(false) }
            
            let items = results[0].items?.allObjects as? [AllFilesModel]
            guard let items = items else { return completion(false) }
            
            self.publicFilesCoreData.value = items
            self.publicFilesCoreData.value.sort(by: { $0.type! < $1.type! })
            completion(true)
        } catch {
            print("PVM 91 getLastFilesFromCoreData ERROR", error)
            completion(false)
        }
    }
    
    func deleteFileFromPublic(token: String, path: String, completion: @escaping ((Bool) -> Void)) {
        let service = NetworkService.shared
        service.unpublish(token: token, path: path) { responseStatusCode in
            if responseStatusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
