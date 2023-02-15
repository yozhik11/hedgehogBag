//
//  ViewProtocol.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 28.09.2022.
//

import Foundation
import UIKit

protocol ViewProtocol {
  //  var navTitle:                          String     { get }
    var navBarAppearanceConnectedColor:    UIColor { get }
    var navBarAppearanceDisconnectedColor: UIColor { get }
    func connectionChanged (status: Bool)
//    func toNextVC          (vc: UIViewController, animated: Bool)
 //   func finishRefreshAnimation ()
}

extension ViewProtocol where Self: UIViewController {
    
    func connectionChanged (status: Bool) {
        let navgationView = UIView()
        let label = UILabel()
      //  label.text = navTitle
        label.sizeToFit()
        label.center = navgationView.center
        label.textAlignment = .center
        navgationView.addSubview(label)
        var color: UIColor
        if status {
            color = navBarAppearanceConnectedColor
        } else {
            let image = UIImageView()
            image.image = UIImage(systemName: "wifi.slash")
            let imageAspect = image.image!.size.width/image.image!.size.height
            image.frame = CGRect(
                x: label.frame.origin.x-label.frame.size.height*imageAspect,
                y: label.frame.origin.y,
                width: label.frame.size.height*imageAspect,
                height: label.frame.size.height)
            image.contentMode = .scaleAspectFit
            navgationView.addSubview(image)
            color = navBarAppearanceDisconnectedColor
        }
        navigationItem.titleView = navgationView
        navgationView.sizeToFit()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = color
        appearance.titleTextAttributes = navigationController?.navigationBar.titleTextAttributes ?? [:]
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15, *) {} else {
            navigationController?.navigationBar.barTintColor = color
        }
    }
}
