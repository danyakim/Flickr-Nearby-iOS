//
//  PostCollectionViewCell.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

protocol PostCollectionViewCellDelegate {
    func postCollectionViewCell(cell: PostCollectionViewCell, didTapOn pictureURL: URL)
}

class PostCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IB Outlets
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var pictureTitle: UILabel!
    
    
    //MARK: - Variables
    
    var post: Post?
    
    var delegate: PostCollectionViewCellDelegate?
    
    //MARK: - Methods
    
    func configure() {
        userImage.layer.cornerRadius = 30
        
        guard let post = post else {
            print("No data to configure cell with")
            return
        }
        
        pictureTitle.text = post.title
        
        configurePicture(for: post)
        configureUser(for: post)
        
        
    }
    
    //MARK: - Helping functions
    
    func configurePicture(for post: Post) {
        picture.setImage(fromURL: post.pictureURL)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showImage))
        picture.isUserInteractionEnabled = true
        picture.addGestureRecognizer(tap)
    }
    
    func configureUser(for post: Post) {
        userName.text = post.user.name
        userImage.setImage(fromURL: post.user.photoURL)
    }
    
    @objc func showImage() {
        delegate?.postCollectionViewCell(cell: self, didTapOn: post!.highResPictureURL)
    }
    
}

//MARK: - Async Image Loading

extension UIImageView {
    
    func setImage(fromURL url: URL) {
        
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            
            let image = UIImage(data: imageData)
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
}
