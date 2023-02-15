//
//  AuthViewController.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 30.08.2022.
//

import UIKit
import WebKit

protocol AuthViewControllerDelegate: AnyObject {
    func trySaveToken(token: String)
}

class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
        
    private let webView = WKWebView()
    private let clientID = Constants.ID.clientID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        guard let request = request else { return }
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    private var request: URLRequest? {
        NetworkService.shared.authUrlRequest()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url, url.scheme == "myphotos" {
            let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else { return }
            let token = components.queryItems?.first(where: {$0.name == "access_token"})?.value
            if let token = token {
                delegate?.trySaveToken(token: token)
            }
            
            decisionHandler(.cancel)
            print("decisionHandler(.cancel)")
            dismiss(animated: true,completion: nil)
            return
        }
   
        decisionHandler(.allow)
        print("decisionHandler(.allow)")
    }

}
