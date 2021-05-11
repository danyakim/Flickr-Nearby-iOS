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
    private var loadingOperations: [IndexPath: LoadPictureOperation] = [:]
    
    //MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.prefetchDataSource = self
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.cells.reuseIdentifier,
                                                      for: indexPath) as! PostCollectionViewCell
        cell.delegate = self
        
        return cell
    }
    
    //MARK: - Collection View Delegate
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        //configure cell
        guard let cell = cell as? PostCollectionViewCell else { return }
        
        //use last cell as loading indicator
        if indexPath.row == posts.count - 1 && page < totalPages {
            cell.startLoadingAnimation()
        } else {
            cell.startLoadingAnimation()
            
            let updateCellClosure: (Post) -> () = { [weak self] post in
                guard let self = self else { return }
                
                cell.configure(with: post)
                self.loadingOperations.removeValue(forKey: indexPath)
            }
            
            if let pictureLoader = loadingOperations[indexPath] {
                if let loadedPicture = pictureLoader.loadedPicture {
                    let post = posts[indexPath.row]
                    post.loadedPicture = loadedPicture
                    updateCellClosure(post)
                } else {
                    pictureLoader.loadingCompletionHandler = updateCellClosure
                }
            } else {
                if let pictureLoader = posts[indexPath.row].loadPicture() {
                    pictureLoader.loadingCompletionHandler = updateCellClosure
                    loadingQueue.addOperation(pictureLoader)
                    loadingOperations[indexPath] = pictureLoader
                } else {
                    updateCellClosure(posts[indexPath.row])
                }
            }
        }
        
        //change page and load more results
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
        
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didEndDisplaying cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if indexPath.row > 0 && indexPath.row < posts.count {
            posts[indexPath.row].loadedPicture = nil
            if let pictureLoader = loadingOperations[indexPath] {
                pictureLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
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
                self.presentAlert(title: "No Results", text: "No photos taken near you :(")
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
                    self.presentAlert(title: "Oops",
                                      text: "No photos tagged: \"\(tag)\"")
                }
                print("Failed to get photos: ", error.localizedDescription)
            }
        }
    }
    
    //MARK: - Helping Functions
    
    private func updatePostsAndTotalPages(with response: (posts: [Post], totalPages: Int)) {
        posts += response.posts
        totalPages = response.totalPages
        
        var indexPaths = [IndexPath]()
        for row in posts.count - response.posts.count  ..<  posts.count {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        
        collectionView.insertItems(at: indexPaths)
        
        //remove loading indicator from last cell
        let updatedFromRow = posts.count - response.posts.count - 1
        if updatedFromRow > 0 {
            let loadingIndicatorPath = IndexPath(row: updatedFromRow, section: 0)
            collectionView.reloadItems(at: [loadingIndicatorPath])
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
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func hideKeyboardWhenTappedOutside() {
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
    
    func presentAlert(title: String, text: String) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok",
                                   style: .default,
                                   handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Scroll View Delegate

extension GalleryCollectionViewController {
    
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

//MARK: - Collection View Prefetching

extension GalleryCollectionViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] {
                continue
            }
            
            if let pictureLoader = posts[indexPath.row].loadPicture() {
                loadingQueue.addOperation(pictureLoader)
                loadingOperations[indexPath] = pictureLoader
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let pictureLoader = loadingOperations[indexPath] {
                pictureLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
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
        
        if let tag = searchBar.text, !tag.isEmpty {
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
