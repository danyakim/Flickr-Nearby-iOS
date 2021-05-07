//
//  FeedCollectionViewController.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit
import CoreLocation

class FeedCollectionViewController: UICollectionViewController {
    
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
    
    //MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostCell")
        
        if tabBarController?.tabBar.selectedItem?.tag == 1 { isSearch = true }
        
        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false
        
        
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
        
        tabBarController?.tabBar.isHidden = false
        
        if isSearch && posts.count == 0 {
            searchBar.becomeFirstResponder()
        }
    }
    
    //MARK: - Collection View Data Source
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCollectionViewCell
        
        
        cell.post = posts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    //MARK: - Collection View Delegate
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PostCollectionViewCell else { return }
        cell.configure()
        
        if indexPath.row == posts.count - 1 {
            //load next page
            if page < totalPages {
                page += 1
                
                if isSearch {
                    loadSearchResults(with: searchBar.text!, on: page)
                } else {
                    loadNearbyPosts(on: page)
                }
                
                print("Current page:", page )
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
        
        FlickrAPI.shared.getPhotosNear(latitude: lat,
                                       longitude: lon,
                                       page: page) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.posts += response!.0
                    self?.totalPages = response!.1
                    self?.collectionView.reloadData()
                }
                
            case .failure(let error):
                print("Failed to get photos: ", error.localizedDescription)
            //show error to user
            }
        }
    }
    
    private func loadSearchResults(with tag: String, on page: Int = 1) {
        FlickrAPI.shared.getPhotosTagged(with: tag, page: page) {[weak self] result in
            switch result {
            case .success(let response):
                
                if tag != self?.previousSearch{
                    self?.posts.removeAll()
                }
                self?.previousSearch = tag
                self?.posts += response!.0
                self?.totalPages = response!.1
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                
            case .failure(let error):
                print("Failed to get photos: ", error.localizedDescription)
            //show error to user
            }
        }
    }
    
    //MARK: - Helping Functions
    
    private func setLogo() {
        let logo = UIImage(named: K.flickrLogo)!
        
        let logoButton = UIButton(type: .custom)
        logoButton.setImage(logo, for: .normal)
        let size = CGRect(x: 0, y: 0, width: logo.size.width, height: logo.size.height)
        logoButton.frame = size
        logoButton.bounds = size
        logoButton.imageEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 280)
        logoButton.addTarget(self, action: #selector(logoClicked(_:)), for: .touchUpInside)
        
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
    
    @objc func logoClicked(_ sender: UIBarButtonItem) {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                    at: .top,
                                    animated: true)
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

//MARK: - Location Manager Delegate

extension FeedCollectionViewController: CLLocationManagerDelegate {
    
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

extension FeedCollectionViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let tag = searchBar.text, !tag.isEmpty{
            loadSearchResults(with: tag)
        }
    }
}

extension FeedCollectionViewController: PostCollectionViewCellDelegate {
    
    func postCollectionViewCell(cell: PostCollectionViewCell, didTapOn picture: Picture) {
        performSegue(withIdentifier: K.segueIdentifiers.showImage, sender: picture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueIdentifiers.showImage {
            let imageVC = segue.destination as! ImageViewController
            imageVC.picture = (sender as! Picture)
        }
    }
}
