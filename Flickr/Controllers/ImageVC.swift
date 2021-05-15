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
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    //MARK: - Properties
    
    let pictureURL: URL
    
    //MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupImageView()
        configureImage()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Methods
    
    init(pictureURL: URL) {
        self.pictureURL = pictureURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private Methods
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        
        scrollView.pinTo(view)
    }
    
    private func setupImageView() {
        scrollView.addSubview(imageView)
        
        imageView.pinTo(scrollView, width: scrollView.widthAnchor, height: scrollView.heightAnchor)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
    }
    
    private func configureImage() {
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
