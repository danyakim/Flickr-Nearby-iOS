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
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    
    //MARK: - Variables
    
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
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        imageView.center = scrollView.center
        
        configureImage()
    }
    
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
