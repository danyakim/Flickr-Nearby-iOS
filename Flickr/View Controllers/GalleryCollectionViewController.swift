//
//  GalleryCollectionViewController.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit
import CoreLocation

class GalleryCollectionViewController: UICollectionViewController {
    //MARK: - IB outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Variables
    
    private var isSearch = false
    private var previousSearch: String?
    
    private var locationManager: CLLocationManager?
    private var lat: String?
    private var lon: String?
    
    private var posts = [Post]()
    
    private var page = 1
    private var totalPages = 1
    
    private var loadingQueue = OperationQueue()
    private var loadingOperations: [IndexPath: Post] = [:]
    
    //MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: K.cells.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        
        if tabBarController?.tabBar.selectedItem?.tag == 1 { isSearch = true }
        tabBarController?.tabBar.isTranslucent = false
        
        navigationController?.navigationBar.isTranslucent = false
        
        if isSearch {
            navigationItem.titleView = searchBar
            
            searchBar.delegate = self
            
            hideKeyboardWhenTappedOutside()
        } else {
            setLogo()
            configureLocationManager()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isSearch && posts.count == 0 {
            searchBar.becomeFirstResponder()
        }
        
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.tintColor = isSearch ? K.colors.red : K.colors.blue
        tabBarController?.tabBar.unselectedItemTintColor = isSearch ? K.colors.blueUnselected : K.colors.redUnselected
    }
    
    //MARK: - Collection View Data Source
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == posts.count - 1 {
            //load next page
            if page < totalPages {
                page += 1
                
                if isSearch {
                    loadSearchResults(with: searchBar.text!, on: page)
                } else {
                    loadNearbyPosts(on: page)
                }
            }
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.cells.reuseIdentifier, for: indexPath) as! PostCollectionViewCell
        
        cell.post = posts[indexPath.row]
        cell.delegate = self
        cell.configure()
        
        return cell
    }
    
    //MARK: - Methods
    
    private func loadNearbyPosts(on page: Int = 1) {
        guard let lat = lat,
              let lon = lon else {
            print("Trying to load post before getting location")
            return
        }
        
        FlickrAPI.shared.getPhotos(location: (lat, lon),
                                   page: page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.updatePostsAndTotalPages(with: response!)
                }
            case .failure(let error):
                print("Failed to get photos: ", error.localizedDescription)
            //show error to user
            }
        }
    }
    
    private func loadSearchResults(with tag: String,
                                   on page: Int = 1) {
        FlickrAPI.shared.getPhotos(tag: tag, page: page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                var shouldScrollToTop = false
                if tag != self.previousSearch{
                    shouldScrollToTop = true
                    self.posts = []
                }
                self.previousSearch = tag
                
                DispatchQueue.main.async {
                    if shouldScrollToTop { self.scrollToTop() }
                    
                    self.updatePostsAndTotalPages(with: response!)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.posts = []
                    self.collectionView.reloadData()
                }
                print("Failed to get photos: ", error.localizedDescription)
            //show error to user
            }
        }
    }
    
    //MARK: - Helping Functions
    
    private func updatePostsAndTotalPages(with response: (posts: [Post], totalPages: Int)) {
        posts += response.posts
        totalPages = response.totalPages
        
//        print("updating posts from: ",posts.count - response.posts.count," to: ", posts.count)
        for row in posts.count - response.posts.count  ..<  posts.count {
            self.collectionView.insertItems(at: [IndexPath(row: row, section: 0)])
        }
    }
    
    private func setLogo() {
        let logo = UIImage(named: K.imageNames.flickrLogo)!
        
        let logoButton = UIButton(type: .custom)
        logoButton.setImage(logo, for: .normal)
        logoButton.imageEdgeInsets = .init(top: 0, left: 5, bottom: 10, right: 280)
        logoButton.addTarget(self, action: #selector(scrollToTopAnimated), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoButton)
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func hideKeyboardWhenTappedOutside() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func scrollToTopAnimated() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                    at: .top,
                                    animated: true)
    }
    
    @objc func scrollToTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                    at: .top,
                                    animated: false)
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isSearch {
            searchBar.resignFirstResponder()
        }
    }
    
}

//MARK: - Collection View Delegate Flow Layout

extension GalleryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return K.cells.minimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return K.cells.minimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = UIScreen.main.bounds.width / 3 - K.cells.minimumSpacing
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}

//MARK: - Location Manager Delegate

extension GalleryCollectionViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .restricted, .denied:
            print("User didn't give location permission")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lat = location.coordinate.latitude.description
            lon = location.coordinate.longitude.description
            
            loadNearbyPosts()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: ", error.localizedDescription)
    }
    
}

//MARK: - Search Bar Delegate

extension GalleryCollectionViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let tag = searchBar.text, !tag.isEmpty{
            loadSearchResults(with: tag)
        }
    }
    
}

//MARK: - PostCollectionViewCell Delegate

extension GalleryCollectionViewController: PostCollectionViewCellDelegate {
    
    func postCollectionViewCell(cell: PostCollectionViewCell, didTapOn pictureURL: URL) {
        performSegue(withIdentifier: K.segueIdentifiers.showImage, sender: pictureURL)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueIdentifiers.showImage {
            let imageVC = segue.destination as! ImageViewController
            imageVC.pictureURL = (sender as! URL)
        }
    }
    
}
