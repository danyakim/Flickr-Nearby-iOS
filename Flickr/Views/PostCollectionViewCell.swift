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
    
    //MARK: - UIViews
    
    private let picture: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.hidesWhenStopped = true
        return activityView
    }()
    
    //MARK: - Variables
    
    var highResPictureURL: URL?
    var delegate: PostCollectionViewCellDelegate?
    
    //MARK: - Methods
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(picture)
        
        picture.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        picture.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        picture.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        picture.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        //add tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(showImage))
        picture.isUserInteractionEnabled = true
        picture.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        picture.image = nil
        highResPictureURL = nil
    }
    
    func configure(with postViewModel: PostViewModel) {
        highResPictureURL = postViewModel.highResURL
        
        spinner.stopAnimating()
        
        DispatchQueue.main.async {
            self.picture.image = postViewModel.loadedPicture
        }
    }
    
    func startLoadingAnimation() {
        spinner.center = CGPoint(x: contentView.bounds.width / 2,
                                 y: contentView.bounds.height / 2)
        contentView.insertSubview(spinner, aboveSubview: picture)
        spinner.startAnimating()
    }
    
    //MARK: - Helping functions
    
    
    @objc func showImage() {
        guard let pictureURL = highResPictureURL else { return }
        
        delegate?.postCollectionViewCell(cell: self, didTapOn: pictureURL)
    }
    
}

