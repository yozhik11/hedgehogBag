import Foundation

class FilesManager {
    let shared = FileManager.default
    
    func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
        // Download the remote URL to a file
        let task = URLSession.shared.downloadTask(with: url) {
            (tempURL, response, error) in
            // Early exit on error
            guard let tempURL = tempURL else {
                completion(error)
                return
            }

            do {
                // Remove any existing document at file
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }

                // Copy the tempURL to file
                try FileManager.default.copyItem(
                    at: tempURL,
                    to: file
                )

                completion(nil)
            }

            // Handle potential file system errors
            catch let fileError {
                completion(fileError)
            }
        }

        // Start the download
        task.resume()
    }
    
    func saveFileToFileManager(fileURL: URL) {
        guard let urlDirectory = shared.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let newDirectoryUrl = urlDirectory.appendingPathExtension("HedgehogBag")
        do {
            try shared.createDirectory(atPath: <#T##String#>, withIntermediateDirectories: <#T##Bool#>)
        }
    }
    
}
