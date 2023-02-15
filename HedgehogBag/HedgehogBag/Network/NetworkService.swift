import UIKit

protocol NetworkServiceProtocol {
    func getLastFilesList(token: String, completion: @escaping (Result<[FilesModelJSON]?, Error>) -> Void)
}

enum NetworkError: Error {
    case errorURL
}

class NetworkService: NetworkServiceProtocol{
    static let shared = NetworkService()
    
    private let clientID = Constants.ID.clientID
    
    func authUrlRequest() -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://oauth.yandex.ru/authorize") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: "\(clientID)")
        ]
        guard let url = urlComponents.url else { return nil }
        return URLRequest(url: url)
    }
    
    //MARK: - Get list for Last Files
    func getLastFilesList(token: String, completion: @escaping (Result<[FilesModelJSON]?, Error>) -> Void) {
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded")
        components?.queryItems = [
            URLQueryItem(name: "media_type", value: "image,document"),
            URLQueryItem(name: "preview_size", value: "50x")
        ]
        
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 5
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("ERROR URLSession", error.localizedDescription)
                return completion(.failure(error))
            }
            
            if let data = data  {
                
                do {
                    let newFiles = try JSONDecoder().decode(FilesModelJSONList.self, from: data).items
                    completion(.success(newFiles))
                } catch let error as NSError {
                    print("do-catch error: ", error)
                    return completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Get list for All Files
    func getAllFilesList(token: String, path: String, completion: @escaping (Result<FilesModelJSONList?, Error>) -> Void) {
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
        components?.queryItems = [
            URLQueryItem(name: "path", value: path),
            URLQueryItem(name: "preview_size", value: "50x"),
            URLQueryItem(name: "limit", value: "50")
        ]
        
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 5
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("ERROR URLSession", error.localizedDescription)
                return completion(.failure(error))
            }
            if let data = data  {
                do {
                    let newFiles = try JSONDecoder().decode(EmbeddedJS.self, from: data)._embedded
                    completion(.success(newFiles))
                } catch let error as NSError {
                    print("do-catch error: ", error)
                    return completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Get list for Public Files
    func getPublicFilesList(token: String, path: String, completion: @escaping (Result<FilesModelJSONList?, Error>) -> Void) {
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/public")
        components?.queryItems = [
            URLQueryItem(name: "path", value: path),
            URLQueryItem(name: "preview_size", value: "50x"),
            URLQueryItem(name: "limit", value: "50")
        ]
        
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 5
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                return completion(.failure(error))
            }
            if let data = data  {
                do {
                    let newFiles = try JSONDecoder().decode(FilesModelJSONList.self, from: data)
                    completion(.success(newFiles))
                } catch let error as NSError {
                    print("do-catch error getPublicFilesList: ", error)
                    return completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - DELETE from Public Files
    func unpublish(token: String, path: String, completion: @escaping ((_ responseStatusCode: Int) -> Void)) {
        
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/unpublish")
        components?.queryItems = [URLQueryItem(name: "path", value: path)]
        
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 5
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if data != nil {
                let resp: HTTPURLResponse = response! as! HTTPURLResponse
                completion(resp.statusCode)
            } else {
                print(error.debugDescription)
            }
        }
        task.resume()
    }
    
    //MARK: - Download preview
    func loadImage(token: String, stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let errorLet = error  {
                print("loadImage ERROR", errorLet)
                return
            }
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
        task.resume()
    }
    
    //MARK: - Get URL File
    func getURLFile(token: String, path: String, downloadOrShare: Bool, completion: @escaping (Result<FileURLModel?, Error>) -> Void) {
        let fromWhere = downloadOrShare ? "download" : "publish"
        let yaLinkApi = "https://cloud-api.yandex.net/v1/disk/resources/\(fromWhere)"
        
        var components = URLComponents(string: yaLinkApi)
        components?.queryItems = [
            URLQueryItem(name: "path", value: path)
        ]
        
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = downloadOrShare ? "GET" : "PUT"
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("ERROR getURLFile", error)
                return completion(.failure(error))
            }
            
            if let data = data  {
                
                do {
                    let urlData = try JSONDecoder().decode(FileURLModel.self, from: data)
                    completion(.success(urlData))
                } catch let error as NSError {
                    print("Network do-catch error: ", error)
                    return completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Download file by URL
    func loadDetailImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        guard
            let url = URL(string: stringUrl),
            let data = try? Data(contentsOf: url)
        else {
            print("Network loadDetailImage ERROR")
            completion(Constants.Images.file)
            return
        }
        DispatchQueue.main.async {
            completion(UIImage(data: data))
        }
    }
    
    func loadDetailFile(stringUrl: String, completion: @escaping ((Data?) -> Void)) {
        guard
            let url = URL(string: stringUrl),
            let data = try? Data(contentsOf: url)
        else {
            print("Network loadDetailFile ERROR")
            completion(nil)
            return
        }
        DispatchQueue.main.async {
            completion(data)
        }
    }
    
    //MARK: - Delete file
    func deleteImage(token: String, path: String, completion: @escaping ((Bool) -> Void)){
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
        components?.queryItems = [
            URLQueryItem(name: "path", value: path)
        ]
        
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("ERROR deleteImage", error)
                return completion(false)
            }
            
            if let _ = response  {
                print("deleteImage response yeee!")
                completion(true)
                return
            } else {
                print("ERROR deleteImage response")
                completion(false)
                return
            }
        }
        task.resume()
    }
    
    //MARK: - Rename file
    func renameFile(token: String, newName: String, path: String, completion: @escaping ((_ responseStatusCode: Int) -> Void)){
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/move")
        components?.queryItems = [
            URLQueryItem(name: "from", value: path),
            URLQueryItem(name: "path", value: newName)
        ]
        
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if data != nil {
                let resp: HTTPURLResponse = response! as! HTTPURLResponse
                completion(resp.statusCode)
            } else {
                print(error.debugDescription)
            }
        }
        task.resume()
    }
    
    //MARK: - Share Link file
    func shareLinkFile(token: String, path: String, completion: @escaping (Result<FilesModelJSON?, Error>) -> Void){
        guard let link = URL(string: path) else { return }
        var request = URLRequest(url: link)
        request.httpMethod = "GET"
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("ERROR shareLinkFile", error)
                return completion(.failure(error))
            }
            
            if let data = data  {
                do {
                    let urlData = try JSONDecoder().decode(FilesModelJSON.self, from: data)
                    completion(.success(urlData))
                } catch let error as NSError {
                    print("Network do-catch shareLinkFile error: ", error)
                    return completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Profile Information
    func profileInfo(token: String, completion: @escaping (Result<ProfileModel?, Error>) -> Void) {
        guard let link = URL(string: "https://cloud-api.yandex.net/v1/disk/") else { return }
        var request = URLRequest(url: link)
        request.httpMethod = "GET"
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("NS ERROR profileInfo", error)
                return completion(.failure(error))
            }
            
            if let data = data {
                do {
                    let profileData = try JSONDecoder().decode(ProfileModel.self, from: data)
                    completion(.success(profileData))
                } catch {
                    print("Network do-catch profileInfo error: ", error)
                    return completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
