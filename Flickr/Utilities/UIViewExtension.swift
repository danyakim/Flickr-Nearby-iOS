//
//  UIViewExtension.swift
//  Flickr
//
//  Created by Daniil Kim on 14.05.2021.
//

import UIKit

extension UIView {
    
    func pinTo(_ view: UIView, width: NSLayoutDimension? = nil, height: NSLayoutDimension? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if let width = width {
            widthAnchor.constraint(equalTo: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalTo: height).isActive = true
        }
    }
    
}
