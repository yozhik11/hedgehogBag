//
//  TestViewController.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 19.08.2022.
//

import UIKit

class StartViewController: UIViewController {
    
    private lazy var logoImage: UIImageView = {
        let imageView = UIImageView(image: Constants.Images.logo)
        return imageView
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: view.frame.size.width / 2 - 150, y: view.frame.size.height - 100, width: 300, height: 40)
        button.setTitle("Войти", for: .normal)
        button.backgroundColor = .brown
        button.tintColor = .white
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(signInButtonDidTap), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(signInButton)
        view.addSubview(logoImage)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    logoImage.widthAnchor.constraint(equalToConstant: 200),
                    logoImage.heightAnchor.constraint(equalToConstant: 200),
                ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser() {
            let onboard = OnboardingViewController()
            onboard.modalPresentationStyle = .fullScreen
            present(onboard, animated: true)
        }
    }
    
    @objc func signInButtonDidTap(_ button: UIButton) {
        navigationController?.pushViewController(LastFilesViewController(), animated: true)
    }
}

//class Core {
//    static let shared = Core()
//    
//    func isNewUser() -> Bool {
//        return !UserDefaults.standard.bool(forKey: "isNewUser")
//    }
//    
//    func setIsNotNewUser() {
//        UserDefaults.standard.set(true, forKey: "isNewUser")
//    }
//    
//}
