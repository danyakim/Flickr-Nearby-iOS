//
//  Constants.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import Foundation

struct K {
    struct API {
        static let flickrAPIKey = "f8857da55742c186c25fdf14f9753ade"
        static let flickrSecret = "89ec82f4422cb36f"
        
        static let per_page = 3
    }
    
    struct imageNames {
        static let flickrLogo = "flickrLogoText"
    }
    
    struct cells {
        static let reuseIdentifier = "PostCell"
        static let nibName = "PostCollectionViewCell"
    }
    
    struct segueIdentifiers {
        static let showImage = "ShowImage"
    }
}
