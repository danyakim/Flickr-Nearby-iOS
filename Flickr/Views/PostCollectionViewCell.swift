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
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        
        activityView.hidesWhenStopped = true
        return activityView
    }()
    
    //MARK: - Properties
    
    var highResPictureURL: URL?
    var delegate: PostCollectionViewCellDelegate?
    
    //MARK: - Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(picture)
        picture.pinTo(contentView)

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
    
    func configure(image picture: UIImage?, highResolutionURL: URL) {
        highResPictureURL = highResolutionURL
        
        spinner.stopAnimating()
        
        DispatchQueue.main.async {
            self.picture.image = picture
        }
    }
    
    func startLoadingAnimation() {
        contentView.addSubview(spinner)
        spinner.pinTo(contentView)
        spinner.startAnimating()
    }
    
    //MARK: - Helping functions
    
    @objc func showImage() {
        guard let pictureURL = highResPictureURL else { return }
        
        delegate?.postCollectionViewCell(cell: self, didTapOn: pictureURL)
    }
    
}

