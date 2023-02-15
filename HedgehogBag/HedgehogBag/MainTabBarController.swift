//
//  TabbarController.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 27.09.2022.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupViews()
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .white
        tabBar.tintColor = .brown
        tabBar.unselectedItemTintColor = .lightGray
    }
    
    private func setupViews() {
        
        let lastVC = LastFilesViewController()
        let allFilesVC = AllFilesViewController()
        let profileVC = ProfileViewController()
        
        setViewControllers( [lastVC,
                             allFilesVC,
                             profileVC],
                            animated: true)
        
        guard let items = tabBar.items else { return }
        items[0].image = UIImage(systemName: "01.circle")
        items[1].image = UIImage(systemName: "02.circle")
        items[2].image = UIImage(systemName: "03.circle")
        
        items[0].title = "Последние"
        items[1].title = "Все файлы"
        items[2].title = "Профиль"

    }
}
