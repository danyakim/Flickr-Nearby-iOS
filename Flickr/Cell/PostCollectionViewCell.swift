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
    
    //MARK: - Constants
    
    fileprivate let picture: UIImageView = {
        let iv = UIImageView()
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    //MARK: - Variables
    
    var post: Post?
    var delegate: PostCollectionViewCellDelegate?
    
    //MARK: - Methods
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(picture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showImage))
        picture.isUserInteractionEnabled = true
        picture.addGestureRecognizer(tap)
        
        picture.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        picture.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        picture.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        picture.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        guard let post = post else {
            print("No data to configure cell with")
            return
        }
        
        configurePicture(for: post)
    }
    
    //MARK: - Helping functions
    
    func configurePicture(for post: Post) {
        DispatchQueue.global().async {
            var image: UIImage
            if let cachedImage = FlickrAPI.shared.cachedPictures[post.pictureURL] {
                image = cachedImage
                
            } else {
                guard let imageData = try? Data(contentsOf: post.pictureURL) else { return }
                
                image = UIImage(data: imageData)!
                DispatchQueue.main.sync {
                    FlickrAPI.shared.cachedPictures[post.pictureURL] = image
                }

            }
            DispatchQueue.main.async {
                self.picture.image = image
            }
        }
    }
    
    @objc func showImage() {
        delegate?.postCollectionViewCell(cell: self, didTapOn: post!.highResPictureURL)
    }
    
}

