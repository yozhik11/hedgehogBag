//
//  Box.swift
//  HedgehogBag
//
//  Created by Natalia Shevaldina on 25.08.2022.
//

import UIKit

class Box<T> {
    typealias Listener = (T) -> ()
    private var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
        
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
