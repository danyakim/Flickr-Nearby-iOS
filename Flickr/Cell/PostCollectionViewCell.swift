//
//  PostCollectionViewCell.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

protocol PostCollectionViewCellDelegate {
    func postCollectionViewCell(cell: PostCollectionViewCell, didTapOn picture: Picture)
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
        
        if let post = post {
            pictureTitle.text = post.title
            
            configurePicture(for: post)
            configureUserProfilePicture(for: post)
            
        } else {
            print("No data to configure cell with")
        }
    }
    
    //MARK: - Helping functions
    
    func configurePicture(for post: Post) {
        post.picture.load()
        picture.setImage(fromURL: post.picture.url)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showImage))
        picture.isUserInteractionEnabled = true
        picture.addGestureRecognizer(tap)
        //        do {
        //            let photo = try Data(contentsOf: post.picture.url)
        //            picture.image = UIImage(data: photo)
        //
        //            let tap = UITapGestureRecognizer(target: self, action: #selector(showImage))
        //            picture.isUserInteractionEnabled = true
        //            picture.addGestureRecognizer(tap)
        //
        //        } catch {
        //            print("Couldn't load picture: ", error.localizedDescription)
        //        }
    }
    
    func configureUserProfilePicture(for post: Post) {
        FlickrAPI.shared.getUserDetails(forUser: post.user) { response in
            switch response {
            case .success(let user):
                    DispatchQueue.main.async {
                        self.userImage.setImage(fromURL: user.photoURL!)
                        self.userName.text = user.name
                    }

            case .failure(let error):
                print("Failed to get user info: ", error.localizedDescription)
            }
        }
    }
    
    @objc func showImage() {
        delegate?.postCollectionViewCell(cell: self, didTapOn: post!.picture)
    }
    
}

extension UIImageView {
    
    func setImage(fromURL url: URL) {
        
        // just not to cause a deadlock in UI!
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            
            let image = UIImage(data: imageData)
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
}
