//
//  GalleryCollectionVC.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import Foundation
import UIKit
import CoreLocation

class GalleryCollectionVC: UICollectionViewController {
    //MARK: - Views
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    //MARK: - Properties
    
    private var isSearch = false
    
    private var locationManager: CLLocationManager?
    private var coordinates: (lat: String, lon: String)?
    
    private var page = 1
    private var totalPages = 1
    
    private var postsViewModel = PostsDataVM()
    
    //MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsViewModel.delegate = self
        
        collectionView.prefetchDataSource = self
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: K.cells.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        
        if tabBarController?.tabBar.selectedItem?.tag == 1 { isSearch = true }
        
        navigationController?.navigationBar.isTranslucent = false
        
        if isSearch {
            searchBar.delegate = self
            navigationItem.titleView = searchBar
            hideKeyboardWhenTappedOutside()
        } else {
            setLogo()
            configureLocationManager()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isSearch && postsViewModel.count() == 0 {
            searchBar.becomeFirstResponder()
        }
        
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.tintColor = isSearch ? K.colors.red : K.colors.blue
        tabBarController?.tabBar.unselectedItemTintColor = isSearch ? K.colors.blueUnselected : K.colors.redUnselected
    }
    
    //MARK: - Collection View Data Source
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return postsViewModel.count()
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
        
        let isLastCell = indexPath.row == postsViewModel.count() - 1 && page < totalPages
        
        cell.startLoadingAnimation()
        //continue loading animation until more posts are loaded
        if isLastCell { return }
        
        let updateCellClosure: (UIImage?, URL) -> () = { image, url in
            cell.configure(image: image, highResolutionURL: url)
        }
        postsViewModel.loadImageForPost(at: indexPath.row,
                                        loadingCompletion: updateCellClosure)
        
        //change page and load more results
        if indexPath.row == postsViewModel.count() - 2 {
            if page < totalPages {
                page += 1
                
                if isSearch {
                    postsViewModel.loadPosts(tagged: postsViewModel.previousSearch, on: page)
                } else {
                    postsViewModel.loadPosts(near: coordinates, on: page)
                }
            }
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didEndDisplaying cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        postsViewModel.cancelLoadingForPost(at: indexPath.row)
    }
    
    //MARK: - Private Methods
    
    private func setLogo() {
        let logo = UIImage(named: K.imageNames.flickrLogo)
        
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
    
    private func configureCollectionView() {
        
    }
    
    private func hideKeyboardWhenTappedOutside() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func presentAlert(title: String, text: String) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok",
                                   style: .default,
                                   handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Selectors
    
    @objc
    private func scrollToTopAnimated() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                    at: .top,
                                    animated: true)
    }
    
    @objc
    private func scrollToTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                    at: .top,
                                    animated: false)
    }
    
    @objc
    private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
}

//MARK: - Scroll View Delegate

extension GalleryCollectionVC {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isSearch {
            searchBar.resignFirstResponder()
        }
    }
    
}

//MARK: - Collection View Delegate Flow Layout

extension GalleryCollectionVC: UICollectionViewDelegateFlowLayout {
    
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

extension GalleryCollectionVC: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
        postsViewModel.prefetchPosts(at: indexPaths.map({ $0.row }))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        postsViewModel.cancelPrefetchingPosts(at: indexPaths.map({ $0.row }))
    }
    
}

//MARK: - Location Manager Delegate

extension GalleryCollectionVC: CLLocationManagerDelegate {
    
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
            coordinates = (location.coordinate.latitude.description,
                           location.coordinate.longitude.description)
            
            postsViewModel.loadPosts(near: coordinates)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: ", error.localizedDescription)
    }
    
}

//MARK: - Search Bar Delegate

extension GalleryCollectionVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let tag = searchBar.text, !tag.isEmpty {
            postsViewModel.loadPosts(tagged: tag)
        }
    }
    
}

//MARK: - PostCollectionViewCell Delegate

extension GalleryCollectionVC: PostCollectionViewCellDelegate {
    
    func postCollectionViewCell(cell: PostCollectionViewCell, didTapOn pictureURL: URL) {
        let imageVC = ImageVC()
        imageVC.pictureURL = pictureURL
        
        navigationController?.show(imageVC, sender: self)
    }
    
}

//MARK: - PostsDataViewModel Delegate

extension GalleryCollectionVC: PostsDataVMDelegate {
    
    func postsDataViewModelAddedNewPosts(count: Int, totalPages: Int) {
        if postsViewModel.shouldScrollToTop { scrollToTop() }
        
        self.totalPages = totalPages
        
        //insert new posts
        let lastIndexBeforeUpdate = postsViewModel.count() - count
        var indexPaths = [IndexPath]()
        for row in lastIndexBeforeUpdate ..< postsViewModel.count() {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        collectionView.insertItems(at: indexPaths)
        
        //remove loading indicator from last cell
        if lastIndexBeforeUpdate > 0 {
            let loadingIndicatorPath = IndexPath(row: lastIndexBeforeUpdate - 1, section: 0)
            collectionView.reloadItems(at: [loadingIndicatorPath])
        }
    }
    
    func postsDataViewModelFailedToGetPosts(with tag: String? ) {
        if let tag = tag {
            self.collectionView.reloadData()
            self.presentAlert(title: "Oops",
                              text: "No photos tagged: \"\(tag)\"")
        } else {
            self.presentAlert(title: "No Results",
                              text: "No photos taken near you :(")
        }
    }
    
}
