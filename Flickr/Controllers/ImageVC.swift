//
//  ImageVC.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

class ImageVC: UIViewController,
               UIScrollViewDelegate {
    
    //MARK: - IB Outlets
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    
    //MARK: - Properties
    
    var pictureURL: URL?
    
    //MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupScrollView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Helping Functions
    
    func setupScrollView() {
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        
        scrollView.pinTo(view)
        scrollView.addSubview(imageView)
        
        imageView.pinTo(scrollView, width: scrollView.widthAnchor, height: scrollView.heightAnchor)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        configureImage()
    }
    
    func configureImage() {
        guard let pictureURL = pictureURL else { return }
        
        do {
            let imageData = try Data(contentsOf: pictureURL)
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: imageData)
            }
        } catch {
            print("Couldn't load picture data: ",error.localizedDescription)
        }
    }
    
    //MARK: - UIScrollView Controller Delegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
