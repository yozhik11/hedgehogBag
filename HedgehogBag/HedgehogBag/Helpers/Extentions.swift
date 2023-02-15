import UIKit

extension Date {
    func toString(dateFormat format : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension String {
    func toDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: self) else { return Date() }
        return date
    }
}

extension UIViewController {
    func alertOk(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.Texts.alertOk, style: .cancel)
        alertController.addAction(ok)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertDismiss(title: String, message: String?, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.Texts.alertOk, style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(ok)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertWithCancel(title: String, message: String?, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: Constants.Texts.alertCancel, style: .cancel)
        let ok = UIAlertAction(title: Constants.Texts.alertYes, style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(ok)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
}

extension UIStackView {
    convenience init(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
        self.translatesAutoresizingMaskIntoConstraints = false
        self.distribution = .equalSpacing
    }
}
