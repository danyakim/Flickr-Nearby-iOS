//
//  User.swift
//  Flickr
//
//  Created by Daniil Kim on 07.05.2021.
//

import Foundation

class User {
    var name: String
    var photoURL: URL
    
    init(name: String, photoURL: URL) {
        self.name = name
        self.photoURL = photoURL
    }
}
