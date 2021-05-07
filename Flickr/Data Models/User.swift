//
//  User.swift
//  Flickr
//
//  Created by Daniil Kim on 07.05.2021.
//

import Foundation

class User {
    var id: String
    var name: String?
    var photoURL: URL?
    
    init(id: String) {
        self.id = id
    }
}
