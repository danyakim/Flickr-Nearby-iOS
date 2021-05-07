//
//  Picture.swift
//  Flickr
//
//  Created by Daniil Kim on 07.05.2021.
//

import UIKit

class Picture {
    
    var id: String
    var server: String
    var secret: String
    var farm: String
    var url: URL!
    
    init(id: String, server: String, secret: String, farm: String) {
        self.id = id
        self.server = server
        self.secret = secret
        self.farm = farm
    }
    
    func load() {
        FlickrAPI.shared.getMediumResolutionPicture(self, completion: { url in
            self.url = url
        })
    }
}

