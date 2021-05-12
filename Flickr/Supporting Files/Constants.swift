//
//  Constants.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

struct K {
    struct API {
        static let flickrAPIKey = "f8857da55742c186c25fdf14f9753ade"
        static let flickrSecret = "89ec82f4422cb36f"
        
        static let per_page = 50
    }
    
    struct colors {
        static let red = UIColor(red: 0.96, green: 0.00, blue: 0.46, alpha: 1.00)
        static let blue = UIColor(red: 0.12, green: 0.42, blue: 0.99, alpha: 1.00)
        static let redUnselected = red.withAlphaComponent(0.5)
        static let blueUnselected = blue.withAlphaComponent(0.4)
    }
    
    struct imageNames {
        static let flickrLogo = "flickrLogoText"
    }
    
    struct cells {
        static let reuseIdentifier = "PostCell"
        
        static let minimumSpacing: CGFloat = 1
    }
    
    struct segueIdentifiers {
        static let showImage = "ShowImage"
    }
}
