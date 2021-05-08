//
//  ImageViewController.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

class ImageViewController: UIViewController,
                           UIScrollViewDelegate {
    
    //MARK: - IB Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeading: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailing: NSLayoutConstraint!
    
    //MARK: - Variables
    
    var pictureURL: URL?
    
    var initialCenter: CGPoint?
    
    //MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImage()
        
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Helping Functions
    
    func configureImage() {
        if let pictureURL = pictureURL {
            
            do {
                let imageData = try Data(contentsOf: pictureURL)
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: imageData)
                }
            } catch {
                print("Couldn't load picture data: ",error.localizedDescription)
            }
            
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            
        }
    }
    
    //MARK: - UIScrollView Controller Delegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
