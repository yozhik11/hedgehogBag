import UIKit

enum Constants {
    
    enum ID {
        static var clientID = "d039aa9e012d46aa912cf769f1d6bd80"
    }
    
    enum Colors {
        static var blackColor = UIColor.black
        static var greyColor = UIColor.gray
        static var lightGreyColor = UIColor.lightGray
        static var brownColor = UIColor.brown
        
        static var spaceUsedColor = UIColor(cgColor: .init(red: 0, green: 0, blue: 1, alpha: 0.5))
        static var spaceTrashColor = UIColor(cgColor: .init(red: 1, green: 0, blue: 0, alpha: 0.5))
        static var spaceFreeColor = UIColor(cgColor: .init(red: 0, green: 1, blue: 0, alpha: 0.5))
    }
    
    enum Fonts {
        static var headerFont: UIFont {
            UIFont.systemFont(ofSize: 16)
        }
        static var textFont: UIFont {
            UIFont.systemFont(ofSize: 14)
        }
    }
    
    enum Images {
        static let logo = UIImage(named: "LogoHedg") ?? UIImage()
        static let allFiles = UIImage(named: "AllFiles") ?? UIImage()
        static let download = UIImage(named: "Download") ?? UIImage()
        static let share = UIImage(named: "Share") ?? UIImage()
        static let update = UIImage(named: "Update") ?? UIImage()
        static let file = UIImage(named: "File") ?? UIImage()
        static let folder = UIImage(named: "Folder") ?? UIImage()
    }
    
    public enum Texts {
        public static let onboarding1 = NSLocalizedString("Now all your documents\nare in one place",
                                                          comment: "")
        public static let onboarding2 = NSLocalizedString("Can access\nfiles offline",
                                                          comment: "")
        public static let onboarding3 = NSLocalizedString("Share your files",
                                                          comment: "")
        
        public static let navLastFiles = NSLocalizedString("Last files",
                                                           comment: "")
        public static let navAllFiles = NSLocalizedString("All files",
                                                           comment: "")
        public static let navProfile = NSLocalizedString("Profile", comment: "")
        public static let labelNoInternet = NSLocalizedString("No connection to the Internet",
                                                              comment: "")
        public static let buttonLogout = NSLocalizedString("Log Out from Account", comment: "")
        public static let buttonPublic = NSLocalizedString("Public files", comment: "")
        
        
        public static let textTotal = NSLocalizedString("Total: ", comment: "")
        public static let textUsed = NSLocalizedString("Used: ", comment: "")
        public static let textTrash = NSLocalizedString("Trash: ", comment: "")
        public static let textFree = NSLocalizedString("Free: ", comment: "")
        public static let sizeKB = NSLocalizedString(" KB", comment: "")
        public static let sizeMB = NSLocalizedString(" MB", comment: "")
        public static let sizeGB = NSLocalizedString(" GB", comment: "")
        
        public static let alertError = NSLocalizedString("Error",
                                                         comment: "")
        public static let alertNoFiles = NSLocalizedString("No files in the cloud server",
                                                           comment: "")
        public static let alertNoPublicFiles = NSLocalizedString("No published files",
                                                           comment: "")
        public static let alertNoConnect = NSLocalizedString("No connections to the cloud server. Please try later.",
                                                                   comment: "")
        public static let alertUnableView = NSLocalizedString("Unable to view the file",
                                                              comment: "")
        public static let alertNoHrefFile = NSLocalizedString("The requested resource could not be found.",
                                                              comment: "")
        public static let alertLinkCopied = NSLocalizedString("The link is copied to the clipboard",
                                                              comment: "")
        public static let alertLinkNoCopied = NSLocalizedString("The link cannot be copied. Try again later.",
                                                                comment: "")
        
        public static let alertRename = NSLocalizedString("Rename file",
                                                          comment: "")
        public static let alertCancel = NSLocalizedString("Cancel",
                                                          comment: "")
        public static let alertOk = NSLocalizedString("Ok",
                                                      comment: "")
        public static let alertYes = NSLocalizedString("Yes",
                                                       comment: "")
        public static let alertDelete = NSLocalizedString("Delete",
                                                          comment: "")
        public static let alertDeleteQuest = NSLocalizedString("Do you really want to delete this file?",
                                                               comment: "")
        
        public static let alertDeleted = NSLocalizedString("File deleted",
                                                           comment: "")
        public static let alertUnavailable = NSLocalizedString("Service is temporarily unavailable",
                                                               comment: "")
        public static let alertCantReadFile = NSLocalizedString("The resource cannot be represented in the requested format.",
                                                                comment: "")
        public static let alertNoSaveToken = NSLocalizedString("Auth token didn't save", comment: "")
        public static let alertLogout = NSLocalizedString("Log Out", comment: "")
        public static let alertLogoutQuest = NSLocalizedString("Are you sure you want to log off? All local user data will be deleted.", comment: "")
    }
}
