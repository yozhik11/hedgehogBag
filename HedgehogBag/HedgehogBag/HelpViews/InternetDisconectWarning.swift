import UIKit

protocol InternetDisconectWarningProtocol {
    func disconectWarningLabel() -> UILabel
}

class InternetDisconectWarning: InternetDisconectWarningProtocol {
    
    func disconectWarningLabel() -> UILabel {
        let label = UILabel()
        label.text = "No Internet connection"
        label.textColor = .white
        label.backgroundColor = .red
        label.textAlignment = .center
        return label
    }
    
}
