import UIKit

protocol DetailViewModelProtocol {
    var file: Box<FilesModelJSON?> { get }
    var hrefData: Box<FileURLModel?> { get }
    func getFileDetail(token: String, file: FilesModelJSON)
    func getDetailImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void))
    func getDetailFile(stringUrl: String, completion: @escaping ((Data?) -> Void))
    func getURLFiles(downloadOrShare: Bool, completion: @escaping ((String?) -> Void))
    func deleteFile(completion: @escaping ((Bool) -> Void))
    func setNewFileName(newName: String, completion: @escaping ((Bool) -> Void))
}

class DetailViewModel: DetailViewModelProtocol {
    
    var file: Box<FilesModelJSON?> = Box(nil)
    var hrefData: Box<FileURLModel?> = Box(nil)
    var token: String = ""
    var pathFile: String = ""
    
    func getFileDetail(token: String, file: FilesModelJSON) {
        self.file.value = file
        self.token = token
        if let path = file.path {
            pathFile = path
            getHrefFile()
        }
    }
    
    func getHrefFile() {
        let service = NetworkService.shared
        
        service.getURLFile(token: token, path: pathFile, downloadOrShare: true) { result in
            switch result {
            case .success(let urlD):
                guard let urlD = urlD else { return }
                self.hrefData.value = urlD
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getURLFiles(downloadOrShare: Bool, completion: @escaping ((String?) -> Void)) {
        let service = NetworkService.shared
        
        service.getURLFile(token: token, path: pathFile, downloadOrShare: false) { result in
            switch result {
            case .success(let urlD):
                guard let urlD = urlD else { return }

                service.shareLinkFile(token: self.token, path: urlD.imgUrl) { result in
                    switch result {
                    case .success(let sharedFileData):
                        guard let item = sharedFileData else { return }
                        completion(item.public_url)
                    case .failure(let error):
                        print(error)
                        completion(nil)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getDetailImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        NetworkService.shared.loadDetailImage(stringUrl: stringUrl) { image in
            if let image = image {
                completion(image)
            } else {
                completion(Constants.Images.file)
            }
        }
    }
    
    func getDetailFile(stringUrl: String, completion: @escaping ((Data?) -> Void)) {
        NetworkService.shared.loadDetailFile(stringUrl: stringUrl) { data in
            if let data = data {
                completion(data)
            } else {
                completion(nil)
            }
        }
    }
    
    func deleteFile(completion: @escaping ((Bool) -> Void)) {
        let service = NetworkService.shared
        
        guard let imgPath = self.file.value?.name else {
            return
        }
        service.deleteImage(token: self.token, path: imgPath) { result in
            switch result {
            case true:
                completion(true)
            case false:
                completion(false)
            }
        }
    }
    
    func setNewFileName(newName: String, completion: @escaping ((Bool) -> Void)) {
        let service = NetworkService.shared
        
        guard let imgPath = self.file.value?.path else {
            return
        }
        
        let path = self.file.value?.path ?? ""
        let slashIndex = (path.lastIndex(of: "/") ?? path.endIndex)
        let filePathWithoutName = String(path[...slashIndex])
        let newNameWithPath = filePathWithoutName + newName
        
        service.renameFile(token: self.token, newName: newNameWithPath, path: imgPath) { responseStatusCode in
            if responseStatusCode == 201 {
                DispatchQueue.main.async {
                    self.file.value?.name = newName
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
