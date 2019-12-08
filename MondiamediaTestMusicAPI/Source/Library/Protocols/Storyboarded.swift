//
//  Storyboarded.swift
//  TochkiInteresa
//
//  Created by ASH on 05.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let className = String(describing: self.self)
        let storyboard = UIStoryboard(name: className, bundle: Bundle.main)
        
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
