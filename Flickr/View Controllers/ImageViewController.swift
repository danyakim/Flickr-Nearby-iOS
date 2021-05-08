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
        scrollView.isScrollEnabled = false
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Helping Functions
    
//    func updateConstraints(for size: CGSize) {
//        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
//        imageViewTop.constant = yOffset
//        imageViewBottom.constant = yOffset
//        
//        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
//        imageViewLeading.constant = xOffset
//        imageViewTrailing.constant = xOffset
//        
//        view.layoutIfNeeded()
//    }
    
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
            
            let standardPan = UIPanGestureRecognizer(target: self,
                                                     action: #selector(imageHandlePan(_:)))
            imageView.addGestureRecognizer(standardPan)
        }
    }
    
    //MARK: - UIScrollView Controller Delegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @objc func imageHandlePan(_ sender: UIPanGestureRecognizer) {
        guard let targetView = sender.view else { return }
        
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            initialCenter = targetView.center
        }
        
        if sender.state != .cancelled{
            targetView.center = CGPoint(x: targetView.center.x + translation.x,
                                        y: targetView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: view)
        } else {
            targetView.center = initialCenter!
        }
    }
}
